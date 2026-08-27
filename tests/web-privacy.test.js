const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const { sanitizeCareForStorage, composeCheckInShare } = require('../privacy-model.js');

test('browser persistence drops every sensitive check-in field', () => {
  const stored = sanitizeCareForStorage({
    checkIns: 2,
    prayerActs: 3,
    supportActs: 4,
    lastActivityAt: '2026-08-27T12:00:00.000Z',
    didCompleteWelcome: true,
    feeling: 'unsafe',
    state: 'carryingSomething',
    selectedSupport: ['professional', 'call'],
    prayerRequest: 'private words',
    affirmation: 'private words'
  });

  assert.deepEqual(Object.keys(stored).sort(), [
    'checkIns',
    'didCompleteWelcome',
    'lastActivityAt',
    'prayerActs',
    'supportActs'
  ]);
  assert.equal(JSON.stringify(stored).includes('unsafe'), false);
  assert.equal(JSON.stringify(stored).includes('private words'), false);
  assert.equal(JSON.stringify(stored).includes('professional'), false);
});

test('private check-ins produce no outgoing share payload', () => {
  assert.equal(composeCheckInShare('private', ['call']), null);
});

test('checked-in share contains no feeling or support detail', () => {
  const outgoing = composeCheckInShare('checked', ['professional', 'call']);
  assert.match(outgoing.text, /checked in today/i);
  assert.doesNotMatch(outgoing.text, /professional|call|feeling|mood|unsafe/i);
});

test('support request shares only explicitly selected allowlisted help', () => {
  const outgoing = composeCheckInShare('request', ['call', 'professional', 'unknown', 'call']);
  assert.match(outgoing.text, /call me/);
  assert.match(outgoing.text, /professional support/);
  assert.doesNotMatch(outgoing.text, /unknown|feeling|mood|unsafe/i);
});

test('PWA shell references every required install asset', () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.webmanifest'), 'utf8'));
  assert.equal(manifest.name, 'People of God');
  assert.equal(manifest.display, 'standalone');
  for (const icon of manifest.icons) {
    assert.equal(fs.existsSync(path.join(root, icon.src)), true, `missing ${icon.src}`);
  }

  const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
  assert.match(html, /manifest\.webmanifest/);
  assert.match(html, /privacy-model\.js/);
  assert.match(html, /app\.js/);
});
