(() => {
  'use strict';

  const STORAGE_KEY = 'peopleOfGod.care.v1';
  const defaultCare = {
    checkIns: 0,
    prayerActs: 0,
    supportActs: 0,
    lastActivityAt: null,
    didCompleteWelcome: false
  };

  const allowedRoutes = new Set(['welcome', 'today', 'checkin', 'prayer', 'speak', 'support']);
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];

  function loadCare() {
    try {
      const value = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}');
      return {
        checkIns: Math.max(0, Number(value.checkIns) || 0),
        prayerActs: Math.max(0, Number(value.prayerActs) || 0),
        supportActs: Math.max(0, Number(value.supportActs) || 0),
        lastActivityAt: typeof value.lastActivityAt === 'string' ? value.lastActivityAt : null,
        didCompleteWelcome: value.didCompleteWelcome === true
      };
    } catch {
      return { ...defaultCare };
    }
  }

  let care = loadCare();
  let currentRoute = care.didCompleteWelcome ? 'today' : 'welcome';
  let selectedState = null;
  let selectedSupport = new Set();
  let checkInCounted = false;
  let prayerCounted = false;
  let wordsCounted = false;
  let deferredInstallPrompt = null;

  function saveCare() {
    // Deliberately persist participation only. Feeling state, support choices,
    // prayer text, and affirmations never enter localStorage or analytics.
    localStorage.setItem(STORAGE_KEY, JSON.stringify(POGPrivacy.sanitizeCareForStorage(care)));
  }

  function recordCare(kind) {
    care[kind] += 1;
    care.lastActivityAt = new Date().toISOString();
    saveCare();
    renderProgress();
  }

  function nextMilestone(total) {
    return [5, 10, 25, 50, 100, 250].find(value => value > total)
      || (Math.floor(total / 100) + 1) * 100;
  }

  function renderProgress() {
    const total = care.checkIns + care.prayerActs + care.supportActs;
    const milestone = nextMilestone(total);
    const previous = [0, 5, 10, 25, 50, 100, 250].filter(value => value <= total).at(-1) || 0;
    const span = Math.max(1, milestone - previous);
    const progress = Math.min(1, Math.max(0, (total - previous) / span));

    $('#careTotal').textContent = total;
    $('#progressRing').style.setProperty('--progress', `${progress * 360}deg`);
    $('#milestoneTitle').textContent = total === 0 ? 'Your first milestone' : `${milestone}-act milestone`;
    $('#milestoneCopy').textContent = `${milestone - total} ${milestone - total === 1 ? 'act' : 'acts'} of care to go.`;
  }

  function routeTo(route, updateHistory = true) {
    if (!allowedRoutes.has(route)) route = 'today';
    if (!care.didCompleteWelcome && route !== 'welcome') route = 'welcome';
    if (route === 'checkin' && currentRoute !== 'checkin') resetCheckInFlow();
    currentRoute = route;

    $$('.screen').forEach(screen => screen.classList.toggle('active', screen.id === route));
    $$('[data-route]', $('#bottomNav')).forEach(button => {
      button.classList.toggle('active', button.dataset.route === route);
    });

    const isWelcome = route === 'welcome';
    $('#topbar').hidden = isWelcome;
    $('#bottomNav').hidden = isWelcome;
    window.scrollTo({ top: 0, behavior: 'smooth' });

    if (updateHistory && !isWelcome) {
      const url = new URL(window.location.href);
      url.searchParams.set('screen', route);
      history.replaceState({ route }, '', url);
    }
  }

  let toastTimer;
  function toast(message) {
    const element = $('#toast');
    element.textContent = message;
    element.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => element.classList.remove('show'), 2400);
  }

  async function shareContent(title, text) {
    try {
      if (navigator.share) {
        await navigator.share({ title, text });
        return true;
      }
      if (navigator.clipboard) {
        await navigator.clipboard.writeText(text);
        toast('Copied. Paste it into the conversation you choose.');
        return true;
      }
      toast('Use your browser Share menu to send this message.');
      return false;
    } catch (error) {
      if (error && error.name !== 'AbortError') toast('Sharing did not open. Try again.');
      return false;
    }
  }

  function updateConsent() {
    $('#enterApp').disabled = !$('#adultConsent').checked || !$('#boundaryConsent').checked;
  }

  function resetCheckInFlow() {
    selectedState = null;
    selectedSupport = new Set();
    checkInCounted = false;
    $$('.choice-row[data-state], .choice-row[data-support]').forEach(row => row.classList.remove('selected'));
    $('#supportStep').hidden = true;
    $('#inlineSafety').hidden = true;
    $('#checkinSuccess').hidden = true;
    $('#saveCheckin').disabled = false;
    const privateChoice = $('input[name="shareChoice"][value="private"]');
    if (privateChoice) privateChoice.checked = true;
    updateCheckInButton();
  }

  $('#adultConsent').addEventListener('change', updateConsent);
  $('#boundaryConsent').addEventListener('change', updateConsent);
  $('#enterApp').addEventListener('click', () => {
    if ($('#enterApp').disabled) return;
    care.didCompleteWelcome = true;
    saveCare();
    routeTo('today');
  });

  $$('[data-route]').forEach(button => {
    button.addEventListener('click', () => routeTo(button.dataset.route));
  });

  $('#shareInvitation').addEventListener('click', () => {
    shareContent(
      'People of God — Circle Check',
      'How are you, really? Take a private check-in with People of God. Share only what you choose.\n\n' + window.location.href.split('?')[0]
    );
  });

  $$('.choice-row[data-state]').forEach(button => {
    button.addEventListener('click', () => {
      selectedState = button.dataset.state;
      checkInCounted = false;
      $('#checkinSuccess').hidden = true;
      $$('.choice-row[data-state]').forEach(row => row.classList.toggle('selected', row === button));
      $('#supportStep').hidden = false;
      $('#inlineSafety').hidden = selectedState !== 'unsafe';
      $('#saveCheckin').disabled = false;
      updateCheckInButton();
    });
  });

  $$('.choice-row[data-support]').forEach(button => {
    button.addEventListener('click', () => {
      const value = button.dataset.support;
      if (selectedSupport.has(value)) selectedSupport.delete(value);
      else selectedSupport.add(value);
      button.classList.toggle('selected', selectedSupport.has(value));
    });
  });

  function selectedShareChoice() {
    return $('input[name="shareChoice"]:checked').value;
  }

  function updateCheckInButton() {
    const labels = {
      private: 'Save private check-in',
      checked: 'Save and share that I checked in',
      request: 'Save and share my support request'
    };
    $('#saveCheckin').textContent = checkInCounted ? 'Check-in saved' : labels[selectedShareChoice()];
  }

  $$('input[name="shareChoice"]').forEach(input => input.addEventListener('change', updateCheckInButton));

  $('#saveCheckin').addEventListener('click', async () => {
    if (!selectedState || checkInCounted) return;
    const shareChoice = selectedShareChoice();
    if (shareChoice === 'request' && selectedSupport.size === 0) {
      toast('Choose the support you want to share—or keep the check-in private.');
      return;
    }

    recordCare('checkIns');
    checkInCounted = true;
    $('#saveCheckin').disabled = true;
    $('#checkinSuccess').hidden = false;
    updateCheckInButton();

    const outgoing = POGPrivacy.composeCheckInShare(shareChoice, [...selectedSupport]);
    if (outgoing) {
      await shareContent(outgoing.title, outgoing.text);
    }
  });

  $('#recordPrayer').addEventListener('click', () => {
    if (prayerCounted) return;
    recordCare('prayerActs');
    prayerCounted = true;
    $('#recordPrayer').textContent = 'Prayer moment recorded';
    $('#recordPrayer').disabled = true;
    $('#prayerSuccess').hidden = false;
  });

  $('#sharePrayer').addEventListener('click', async () => {
    const request = $('#prayerRequest').value.trim();
    const text = request
      ? `Please pray with me: ${request}`
      : 'I have an unspoken prayer request. Please pray with me.';
    await shareContent('People of God — Prayer Chain', text);
  });

  $('#sendWords').addEventListener('click', async () => {
    const words = $('#speakWords').value.trim();
    if (!words) {
      toast('Write the words you want to send first.');
      return;
    }
    const shared = await shareContent('People of God — Speak Life', words);
    if (shared && !wordsCounted) {
      recordCare('supportActs');
      wordsCounted = true;
      $('#speakSuccess').hidden = false;
    }
  });

  function showInstallSheet(message) {
    $('#installInstructions').textContent = message;
    $('#installSheet').hidden = false;
  }

  function closeInstallSheet() {
    $('#installSheet').hidden = true;
  }

  window.addEventListener('beforeinstallprompt', event => {
    event.preventDefault();
    deferredInstallPrompt = event;
  });

  $('#installButton').addEventListener('click', async () => {
    const isStandalone = matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
    if (isStandalone) {
      toast('People of God is already installed.');
      return;
    }

    if (deferredInstallPrompt) {
      deferredInstallPrompt.prompt();
      await deferredInstallPrompt.userChoice;
      deferredInstallPrompt = null;
      return;
    }

    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
    showInstallSheet(isIOS
      ? 'In Safari, tap Share, choose Add to Home Screen, then tap Add.'
      : 'In Chrome, open the ⋮ menu and choose Install app or Add to Home screen.');
  });

  $('.sheet-backdrop').addEventListener('click', closeInstallSheet);
  $('#closeInstall').addEventListener('click', closeInstallSheet);

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(() => {}));
  }

  const requestedRoute = new URLSearchParams(window.location.search).get('screen');
  renderProgress();
  routeTo(care.didCompleteWelcome && allowedRoutes.has(requestedRoute) ? requestedRoute : currentRoute, false);
  document.documentElement.dataset.appReady = 'true';
})();
