-- ============================================================================
-- MOG 05 — the HERE bridge, deliberately one-way
-- ============================================================================
-- REVIEW ONLY. Not applied.
--
-- AGENTS.md, integration boundary:
--   "Men of God remains its own product and data domain. HERE remains the
--    commerce/platform authority."
--   "Do not merge MOG databases into HERE or let MOG directly rewrite HERE
--    ledgers/prices."
--   "Future integration should be narrow: read approved catalog/offer data,
--    deep-link to approved HERE checkout/payment flows, expose platform/founder
--    profile content intentionally."
--
-- HERE lives in a separate Supabase project (ref zmnhbrjyhxzhkxmhkexs) and is
-- live: 15,341 events, 18 offerings, licence scopes, engagements.
--
-- This table is a CACHE, not a copy of authority. It holds only what MOG needs
-- to render a card and send the member to HERE to transact. There is no write
-- path back to HERE anywhere in this schema, and MOG never stores a price it
-- would be tempted to treat as authoritative.
-- ============================================================================

create table if not exists public.mog_here_offerings (
  here_offering_id  text primary key,        -- the id as HERE knows it
  title             text not null,
  summary           text,
  price_display     text,                    -- a string to show, never money maths
  checkout_url      text not null check (checkout_url ~ '^https://'),
  approved          boolean not null default false,
  synced_at         timestamptz not null default now()
);

comment on table public.mog_here_offerings is
  'Read-only mirror of approved HERE offerings. MOG never writes to HERE. '
  'price_display is a label for rendering; HERE remains the pricing authority.';

comment on column public.mog_here_offerings.approved is
  'Only offerings explicitly approved for MOG surfaces are shown. Default false, '
  'so a sync that pulls the whole HERE catalogue still surfaces nothing.';

create index if not exists mog_here_offerings_approved_idx
  on public.mog_here_offerings (approved) where approved;

alter table public.mog_here_offerings enable row level security;

create policy "approved offerings are readable" on public.mog_here_offerings
  for select using (approved or public.is_mog_admin());

-- Writes only from the sync job running as service_role, or an administrator.
-- No member-facing insert path exists.
create policy "admins manage the mirror" on public.mog_here_offerings
  for all using (public.is_mog_admin()) with check (public.is_mog_admin());

revoke all on public.mog_here_offerings from anon, authenticated;
grant select on public.mog_here_offerings to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Sync contract, for whoever builds the job:
--
--   direction   HERE  ->  MOG only. One way. No exceptions.
--   reads       offerings (id, title, summary, display price, checkout url)
--   never reads engagements, leads, campaigns, events, licence_scopes —
--               none of it is needed to render a front door
--   never writes anything, anywhere, in the HERE project
--   auth        a HERE credential scoped to read the offerings table only;
--               it must not be the HERE service_role key
--   cadence     on demand or scheduled; staleness is acceptable because MOG
--               deep-links to HERE for the actual transaction
--
-- If a future requirement needs MOG to affect HERE state, that is a change to
-- the integration boundary in AGENTS.md and needs an explicit decision first.
-- ---------------------------------------------------------------------------
