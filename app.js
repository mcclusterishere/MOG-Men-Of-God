const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];

const DEFAULT_PROFILE = {
  name: 'Brother', chapter: 'Founding Chapter', role: '', platform: '',
  talents: 0, streak: 0, proofs: 0, replies: 0, since: new Date().getFullYear()
};

const state = {
  profile: { ...DEFAULT_PROFILE, ...JSON.parse(localStorage.getItem('mogProfile') || 'null') },
  posts: JSON.parse(localStorage.getItem('mogPosts') || '[]'),
  completed: JSON.parse(localStorage.getItem('mogCompleted') || '[]')
};

function save() {
  localStorage.setItem('mogProfile', JSON.stringify(state.profile));
  localStorage.setItem('mogPosts', JSON.stringify(state.posts));
  localStorage.setItem('mogCompleted', JSON.stringify(state.completed));
}

const escapeHTML = (s = '') =>
  s.replace(/[&<>'"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[c]));

const initials = (name = 'B') =>
  name.split(/\s+/).map(w => w[0]).join('').slice(0, 2).toUpperCase() || 'M';

const icon = id => `<svg><use href="#${id}"/></svg>`;

/* Rank ladder — earned with Talents. */
const RANKS = [
  [3000, 'Elder'], [1500, 'Watchman'], [750, 'Builder'], [250, 'Servant'], [0, 'Seeker']
];
const rankFor = talents => RANKS.find(([floor]) => talents >= floor)[1];

/* ------------------------------------------------------------------
   Navigation
   ------------------------------------------------------------------ */
function showScreen(id) {
  $$('.screen').forEach(s => s.classList.toggle('active', s.id === id));
  $$('nav button').forEach(b => b.classList.toggle('active', b.dataset.target === id));
  window.scrollTo({ top: 0, behavior: 'smooth' });
  if (id === 'me') renderProfile();
  if (id === 'feed') positionThumb();
}

$$('nav button').forEach(b => b.addEventListener('click', () => showScreen(b.dataset.target)));
$$('[data-go]').forEach(b => b.addEventListener('click', () => showScreen(b.dataset.go)));
$$('.profileJump').forEach(b => b.addEventListener('click', () => showScreen('me')));

/* Hairline appears under the app bar once the screen scrolls. */
addEventListener('scroll', () => {
  const stuck = scrollY > 8;
  $$('.bar').forEach(bar => bar.classList.toggle('stuck', stuck));
}, { passive: true });

/* ------------------------------------------------------------------
   Sheets
   ------------------------------------------------------------------ */
const openModal = id => $('#' + id).classList.add('open');
const closeModal = id => $('#' + id).classList.remove('open');

$$('[data-close]').forEach(b => b.addEventListener('click', () => closeModal(b.dataset.close)));
$$('.modal').forEach(m => m.addEventListener('click', e => { if (e.target === m) closeModal(m.id); }));

function toast(msg) {
  const t = $('#toast');
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => t.classList.remove('show'), 1900);
}

/* ------------------------------------------------------------------
   Segmented control
   ------------------------------------------------------------------ */
const filters = $('#feedFilters');
const thumb = $('.thumb', filters);

function positionThumb() {
  const active = $('button.selected', filters);
  if (!active || !active.offsetWidth) return;
  thumb.style.width = active.offsetWidth + 'px';
  thumb.style.transform = `translateX(${active.offsetLeft - 4}px)`;
}

$$('button', filters).forEach(b => b.addEventListener('click', () => {
  $$('button', filters).forEach(x => x.classList.toggle('selected', x === b));
  positionThumb();
  const f = b.dataset.filter;
  $$('.feedItem').forEach(item => {
    const match = f === 'all' || item.dataset.type === f || item.classList.contains('userPost');
    item.style.display = match ? '' : 'none';
  });
}));

addEventListener('resize', positionThumb);

/* ------------------------------------------------------------------
   Profile
   ------------------------------------------------------------------ */
function renderProfile() {
  const p = state.profile;
  const rank = rankFor(p.talents);

  $('#profileName').textContent = p.name;
  $('#profileHeader').textContent = p.name;
  $('#profileMeta').textContent = [p.role, p.chapter].filter(Boolean).join(' · ') || 'Founding Chapter';
  $('#profileAvatar').textContent = initials(p.name);
  $('#navAvatar').textContent = initials(p.name);
  $('#profileRank').textContent = rank;
  $('#rankStat').textContent = rank;

  $('#profileStreak').textContent = p.streak;
  $('#profileTalents').textContent = p.talents;
  $('#profileProofs').textContent = p.proofs;
  $('#streakStat').textContent = p.streak;
  $('#talentStat').textContent = p.talents.toLocaleString();
  $('#challengeTalents').textContent = p.talents.toLocaleString();

  $('#platformTitle').textContent = p.platform ? 'Visit my platform' : 'Add my platform';
  $('#platformMeta').textContent = p.platform || 'Music, media, ministry — show what you build.';

  $('#covenantSince').textContent = p.since;

  renderWeek();
  renderTrophies();
  renderProofGrid();
}

/* Proof grid falls back to a ghosted mark until there is work to show. */
function renderProofGrid() {
  const shots = state.posts.filter(x => x.media && !x.media.startsWith('data:video')).slice(0, 6);
  const cells = shots.map(x => `<div class="cell"><img src="${x.media}" alt="Proof"></div>`);
  while (cells.length < 4) {
    cells.push('<div class="cell empty"><img src="assets/mark-silver-256.webp" alt=""></div>');
  }
  $('#profileGrid').innerHTML = cells.join('');
}

$('#platformLink').addEventListener('click', () => {
  const url = state.profile.platform;
  if (!url) return openProfileEditor();
  open(/^https?:\/\//.test(url) ? url : 'https://' + url, '_blank');
});

function openProfileEditor() {
  const p = state.profile;
  $('#nameInput').value = p.name === 'Brother' ? '' : p.name;
  $('#chapterInput').value = p.chapter === 'Founding Chapter' ? '' : p.chapter;
  $('#roleInput').value = p.role;
  $('#platformInput').value = p.platform;
  openModal('profileModal');
}

$('#editProfile').addEventListener('click', openProfileEditor);

$('#saveProfile').addEventListener('click', () => {
  state.profile = {
    ...state.profile,
    name: $('#nameInput').value.trim() || 'Brother',
    chapter: $('#chapterInput').value.trim() || 'Founding Chapter',
    role: $('#roleInput').value.trim(),
    platform: $('#platformInput').value.trim()
  };
  save();
  renderProfile();
  closeModal('profileModal');
  toast('Profile saved');
});

$$('#profileTabs button').forEach(b => b.addEventListener('click', () => {
  $$('#profileTabs button').forEach(x => x.classList.toggle('selected', x === b));
  toast(`${b.textContent} coming next`);
}));

/* ------------------------------------------------------------------
   Trophy case — unlocks track real progress
   ------------------------------------------------------------------ */
function renderTrophies() {
  const p = state.profile;
  const earned = {
    'Verified Brother': p.proofs >= 1,
    'Rank: Builder': p.talents >= 750,
    '7 Days of Iron': p.streak >= 7,
    'Chain Breaker': state.completed.length >= 3,
    'Man of Prayer': p.streak >= 3,
    'Covenant Ring': p.name !== 'Brother',
    'Brotherhood': p.replies >= 1,
    'Redeem the Time': state.completed.length >= 5
  };
  $$('.trophy').forEach(t => t.classList.toggle('locked', !earned[t.dataset.trophy]));
}

$$('.trophy').forEach(t => t.addEventListener('click', () => {
  toast(t.classList.contains('locked') ? `${t.dataset.trophy} — still locked` : `${t.dataset.trophy} earned`);
}));

$('#trophyInfo').addEventListener('click', () =>
  toast('Post proof, hold your streak, earn Talents'));

/* ------------------------------------------------------------------
   Weekly progress
   ------------------------------------------------------------------ */
function renderWeek() {
  const days = Math.min(7, state.completed.length);
  $$('#weekDots i').forEach((dot, i) => dot.classList.toggle('on', i < days));
  $('#weekProgressText').textContent = `${days} OF 7 DAYS`;
}

/* ------------------------------------------------------------------
   Challenges
   ------------------------------------------------------------------ */
function renderHoursLeft() {
  const now = new Date();
  const midnight = new Date(now);
  midnight.setHours(24, 0, 0, 0);
  const mins = Math.round((midnight - now) / 60000);
  const h = Math.floor(mins / 60);
  $('#hoursLeft').textContent = h >= 1
    ? `${h} hour${h === 1 ? '' : 's'}`
    : `${mins} minute${mins === 1 ? '' : 's'}`;
}
setInterval(renderHoursLeft, 60000);

$$('.task').forEach(task => {
  const key = $('h3', task).textContent;
  if (state.completed.includes(key)) task.classList.add('done');

  $('.taskDone', task).addEventListener('click', () => {
    if (state.completed.includes(key)) return toast('Already completed');
    const reward = Number(task.dataset.reward || 0);
    state.completed.push(key);
    state.profile.talents += reward;
    state.profile.streak = Math.max(1, state.profile.streak);
    task.classList.add('done');
    save();
    renderProfile();
    toast(`+${reward} Talents`);
  });
});

/* ------------------------------------------------------------------
   Composer
   ------------------------------------------------------------------ */
let mediaData = '';

$('#proofFile').addEventListener('change', e => {
  const file = e.target.files[0];
  if (!file) return;
  if (file.size > 6 * 1024 * 1024) return toast('Keep demo media under 6 MB');
  const reader = new FileReader();
  reader.onload = () => {
    mediaData = reader.result;
    $('#mediaPreview').innerHTML = file.type.startsWith('video')
      ? '<div class="mediaReady">Video ready</div>'
      : `<img src="${mediaData}" alt="Post preview">`;
  };
  reader.readAsDataURL(file);
});

function openComposer() {
  mediaData = '';
  $('#mediaPreview').innerHTML = '';
  $('#postText').value = '';
  openModal('composer');
}

$('#newPost').addEventListener('click', openComposer);
$('#completeChallenge').addEventListener('click', openComposer);

$('#publishPost').addEventListener('click', () => {
  const text = $('#postText').value.trim();
  if (!text && !mediaData) return toast('Add a thought, photo, or video');
  state.posts.unshift({
    id: Date.now(), name: state.profile.name, text,
    media: mediaData, likes: 0, comments: [], time: 'now'
  });
  state.profile.proofs += 1;
  save();
  renderPosts();
  renderProfile();
  closeModal('composer');
  showScreen('feed');
  toast('Posted to Brotherhood');
});

/* ------------------------------------------------------------------
   Posts
   ------------------------------------------------------------------ */
function postHTML(p) {
  const media = !p.media ? ''
    : p.media.startsWith('data:video')
      ? '<div class="mediaReady">Video proof</div>'
      : `<img class="userMedia" src="${p.media}" alt="Brotherhood post">`;

  return `<article class="post feedItem userPost" data-id="${p.id}">
    <div class="postTop">
      <div class="avatar sm">${initials(p.name)}</div>
      <div class="grow">
        <b>${escapeHTML(p.name)}</b>
        <small>${escapeHTML(state.profile.chapter)} · ${p.time}</small>
      </div>
    </div>
    ${media}
    <p>${escapeHTML(p.text)}</p>
    <div class="postActions">
      <button class="likeBtn">${icon('i-heart')}<span>${p.likes || 0}</span></button>
      <button class="commentBtn">${icon('i-comment')}<span>${(p.comments || []).length}</span></button>
      <button class="shareBtn">${icon('i-share')}</button>
    </div>
  </article>`;
}

function renderPosts() {
  const list = $('#feedList');
  $$('.userPost', list).forEach(x => x.remove());
  state.posts.slice().reverse().forEach(p => list.insertAdjacentHTML('afterbegin', postHTML(p)));
  wireActions();
}

let activePost = null;

function wireActions() {
  $$('.likeBtn').forEach(btn => {
    if (btn.dataset.wired) return;
    btn.dataset.wired = 1;
    btn.addEventListener('click', () => {
      btn.classList.toggle('liked');
      const span = $('span', btn);
      if (span) {
        const n = (parseInt(span.textContent, 10) || 0) + (btn.classList.contains('liked') ? 1 : -1);
        span.textContent = Math.max(0, n);
        const post = btn.closest('[data-id]');
        const stored = post && state.posts.find(x => x.id == post.dataset.id);
        if (stored) { stored.likes = Math.max(0, n); save(); }
      }
    });
  });

  $$('.commentBtn').forEach(btn => {
    if (btn.dataset.wired) return;
    btn.dataset.wired = 1;
    btn.addEventListener('click', () => {
      activePost = btn.closest('[data-id]')?.dataset.id || null;
      renderComments();
      openModal('commentsModal');
    });
  });

  $$('.shareBtn').forEach(btn => {
    if (btn.dataset.wired) return;
    btn.dataset.wired = 1;
    btn.addEventListener('click', async () => {
      try {
        if (navigator.share) {
          await navigator.share({
            title: 'Men of God',
            text: 'Come build with the Brotherhood.',
            url: location.href
          });
        } else {
          toast('Share this page from your browser');
        }
      } catch { /* dismissed */ }
    });
  });
}

function renderComments() {
  const p = state.posts.find(x => x.id == activePost);
  const comments = p?.comments || [];
  $('#commentList').innerHTML = comments.length
    ? comments.map(c => `<div class="comment"><b>${escapeHTML(c.name)}</b><p>${escapeHTML(c.text)}</p></div>`).join('')
    : '<div class="comment"><b>Brotherhood</b><p>Start the conversation.</p></div>';
}

$('#sendReply').addEventListener('click', () => {
  const input = $('#replyInput');
  const text = input.value.trim();
  if (!text) return;
  const p = state.posts.find(x => x.id == activePost);
  if (p) {
    p.comments = p.comments || [];
    p.comments.push({ name: state.profile.name, text });
    state.profile.replies += 1;
    save();
    renderPosts();
    renderTrophies();
  }
  input.value = '';
  renderComments();
  toast('Reply posted');
});

/* ------------------------------------------------------------------
   Brothers
   ------------------------------------------------------------------ */
$('#enterChapter').addEventListener('click', () => {
  showScreen('feed');
  toast('Atlanta Chapter feed opened');
});
$('#searchBrothers').addEventListener('click', () => toast('Brother search is next'));
$$('.viewBrother').forEach(b =>
  b.addEventListener('click', () => toast(`${b.dataset.name} profile preview`)));

/* ------------------------------------------------------------------
   Greeting
   ------------------------------------------------------------------ */
const hour = new Date().getHours();
$('#greeting').textContent =
  hour < 5 ? 'Still up, Brother?' :
  hour < 12 ? 'Good morning, Brother.' :
  hour < 17 ? 'Good afternoon, Brother.' :
  hour < 21 ? 'Good evening, Brother.' :
  'Night check-in, Brother.';

/* ------------------------------------------------------------------
   Install / service worker
   ------------------------------------------------------------------ */
const ua = navigator.userAgent;
const isIOS = /iPhone|iPad|iPod/i.test(ua);
const isAndroid = /Android/i.test(ua);
const isStandalone = matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;

let deferredPrompt = null;
const installCard = $('#installCard');

function hideInstall(hours = 24) {
  installCard.style.display = 'none';
  localStorage.setItem('mogInstallUntil', String(Date.now() + hours * 3600000));
}

function setupInstall() {
  if (isStandalone || Number(localStorage.getItem('mogInstallUntil') || 0) > Date.now()) {
    installCard.style.display = 'none';
    return;
  }
  $('#installSkip').addEventListener('click', () => hideInstall());
  $('#installBtn').addEventListener('click', async () => {
    if (isIOS) return openModal('iosInstall');
    if (deferredPrompt) {
      deferredPrompt.prompt();
      await deferredPrompt.userChoice;
      deferredPrompt = null;
      return hideInstall(720);
    }
    toast(isAndroid ? 'Chrome menu → Add to Home screen' : 'Browser menu → Install app');
  });
}

addEventListener('beforeinstallprompt', e => { e.preventDefault(); deferredPrompt = e; });
addEventListener('appinstalled', () => hideInstall(8760));

if ('serviceWorker' in navigator) {
  addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(() => {}));
}

/* ------------------------------------------------------------------
   Boot
   ------------------------------------------------------------------ */
function dismissSplash() {
  const splash = $('#splash');
  splash.classList.add('gone');
  setTimeout(() => splash.remove(), 600);
}

setupInstall();
renderHoursLeft();
renderPosts();
renderProfile();
wireActions();
positionThumb();

setTimeout(dismissSplash, 1250);
if (!localStorage.getItem('mogProfile')) setTimeout(openProfileEditor, 2100);
