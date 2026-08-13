-- ============================================================================
-- MOG 06 — founding profiles: Matthew McCluster and SilverBack Fitness
-- ============================================================================
-- REVIEW ONLY. Not applied.
--
-- matthew@mccluster.org is the ONLY backend administrator.
--
-- SilverBack Fitness is its own account, staged for now. It is deliberately
-- NOT granted backend_admin — operating a brand front door is authority over
-- that one profile, never over the platform. It is staged by setting
-- managed_by to the administrator, which lets the door be built and published
-- before the brand runs its own team.
--
-- When SilverBack gets its own repo and operators, clear managed_by:
--
--   update public.mog_profiles set managed_by = null
--    where handle = 'silverback-fitness';
--
-- and the profile keeps every link, every follower and its whole history. That
-- is the point of staging it as a separate account rather than a sub-page.
--
-- This script never creates auth users. Sign both accounts up through Supabase
-- Auth first; the lookups below fail loudly rather than inventing an identity.
--
-- Run with:
--   psql "$DATABASE_URL" \
--     -v admin_email=matthew@mccluster.org \
--     -v silverback_email=<the SilverBack account> \
--     -f 20260812000600_mog_seed_founders.sql
-- ============================================================================

begin;

-- psql only substitutes :vars in plain SQL, never inside a dollar-quoted block,
-- so they are lifted into run-scoped settings the block can read at runtime.
select set_config('mog.admin_email',      :'admin_email',      true),
       set_config('mog.silverback_email', :'silverback_email', true);

do $$
declare
  admin_id        uuid;
  silverback_id   uuid;
  subject_id      uuid;
  admin_mail      text := current_setting('mog.admin_email');
  silverback_mail text := current_setting('mog.silverback_email');
begin
  select id into admin_id      from auth.users where email = admin_mail;
  select id into silverback_id from auth.users where email = silverback_mail;

  if admin_id is null then
    raise exception 'No auth user for %. Create the account first.', admin_mail;
  end if;
  if silverback_id is null then
    raise exception 'No auth user for %. Create the account first.', silverback_mail;
  end if;
  if admin_id = silverback_id then
    raise exception 'SilverBack is its own account; it cannot share the administrator login';
  end if;

  -- ---- Matthew McCluster: founder, and the only administrator -------------
  insert into public.mog_profiles
    (owner, handle, display_name, chapter, role_line, bio, entry_door,
     membership_state, is_org, managed_by)
  values
    (admin_id, 'matthew-mccluster', 'Matthew McCluster', 'Founding Chapter',
     'Founder · Builder',
     'Founding brother. Building the front door that leads back to everything you already run.',
     'founding', 'invited', false, null)
  on conflict (owner) do update
    set display_name = excluded.display_name,
        role_line    = excluded.role_line;

  -- ---- SilverBack Fitness: its own account, staged ------------------------
  insert into public.mog_profiles
    (owner, handle, display_name, chapter, role_line, bio, entry_door,
     membership_state, is_org, managed_by)
  values
    (silverback_id, 'silverback-fitness', 'SilverBack Fitness', 'Atlanta',
     'Training · Discipline',
     'Strength work for men who show up. Programmes, coaching and proof of the work.',
     'founding', 'invited', true, admin_id)
  on conflict (owner) do update
    set display_name = excluded.display_name,
        role_line    = excluded.role_line,
        managed_by   = excluded.managed_by;

  -- ---- Walk both through the state machine --------------------------------
  -- Founding entry still passes through every state, so the audit trail reads
  -- the same for a founder as for anyone invited later. Both must reach
  -- 'active' or their front doors stay private.
  foreach subject_id in array array[admin_id, silverback_id] loop
    if (select membership_state from public.mog_profiles where owner = subject_id) = 'invited' then
      insert into public.mog_membership_events (subject, to_state, actor, reason)
      values (subject_id, 'candidate',        admin_id, 'Founding cohort'),
             (subject_id, 'pending_approval', admin_id, 'Founding cohort'),
             (subject_id, 'active',           admin_id, 'Founding cohort');
    end if;
  end loop;

  -- ---- The single administrator grant -------------------------------------
  insert into public.mog_roles (owner, role, granted_by, note)
  values (admin_id, 'backend_admin', admin_id, 'Sole backend administrator')
  on conflict (owner, role) do update set revoked_at = null;

  -- SilverBack is a member, not an administrator.
  insert into public.mog_roles (owner, role, granted_by, note)
  values (silverback_id, 'member', admin_id, 'Staged brand account')
  on conflict (owner, role) do update set revoked_at = null;

  raise notice 'Administrator: % (%)', admin_mail, admin_id;
  raise notice 'SilverBack staged under administrator, no admin rights: %', silverback_id;
end $$;

-- ---- Front doors -----------------------------------------------------------
-- The website link is sort 0 on purpose: the whole point is that a brother in
-- the MOG feed can reach SilverBack's actual site from here.
--
-- Replace every URL below with the real destination before running this. None
-- are verified, because verification requires an OAuth grant in member_oauth
-- rather than an assertion in a seed file.
insert into public.mog_front_door_links (owner, platform, label, url, handle, sort)
select p.owner, v.platform::mog_platform, v.label, v.url, v.handle, v.sort
  from public.mog_profiles p
  join (values
        ('silverback-fitness', 'website',   'SilverBack Fitness',  'https://example.com/silverback',          null,       0),
        ('silverback-fitness', 'instagram', 'Instagram',           'https://instagram.com/example',           '@example', 1),
        ('silverback-fitness', 'youtube',   'YouTube',             'https://youtube.com/@example',            '@example', 2),
        ('silverback-fitness', 'here',      'Programmes on HERE',  'https://example.com/here/silverback',     null,       3),
        ('matthew-mccluster',  'website',   'mccluster.org',       'https://mccluster.org',                   null,       0),
        ('matthew-mccluster',  'spotify',   'Spotify',             'https://open.spotify.com/artist/example', null,       1)
       ) as v(handle_ref, platform, label, url, handle, sort)
    on v.handle_ref = p.handle
on conflict (owner, platform, url) do nothing;

commit;
