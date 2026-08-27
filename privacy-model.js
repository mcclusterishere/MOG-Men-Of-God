(function exposePrivacyModel(root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.POGPrivacy = api;
}(typeof globalThis !== 'undefined' ? globalThis : this, function buildPrivacyModel() {
  'use strict';

  const supportLabels = Object.freeze({
    prayer: 'pray for me',
    call: 'call me',
    listen: 'listen without trying to fix it',
    tomorrow: 'check on me tomorrow',
    practical: 'help me with something practical',
    professional: 'help me find professional support'
  });

  function nonNegativeInteger(value) {
    return Math.max(0, Math.trunc(Number(value) || 0));
  }

  function sanitizeCareForStorage(value = {}) {
    return {
      checkIns: nonNegativeInteger(value.checkIns),
      prayerActs: nonNegativeInteger(value.prayerActs),
      supportActs: nonNegativeInteger(value.supportActs),
      lastActivityAt: typeof value.lastActivityAt === 'string' ? value.lastActivityAt : null,
      didCompleteWelcome: value.didCompleteWelcome === true
    };
  }

  function composeCheckInShare(choice, supportValues = []) {
    if (choice === 'checked') {
      return {
        title: 'People of God — Circle Check',
        text: 'I checked in today. No details shared—just letting my circle know I showed up.'
      };
    }

    if (choice === 'request') {
      const requests = [...new Set(supportValues)]
        .map(value => supportLabels[value])
        .filter(Boolean);
      if (requests.length === 0) return null;
      return {
        title: 'People of God — Support Request',
        text: `I checked in. What would help right now: ${requests.join(', ')}.`
      };
    }

    return null;
  }

  return Object.freeze({ sanitizeCareForStorage, composeCheckInShare });
}));
