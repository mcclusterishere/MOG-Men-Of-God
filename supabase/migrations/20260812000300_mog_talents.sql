-- ============================================================================
-- MOG 03 — Talents ledger
-- ============================================================================
-- REVIEW ONLY. Not applied.
--
-- AGENTS.md: "Talents are earned reputation/reward points, not cash and not
-- purchasable currency. Use an append-only ledger. Do not store only a mutable
-- balance. Derive balance from ledger entries." and "Do not make monetary
-- redemption assumptions without explicit product/legal approval."
--
-- So: no balance column anywhere, no cash-out table, no purchase path. Balance
-- is a view. Entries are immutable once written.
-- ============================================================================

create type mog_talent_source as enum
  ('challenge', 'proof', 'streak', 'grant', 'correction');

create table if not exists public.mog_talents_ledger (
  id          bigint generated always as identity primary key,
  owner       uuid not null references auth.users (id) on delete cascade,
  delta       integer not null check (delta <> 0),
  source_kind mog_talent_source not null,
  source_ref  text,                 -- challenge key, proof id, etc.
  reason      text not null,
  actor       uuid references auth.users (id),
  at          timestamptz not null default now()
);

comment on table public.mog_talents_ledger is
  'Append-only. Never update or delete a row; post a compensating correction instead.';

create index if not exists mog_talents_ledger_owner_idx
  on public.mog_talents_ledger (owner, at desc);

-- One award per member per source. Re-running a challenge cannot double-pay.
create unique index if not exists mog_talents_ledger_source_once
  on public.mog_talents_ledger (owner, source_kind, source_ref)
  where source_ref is not null and source_kind <> 'correction';

create or replace function public.mog_talents_immutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'mog_talents_ledger is append-only; post a correction entry instead';
end;
$$;

create trigger mog_talents_no_update before update on public.mog_talents_ledger
  for each row execute function public.mog_talents_immutable();
create trigger mog_talents_no_delete before delete on public.mog_talents_ledger
  for each row execute function public.mog_talents_immutable();

create or replace view public.mog_talents_balance
with (security_invoker = true) as
  select owner,
         sum(delta)::bigint  as talents,
         count(*)::bigint    as entries,
         max(at)             as last_earned_at
    from public.mog_talents_ledger
   group by owner;

comment on view public.mog_talents_balance is
  'Derived balance. security_invoker keeps the underlying RLS in force.';

alter table public.mog_talents_ledger enable row level security;

create policy "you read your own ledger" on public.mog_talents_ledger
  for select using (owner = auth.uid() or public.is_mog_admin());

-- Members never write their own Talents. Awards come from a server-side rule
-- or an administrator, which is what keeps this reputation rather than points
-- a client can mint.
create policy "admins award talents" on public.mog_talents_ledger
  for insert with check (public.is_mog_admin());

revoke all on public.mog_talents_ledger from anon, authenticated;
grant select, insert on public.mog_talents_ledger to authenticated;
grant select on public.mog_talents_balance to authenticated;
