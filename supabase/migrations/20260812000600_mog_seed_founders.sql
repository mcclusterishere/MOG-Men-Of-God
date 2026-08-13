-- ============================================================================
-- MOG 06 — founding profiles: Matthew McCluster and SilverBack Fitness
-- ============================================================================
-- REVIEW ONLY. Not applied. Read the two decisions below before running it.
--
-- DECISION 1 — which address is the administrator?
--   The existing predicate hardcodes  matthew@mccluster.org
--   This session's account is         mattmccluster@gmail.com
--   They are different addresses. This script uses :admin_email so you state it
--   once rather than having me guess. Both can be granted; run the grant block
--   twice with different values if the same person holds both.
--
-- DECISION 2 — is SilverBack Fitness you, or its own account?
--   As written it is a separate front door owned by :silverback_email, flagged
--   is_org = true, and granted backend_admin as requested. If SilverBack is your
--   own brand rather than a separate operator, set :silverback_email to the same
--   address as :admin_email and it becomes a second front door you control.
--
-- This script never creates auth users. Sign both accounts up through Supabase
-- Auth first; the lookups below fail loudly rather than inventing an identity.
--
-- Run with, for example:
--   psql "$DATABASE_URL" \
--     -v admin_email=matthew@mccluster.org \
--     -v silverback_email=silverback@example.com \
--     -f 20260812000600_mog_seed_founders.sql
-- ============================================================================

begin;

-- psql only substitutes :vars in plain SQL, never inside a dollar-quoted block,
-- so they are lifted into run-scoped settings the block can read at runtime.
select set_config('mog.admin_email',      :'admin_email',      true),
       set_config('mog.silverback_email', :'silverback_email', true);

do $$
declare
  admin_id       uuid;
  silverback_id  uuid;
  subject_id     uuid;
  admin_mail     text := current_setting('mog.admin_email');
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

  -- ---- Matthew McCluster ---------------------------------------------------
  insert into public.mog_profiles
    (owner, handle, display_name, chapter, role_line, bio, entry_door,
     membership_state, is_org)
  values
    (admin_id, 'matthew-mccluster', 'Matthew McCluster', 'Founding Chapter',
     'Founder · Builder',
     'Founding brother. Building the front door that leads back to everything you already run.',
     'founding', 'invited', false)
  on conflict (owner) do update
    set display_name = excluded.display_name,
        role_line    = excluded.role_line,
        updated_at   = now();

  -- ---- SilverBack Fitness --------------------------------------------------
  insert into public.mog_profiles
    (owner, handle, display_name, chapter, role_line, bio, entry_door,
     membership_state, is_org)
  values
    (silverback_id, 'silverback-fitness', 'SilverBack Fitness', 'Atlanta',
     'Training · Discipline',
     'Strength work for men who show up. Programmes, coaching and proof of the work.',
     'founding', 'invited', true)
  on conflict (owner) do update
    set display_name = excluded.display_name,
        role_line    = excluded.role_line,
        updated_at   = now();

  -- ---- Walk both through the state machine --------------------------------
  -- Founding entry still passes through every state, so the audit trail reads
  -- the same for a founder as for anyone invited later.
  foreach subject_id in array array[admin_id, silverback_id] loop
    if (select membership_state from public.mog_profiles where owner = subject_id) = 'invited' then
      insert into public.mog_membership_events (subject, to_state, actor, reason)
      values (subject_id, 'candidate',        admin_id, 'Founding cohort'),
             (subject_id, 'pending_approval', admin_id, 'Founding cohort'),
             (subject_id, 'active',           admin_id, 'Founding cohort');
    end if;
  end loop;

  -- ---- Backend administrator grants ---------------------------------------
  insert into public.mog_roles (owner, role, granted_by, note)
  values (admin_id,      'backend_admin', admin_id, 'Founding administrator'),
         (silverback_id, 'backend_admin', admin_id, 'SilverBack Fitness operator')
  on conflict (owner, role) do update set revoked_at = null;

  raise notice 'Seeded Matthew McCluster (%) and SilverBack Fitness (%)', admin_id, silverback_id;
end $$;

-- ---- Front doors -----------------------------------------------------------
-- Placeholders. Every URL here must be replaced with a real destination before
-- this runs; none of them are verified, because verification requires an OAuth
-- grant in member_oauth rather than an assertion in a seed file.
insert into public.mog_front_door_links (owner, platform, label, url, handle, sort)
select p.owner, v.platform::mog_platform, v.label, v.url, v.handle, v.sort
  from public.mog_profiles p
  join (values
        ('silverback-fitness', 'website',   'Train with SilverBack', 'https://example.com/silverback',           null,          0),
        ('silverback-fitness', 'instagram', 'Instagram',             'https://instagram.com/example',            '@example',    1),
        ('silverback-fitness', 'youtube',   'YouTube',               'https://youtube.com/@example',             '@example',    2),
        ('silverback-fitness', 'here',      'Programmes on HERE',    'https://example.com/here/silverback',      null,          3),
        ('matthew-mccluster',  'website',   'mccluster.org',         'https://mccluster.org',                    null,          0),
        ('matthew-mccluster',  'spotify',   'Spotify',               'https://open.spotify.com/artist/example',  null,          1)
       ) as v(handle_ref, platform, label, url, handle, sort)
    on v.handle_ref = p.handle
on conflict (owner, platform, url) do nothing;

commit;
