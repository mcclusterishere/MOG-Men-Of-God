/* ==========================================================================
   MOG BACKEND UI — front door, sign in, administration
   --------------------------------------------------------------------------
   Additive. The five-tab navigation is untouched; the front door is a
   secondary screen opened from a member, the same pattern the Bible screen
   already uses.
   ========================================================================== */

(() => {
  const B = MOGBackend;
  const el = id => document.getElementById(id);

  /* ---- front door ------------------------------------------------------ */
  function linkRow(l) {
    const label = B.PLATFORM_LABEL[l.platform] || l.platform;
    const mark = l.verified
      ? '<span class="doorVerified" data-mog="verified:micro" data-mog-where="Front door · verified link"></span>'
      : '';
    const href = l.url ? ` href="${l.url}" target="_blank" rel="noopener noreferrer"` : '';
    const tag = l.url ? 'a' : 'div';
    return `<${tag} class="doorLink"${href}>
      <span class="doorPlatform">${label}</span>
      <span class="doorBody"><b>${l.label}</b>${l.handle ? `<small>${l.handle}</small>` : ''}</span>
      ${mark}<span class="doorGo">↗</span>
    </${tag}>`;
  }

  async function openFrontDoor(handle) {
    const p = await B.frontDoor(handle);
    const body = el('frontDoorBody');
    if (!p) { body.innerHTML = '<p class="doorEmpty">No front door published yet.</p>'; }
    else {
      const initials = p.display_name.split(/\s+/).map(w => w[0]).join('').slice(0, 2).toUpperCase();
      body.innerHTML = `
        <div class="doorHero">
          <div class="avatar xl">${initials}</div>
          <h2>${p.display_name}</h2>
          <p>${[p.role_line, p.chapter].filter(Boolean).join(' · ')}</p>
          <span class="doorKind">${p.is_org ? 'BRAND FRONT DOOR' : 'BROTHER'}</span>
          ${(p.staged || p.managed_by) ? '<span class="doorStaged">Staged — operated by the founding administrator until this brand runs its own account</span>' : ''}
        </div>
        <p class="doorBio">${p.bio || ''}</p>
        <div class="sectionHead"><h3>Where this leads</h3></div>
        <div class="doorLinks">${(p.links || []).map(linkRow).join('')}</div>
        <p class="doorFoot">MOG does not host these. Each door opens the backend this member
        already runs. Verified means ownership was proven by a connected account.</p>`;
    }
    showScreen('frontdoor');
    MOG.hydrate(body);
    MOG.reveal(body);
  }
  window.openFrontDoor = openFrontDoor;

  el('frontDoorBack')?.addEventListener('click', () => showScreen('brothers'));

  /* ---- session state --------------------------------------------------- */
  function paintSession() {
    const s = B.session();
    const mode = B.isLive() ? 'live' : 'demo';
    el('sessionMode').textContent = mode === 'live' ? 'Connected' : 'Demo data';
    el('sessionMode').className = 'sessionMode ' + mode;

    el('signInBtn').hidden = Boolean(s);
    el('signedInAs').hidden = !s;
    el('adminEntry').hidden = !(s && B.isAdmin());
    if (s) {
      el('sessionEmail').textContent = s.email;
      el('sessionRole').textContent = B.isAdmin() ? 'Backend administrator' : 'Member';
    }
  }

  el('signInBtn')?.addEventListener('click', () => {
    el('loginHint').textContent = B.isLive()
      ? 'Sign in with your MOG account.'
      : 'Demo mode. matthew@mccluster.org (administrator) or silverback@silverbackfitness.com (member), any password. Neither grants anything server-side.';
    openModal('loginModal');
  });

  el('doSignIn')?.addEventListener('click', async () => {
    const email = el('loginEmail').value.trim();
    const password = el('loginPassword').value;
    if (!email) return toast('Enter your email');
    try {
      await B.signIn(email, password);
      closeModal('loginModal');
      paintSession();
      toast(B.isLive() ? 'Signed in' : 'Demo session started');
    } catch (e) {
      el('loginError').textContent = String(e.message || e);
    }
  });

  el('signOutBtn')?.addEventListener('click', () => {
    B.signOut(); paintSession(); toast('Signed out');
  });

  el('myFrontDoor')?.addEventListener('click', async () => {
    const s = B.session();
    if (!s) return toast('Sign in to see your front door');
    const p = await B.myProfile();
    if (!p) return toast('No profile yet');
    openFrontDoor(p.handle);
  });

  /* ---- administration -------------------------------------------------- */
  el('adminEntry')?.addEventListener('click', async () => {
    const o = await B.adminOverview();
    el('adminStats').innerHTML = `
      <div><b>${o.members}</b><span>ACTIVE MEMBERS</span></div>
      <div><b>${o.pending}</b><span>AWAITING APPROVAL</span></div>
      <div><b>${o.admins}</b><span>ADMINISTRATOR${o.admins === 1 ? '' : 'S'}</span></div>
      <div><b>${o.doors}</b><span>FRONT DOORS</span></div>`;
    el('adminScope').textContent = o.demo
      ? 'Demo figures. No database is connected, so nothing here is real and no administrator rights are granted.'
      : 'Live figures. Every action below is additionally enforced by row-level security, so hiding a control is convenience, not the security boundary.';
    openModal('adminModal');
  });

  document.querySelectorAll('[data-frontdoor]').forEach(b =>
    b.addEventListener('click', e => { e.stopPropagation(); openFrontDoor(b.dataset.frontdoor); }));

  paintSession();
})();
