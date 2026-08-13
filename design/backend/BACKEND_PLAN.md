# MOG backend plan — front door, identity, and the HERE boundary

**Status: reviewable design. Nothing has been applied to any live database.**

The migrations in `supabase/migrations/` were run and tested against a throwaway
local Postgres 16 cluster, not against your project. Results are at the bottom.

---

## The three decisions this was built on

| Decision | Chosen |
|---|---|
| HERE boundary | **Keep it.** MOG owns its own data. It reads approved HERE offerings and deep-links to HERE checkout. Nothing of MOG's is written into HERE. |
| Backend home | **Reuse `fxbkvcrfbbcmrrupdcjt`.** It already holds 25 auth users, `member_oauth`, `member_connections` and 13 providers including a Matthew McCluster record. |
| How far to go | **Design first, no writes.** Schema, policies and seed are written and tested; applying them is your call. |

---

## What the product actually is

A member's MOG page is a **front door**. It does not replace the backends they
already run — Etsy, eBay, Instagram, YouTube, Spotify, Apple Music, their own
site, their HERE storefront. It points at them, and where a token exists, reads
from them.

That splits cleanly into three layers, and keeping them separate is the whole
design:

| Layer | Table | Who can read it |
|---|---|---|
| Credentials | `member_oauth` *(exists)* | **Nobody via the API.** RLS is on with zero policies, so only `service_role` can touch a token. This migration does not change that, because it is already correct. |
| Reporting | `member_connections` *(exists)* | Owner and administrators. |
| Presentation | `mog_front_door_links` *(new)* | Public, but only for members who are actually `active`. |

A front door can be published with no token behind it, and a token can exist
without being advertised. Neither implies the other.

---

## Schema

| Migration | Adds | Why |
|---|---|---|
| `01_mog_roles` | `mog_roles`, `is_mog_admin()`, `has_mog_role()` | Replaces a hardcoded email with real grants |
| `02_mog_profiles_membership` | `mog_profiles`, `mog_membership_events` + transition guard | The state machine AGENTS.md asks for |
| `03_mog_talents` | `mog_talents_ledger`, `mog_talents_balance` view | Append-only, balance derived |
| `04_mog_front_door` | `mog_front_door_links` | The front door itself |
| `05_mog_here_bridge` | `mog_here_offerings` | One-way read mirror of HERE |
| `06_mog_seed_founders` | Matthew McCluster + SilverBack Fitness | Founding profiles, the single admin grant, staged brand |

### The admin model is the biggest change

Today the only administrator check is:

```sql
select coalesce(auth.jwt() ->> 'email','') = 'matthew@mccluster.org';
```

That cannot grant a second administrator, cannot revoke one without shipping a
migration, and leaves no record of who granted what. `is_mog_admin()` reads a
grants table instead, is `SECURITY DEFINER` with a pinned `search_path`, and
records `granted_by` / `revoked_at`. There is no `DELETE` policy on `mog_roles`
— revocation sets a timestamp, so the history of who held administrator rights
survives.

The legacy email check is still OR'd in so the fifteen existing policies that
call `is_mcc_admin()` keep working. **Remove that line once the grants are
seeded and verified** — it is marked in the migration.

### Talents follow the rules already written down

AGENTS.md: *"not cash and not purchasable"*, *"append-only ledger"*, *"derive
balance from ledger entries"*, *"no monetary redemption assumptions"*.

So there is no balance column anywhere, no cash-out table and no purchase path.
`UPDATE` and `DELETE` both raise; a mistake is fixed by posting a compensating
`correction` row. A unique index means the same challenge cannot pay twice.
Members cannot write their own Talents at all — that is what keeps this
reputation rather than points a client can mint.

---

## The HERE bridge is deliberately one-way

HERE (`zmnhbrjyhxzhkxmhkexs`) is live: 15,341 events, 18 offerings, licence
scopes, engagements. `mog_here_offerings` is a **cache for rendering a card**,
holding only title, summary, a display price string and a checkout URL.

- Direction: HERE → MOG only. There is no write path back, anywhere in the schema.
- `price_display` is a string. MOG never does money maths on it; HERE stays the pricing authority.
- `approved` defaults to `false`, so a sync that pulls the whole catalogue still surfaces nothing until someone approves it.
- The sync credential must be scoped to read `offerings` only — **not** the HERE service-role key.

If a future requirement needs MOG to affect HERE state, that changes the
integration boundary in AGENTS.md and needs an explicit decision first.

---

## Who holds what

`matthew@mccluster.org` is the **only** backend administrator.

SilverBack Fitness is **its own account, staged**. It is deliberately not
granted `backend_admin`, because operating a brand front door is authority over
that one profile and must never imply authority over the platform. Staging is
expressed with `mog_profiles.managed_by`, which lets the administrator build and
publish the door before the brand runs its own team.

When SilverBack gets its own repo and operators, one statement hands it over:

```sql
update public.mog_profiles set managed_by = null
 where handle = 'silverback-fitness';
```

The profile keeps its handle, links, history and followers. That is the reason
to stage it as a separate account rather than a sub-page of yours.

The seed never creates auth users. Sign both accounts up through Supabase Auth
first; the lookups fail loudly rather than inventing an identity. It also
refuses to run if the two addresses are the same.

---

## Verification

Run against a throwaway local Postgres 16 with the Supabase auth surface stubbed.

Migrations 01–05 applied cleanly. The seed produced both profiles, walked each
through `invited → candidate → pending_approval → active`, granted
`backend_admin` to Matthew only, recorded SilverBack as a `member` staged under
him, and created 2 and 4 front-door links.

**Schema invariants**

| Attempt | Result |
|---|---|
| `active → candidate` | blocked, illegal transition |
| `active → suspended` | allowed |
| `suspended → candidate` | blocked |
| Award the same challenge twice | blocked, unique index |
| `UPDATE` a ledger row | blocked, append-only |
| `DELETE` a ledger row | blocked, append-only |
| Post a `correction` | allowed; balance settled at 20 from 2 entries |
| `javascript:` front-door URL | blocked, https-only check |
| Handle `Bad Handle!` | blocked, format check |

**Row Level Security, as an ordinary signed-in member**

| Attempt | Result |
|---|---|
| Grant themselves `backend_admin` | **blocked by RLS** |
| Promote themselves through the state machine | **blocked by RLS** |
| Award themselves 9,999 Talents | **blocked by RLS** |
| Read another member's ledger | 0 rows |
| Publish a front door with `verified = true` | inserted, but forced back to `false` |
| Read an active member's front doors | 4 rows, as intended |

**Staged brand account (SilverBack), signed in as itself**

| Attempt | Result |
|---|---|
| Grant itself `backend_admin` | **blocked by RLS** |
| Move itself through the membership state machine | **blocked by RLS** |
| Read the administrator's ledger | 0 rows |
| Edit its own front door | allowed, as its operator |

**Unrelated member**

| Attempt | Result |
|---|---|
| Edit SilverBack's front door | 0 rows affected |
| Seize the staged profile by setting `managed_by` to themselves | 0 rows affected |
| View SilverBack's public front door | 4 rows, as intended |

As an administrator: role grants succeed, all ledgers are readable, and the
staged brand's doors are editable.

The seed is idempotent — running it twice produces no error and no duplicates.

---

## Separate security finding

`public.credit_colors` in the same project has **RLS disabled** — anyone with
the anon key can read or modify every row. It is unrelated to this work and is
not fixed here, because enabling RLS without policies would block all access to
it. The one-line fix, for you to decide on:

```sql
ALTER TABLE public.credit_colors ENABLE ROW LEVEL SECURITY;
```
