-- ============================================================================
-- MOG 01 — role model
-- ============================================================================
-- REVIEW ONLY. Not applied. See design/backend/BACKEND_PLAN.md.
--
-- Today the admin predicate is a single hardcoded address:
--
--   create function public.is_mcc_admin() returns boolean language sql stable
--   as $$ select coalesce(auth.jwt() ->> 'email','') = 'matthew@mccluster.org' $$;
--
-- That cannot grant a second administrator, cannot revoke one without a
-- migration, and leaves no record of who granted what. It is also STABLE and
-- not SECURITY DEFINER, so it depends entirely on the caller's JWT.
--
-- This replaces it with a grants table. is_mcc_admin() keeps working, so the
-- fifteen existing policies that call it are untouched by this migration.
-- ============================================================================

create table if not exists public.mog_roles (
  id          bigint generated always as identity primary key,
  owner       uuid not null references auth.users (id) on delete cascade,
  role        text not null check (role in ('member', 'chapter_lead', 'backend_admin')),
  granted_by  uuid references auth.users (id),
  granted_at  timestamptz not null default now(),
  revoked_at  timestamptz,
  note        text,
  unique (owner, role)
);

comment on table public.mog_roles is
  'Role grants for MOG. backend_admin supersedes the hardcoded is_mcc_admin() email check.';

create index if not exists mog_roles_owner_active_idx
  on public.mog_roles (owner) where revoked_at is null;

-- SECURITY DEFINER so the predicate can read the grants table while that table
-- stays closed to clients. search_path is pinned so the body cannot be hijacked
-- by a caller-controlled search_path.
create or replace function public.is_mog_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.mog_roles
    where owner = auth.uid()
      and role = 'backend_admin'
      and revoked_at is null
  )
  -- Transitional: the legacy predicate stays honoured until the grants table is
  -- seeded and verified, so nobody is locked out mid-migration. Remove this
  -- line once the seed in migration 06 is applied and confirmed.
  or coalesce(auth.jwt() ->> 'email', '') = 'matthew@mccluster.org';
$$;

create or replace function public.has_mog_role(target text)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.mog_roles
    where owner = auth.uid() and role = target and revoked_at is null
  );
$$;

alter table public.mog_roles enable row level security;

-- A member may see their own grants. Only an administrator sees or changes all.
create policy "you see your own roles" on public.mog_roles
  for select using (owner = auth.uid() or public.is_mog_admin());

create policy "only admins grant roles" on public.mog_roles
  for insert with check (public.is_mog_admin());

create policy "only admins change roles" on public.mog_roles
  for update using (public.is_mog_admin()) with check (public.is_mog_admin());

-- No delete policy on purpose. Grants are revoked by setting revoked_at, so the
-- history of who held administrator rights is never destroyed.

revoke all on public.mog_roles from anon, authenticated;
grant select, insert, update on public.mog_roles to authenticated;
