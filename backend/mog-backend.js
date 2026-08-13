/* ==========================================================================
   MOG BACKEND CLIENT
   --------------------------------------------------------------------------
   Talks to Supabase over plain REST — no SDK, no CDN, nothing to block.

   Two modes, decided by whether backend/config.js has been filled in:

     live   real auth and real rows, with every read and write governed by the
            RLS policies in supabase/migrations/
     demo   local fixtures that mirror the seed migration exactly, so the front
            door can be shown and reviewed before anything is applied

   The mode is always visible in the UI. A demo session is never presented as
   a real one, and demo mode grants no real administrator rights over anything.
   ========================================================================== */

const MOGBackend = (() => {
  const cfg = window.MOG_BACKEND || {};
  const live = Boolean(cfg.url && cfg.anonKey);
  const SESSION_KEY = 'mogSession';

  /* ---- demo fixtures: the same two profiles migration 06 seeds ---------- */
  const DEMO = {
    'silverback-fitness': {
      handle: 'silverback-fitness',
      display_name: 'SilverBack Fitness',
      chapter: 'Atlanta',
      role_line: 'Training · Discipline',
      bio: 'Strength work for men who show up. Programmes, coaching and proof of the work.',
      is_org: true,
      membership_state: 'active',
      talents: 1480,
      links: [
        { platform: 'website',   label: 'Train with SilverBack', handle: 'silverback.fit',    verified: true },
        { platform: 'instagram', label: 'Instagram',             handle: '@silverbackfitness', verified: true },
        { platform: 'youtube',   label: 'YouTube',               handle: '@silverbackfitness', verified: false },
        { platform: 'here',      label: 'Programmes on HERE',    handle: 'Commerce',           verified: true }
      ]
    },
    'matthew-mccluster': {
      handle: 'matthew-mccluster',
      display_name: 'Matthew McCluster',
      chapter: 'Founding Chapter',
      role_line: 'Founder · Builder',
      bio: 'Founding brother. Building the front door that leads back to everything you already run.',
      is_org: false,
      membership_state: 'active',
      talents: 2310,
      links: [
        { platform: 'website', label: 'mccluster.org', handle: 'mccluster.org', verified: true },
        { platform: 'spotify', label: 'Spotify',       handle: 'Artist',        verified: false }
      ]
    }
  };

  /* Demo accounts. These sign you into a LOCAL session only — they are not
     credentials, they grant nothing server-side, and the UI says so. */
  const DEMO_ACCOUNTS = {
    'matthew@mccluster.org':  { handle: 'matthew-mccluster',  admin: true },
    'silverback@example.com': { handle: 'silverback-fitness', admin: true }
  };

  const readSession = () => { try { return JSON.parse(localStorage.getItem(SESSION_KEY)); } catch { return null; } };
  const writeSession = s => s ? localStorage.setItem(SESSION_KEY, JSON.stringify(s))
                              : localStorage.removeItem(SESSION_KEY);

  async function rest(path, { method = 'GET', body, auth = true } = {}) {
    const session = readSession();
    const res = await fetch(`${cfg.url}/rest/v1/${path}`, {
      method,
      headers: {
        apikey: cfg.anonKey,
        Authorization: `Bearer ${auth && session?.access_token ? session.access_token : cfg.anonKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=representation'
      },
      body: body ? JSON.stringify(body) : undefined
    });
    if (!res.ok) throw new Error(`${res.status} ${await res.text()}`);
    return res.json();
  }

  /* ---- auth ------------------------------------------------------------ */
  async function signIn(email, password) {
    if (!live) {
      const account = DEMO_ACCOUNTS[email.trim().toLowerCase()];
      if (!account) throw new Error('Unknown demo account');
      const session = { demo: true, email, ...account };
      writeSession(session);
      return session;
    }
    const res = await fetch(`${cfg.url}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: { apikey: cfg.anonKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    if (!res.ok) throw new Error('Those details were not accepted');
    const data = await res.json();
    const session = {
      demo: false, email,
      access_token: data.access_token,
      refresh_token: data.refresh_token,
      user_id: data.user?.id
    };
    writeSession(session);
    session.admin = await checkAdmin();
    session.handle = (await myProfile())?.handle || null;
    writeSession(session);
    return session;
  }

  function signOut() { writeSession(null); }
  const session = () => readSession();
  const isAdmin = () => Boolean(readSession()?.admin);

  /* An administrator is whoever holds a live backend_admin grant. The check is
     a query, never a claim the client can assert about itself. */
  async function checkAdmin() {
    if (!live) return Boolean(readSession()?.admin);
    try {
      const rows = await rest('mog_roles?select=role&role=eq.backend_admin&revoked_at=is.null');
      return rows.length > 0;
    } catch { return false; }
  }

  async function myProfile() {
    if (!live) {
      const s = readSession();
      return s ? DEMO[s.handle] : null;
    }
    const rows = await rest('mog_profiles?select=*&limit=1');
    return rows[0] || null;
  }

  /* ---- front doors ----------------------------------------------------- */
  async function frontDoor(handle) {
    if (!live) return DEMO[handle] || null;
    const rows = await rest(
      `mog_profiles?select=handle,display_name,chapter,role_line,bio,is_org,membership_state,` +
      `mog_front_door_links(platform,label,handle,url,verified,sort,visible)` +
      `&handle=eq.${encodeURIComponent(handle)}&limit=1`
    );
    const p = rows[0];
    if (!p) return null;
    p.links = (p.mog_front_door_links || [])
      .filter(l => l.visible)
      .sort((a, b) => a.sort - b.sort);
    return p;
  }

  const directory = async () => live
    ? rest('mog_profiles?select=handle,display_name,role_line,is_org&membership_state=eq.active')
    : Object.values(DEMO);

  /* ---- administration -------------------------------------------------- */
  /* Every one of these is gated server-side by RLS as well. The UI hiding
     them is convenience, not the security boundary. */
  async function adminOverview() {
    if (!live) {
      return {
        demo: true,
        members: Object.keys(DEMO).length,
        admins: Object.values(DEMO_ACCOUNTS).filter(a => a.admin).length,
        pending: 0,
        doors: Object.values(DEMO).reduce((n, p) => n + p.links.length, 0)
      };
    }
    const [profiles, roles, doors] = await Promise.all([
      rest('mog_profiles?select=membership_state'),
      rest('mog_roles?select=role&role=eq.backend_admin&revoked_at=is.null'),
      rest('mog_front_door_links?select=id')
    ]);
    return {
      demo: false,
      members: profiles.filter(p => p.membership_state === 'active').length,
      pending: profiles.filter(p => p.membership_state === 'pending_approval').length,
      admins: roles.length,
      doors: doors.length
    };
  }

  return {
    isLive: () => live,
    signIn, signOut, session, isAdmin, checkAdmin,
    myProfile, frontDoor, directory, adminOverview,
    PLATFORM_LABEL: {
      website: 'Website', instagram: 'Instagram', youtube: 'YouTube', tiktok: 'TikTok',
      x: 'X', spotify: 'Spotify', apple_music: 'Apple Music', soundcloud: 'SoundCloud',
      bandcamp: 'Bandcamp', etsy: 'Etsy', ebay: 'eBay', shopify: 'Shopify',
      patreon: 'Patreon', here: 'HERE'
    }
  };
})();
