-- ============================================================================
-- MOG 02 — profiles and the membership state machine
-- ============================================================================
-- REVIEW ONLY. Not applied.
--
-- AGENTS.md: "There are only two intended doors: founding/inaugural group-chat
-- access, and invitation by an existing Brother followed by approval." and
-- "Model it as a state machine so approval logic can be replaced later without
-- rewriting membership identity."
--
-- So state lives in an append-only event log and the profile column is a
-- derived cache. Replacing the approval rules later means changing who is
-- allowed to write an event, not migrating identity.
-- ============================================================================

create type mog_membership_state as enum
  ('invited', 'candidate', 'pending_approval', 'active', 'suspended', 'removed');

create type mog_entry_door as enum ('founding', 'invitation');

create table if not exists public.mog_profiles (
  owner             uuid primary key references auth.users (id) on delete cascade,
  handle            text not null unique
                      check (handle ~ '^[a-z0-9][a-z0-9-]{1,38}[a-z0-9]$'),
  display_name      text not null,
  chapter           text,
  role_line         text,                       -- "Trainer · Builder"
  bio               text,
  avatar_url        text,
  entry_door        mog_entry_door not null,
  membership_state  mog_membership_state not null default 'invited',
  invited_by        uuid references auth.users (id),
  is_org            boolean not null default false,  -- a brand front door, not a person
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on column public.mog_profiles.membership_state is
  'Derived cache of the latest mog_membership_events row. Never write directly.';
comment on column public.mog_profiles.is_org is
  'True for a brand or business front door such as SilverBack Fitness, false for a person.';

create table if not exists public.mog_membership_events (
  id          bigint generated always as identity primary key,
  subject     uuid not null references auth.users (id) on delete cascade,
  from_state  mog_membership_state,
  to_state    mog_membership_state not null,
  actor       uuid references auth.users (id),
  reason      text,
  at          timestamptz not null default now()
);

create index if not exists mog_membership_events_subject_idx
  on public.mog_membership_events (subject, at desc);

-- Only these transitions are legal. Anything else raises, so an invalid state
-- cannot be written even by a caller holding the service role.
create or replace function public.mog_membership_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  current_state mog_membership_state;
  allowed       mog_membership_state[];
begin
  select membership_state into current_state
    from public.mog_profiles where owner = new.subject;

  allowed := case current_state
    when 'invited'          then array['candidate','removed']::mog_membership_state[]
    when 'candidate'        then array['pending_approval','removed']::mog_membership_state[]
    when 'pending_approval' then array['active','candidate','removed']::mog_membership_state[]
    when 'active'           then array['suspended','removed']::mog_membership_state[]
    when 'suspended'        then array['active','removed']::mog_membership_state[]
    when 'removed'          then array[]::mog_membership_state[]
    else array['invited']::mog_membership_state[]
  end;

  if current_state is not null and not (new.to_state = any (allowed)) then
    raise exception 'illegal membership transition % -> %', current_state, new.to_state;
  end if;

  new.from_state := current_state;

  update public.mog_profiles
     set membership_state = new.to_state, updated_at = now()
   where owner = new.subject;

  return new;
end;
$$;

create trigger mog_membership_events_guard
  before insert on public.mog_membership_events
  for each row execute function public.mog_membership_guard();

alter table public.mog_profiles enable row level security;
alter table public.mog_membership_events enable row level security;

-- An active profile is readable by any signed-in member. Everything else is
-- visible only to its owner and to administrators, so a suspended or pending
-- member is not exposed to the brotherhood.
create policy "active profiles are visible to members" on public.mog_profiles
  for select using (
    membership_state = 'active'
    or owner = auth.uid()
    or public.is_mog_admin()
  );

create policy "you edit your own profile" on public.mog_profiles
  for update using (owner = auth.uid() or public.is_mog_admin())
  with check (owner = auth.uid() or public.is_mog_admin());

create policy "admins create profiles" on public.mog_profiles
  for insert with check (public.is_mog_admin());

create policy "you read your own membership history" on public.mog_membership_events
  for select using (subject = auth.uid() or public.is_mog_admin());

-- Only an administrator moves someone through the state machine. Replacing the
-- approval ritual later means changing this one policy.
create policy "admins record membership events" on public.mog_membership_events
  for insert with check (public.is_mog_admin());

revoke all on public.mog_profiles, public.mog_membership_events from anon, authenticated;
grant select, insert, update on public.mog_profiles to authenticated;
grant select, insert on public.mog_membership_events to authenticated;
