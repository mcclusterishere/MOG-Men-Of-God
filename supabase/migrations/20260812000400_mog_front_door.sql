-- ============================================================================
-- MOG 04 — the front door
-- ============================================================================
-- REVIEW ONLY. Not applied.
--
-- The product idea: a member's MOG page is a front door that leads to the
-- backends they already run — Etsy, eBay, Instagram, YouTube, Spotify, Apple
-- Music, their own site. MOG does not replace those. It points at them and,
-- where a token exists, reads from them.
--
-- Three layers, deliberately separate:
--
--   public.member_oauth        credentials. Already exists. RLS on with ZERO
--                              policies, so no client can read a token. That
--                              posture is correct and this migration does not
--                              touch it.
--   public.member_connections  reporting/distribution records. Already exists.
--   public.mog_front_door_links  the public, outbound-facing doors. New here.
--
-- Splitting presentation from credentials means a front door can be published
-- without any token existing, and a token can exist without being advertised.
-- ============================================================================

create type mog_platform as enum (
  'website', 'instagram', 'youtube', 'tiktok', 'x',
  'spotify', 'apple_music', 'soundcloud', 'bandcamp',
  'etsy', 'ebay', 'shopify', 'patreon',
  'here'                                  -- the HERE storefront, see migration 05
);

create table if not exists public.mog_front_door_links (
  id          bigint generated always as identity primary key,
  owner       uuid not null references auth.users (id) on delete cascade,
  platform    mog_platform not null,
  label       text not null,
  url         text not null check (url ~ '^https://'),   -- https only, no javascript: or data:
  handle      text,
  sort        integer not null default 0,
  visible     boolean not null default true,
  -- Verified means MOG confirmed ownership via an OAuth grant in member_oauth.
  -- It is set by the server, never by the member.
  verified    boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (owner, platform, url)
);

comment on column public.mog_front_door_links.verified is
  'Server-set only. True when a matching member_oauth grant proves ownership.';

create index if not exists mog_front_door_links_owner_idx
  on public.mog_front_door_links (owner, sort) where visible;

-- A member cannot mark their own link verified. Ownership is proven by a token
-- grant, not by asserting it.
create or replace function public.mog_front_door_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- auth.uid() is null for a server-side caller; the guard defends against a
  -- member asserting ownership, not against the sync job that proves it.
  if auth.uid() is not null and not public.is_mog_admin() then
    if tg_op = 'INSERT' then
      new.verified := false;
    elsif new.verified is distinct from old.verified then
      raise exception 'verified is set by ownership proof, not by the member';
    end if;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger mog_front_door_links_guard
  before insert or update on public.mog_front_door_links
  for each row execute function public.mog_front_door_guard();

alter table public.mog_front_door_links enable row level security;

-- A front door is public by design, but only for a member who is actually
-- active. A suspended member's doors close with them.
create policy "front doors of active members are public" on public.mog_front_door_links
  for select using (
    (visible and exists (
      select 1 from public.mog_profiles p
       where p.owner = mog_front_door_links.owner
         and p.membership_state = 'active'
    ))
    or owner = auth.uid()
    or public.is_mog_admin()
  );

-- One predicate for "may act on this profile's doors", so the four policies
-- below cannot drift apart. A manager operates a staged brand front door; that
-- is authority over one profile, never over the platform.
create or replace function public.mog_may_manage(profile_owner uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select profile_owner = auth.uid()
      or public.is_mog_admin()
      or exists (
           select 1 from public.mog_profiles p
            where p.owner = profile_owner and p.managed_by = auth.uid()
         );
$$;

create policy "you add doors you may manage" on public.mog_front_door_links
  for insert with check (public.mog_may_manage(owner));

create policy "you edit doors you may manage" on public.mog_front_door_links
  for update using (public.mog_may_manage(owner))
  with check (public.mog_may_manage(owner));

create policy "you remove doors you may manage" on public.mog_front_door_links
  for delete using (public.mog_may_manage(owner));

revoke all on public.mog_front_door_links from anon, authenticated;
grant select, insert, update, delete on public.mog_front_door_links to authenticated;
grant select on public.mog_front_door_links to anon;   -- public front doors only, per policy
