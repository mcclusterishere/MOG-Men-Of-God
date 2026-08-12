# MOG Asset Integration Audit

Branch: `claude/mog-asset-integration-v2`. Asset integration and reskin only.

Tables are generated from `MOG.audit()` at runtime, not written by hand.
Regenerate by loading the app and calling `MOG.audit()` in the console.


## Branded concepts mounted through the registry

Every row was resolved by `assets/registry.js`. No component selects an asset
itself: markup declares `data-mog="concept:tier"` and the registry decides the
file, the material channel and the motion. There are no hardcoded asset paths
left in `index.html`.


| Concept | Tier | Runtime asset | Where it appears | Material channel | Motion |
|---|---|---|---|---|---|
| `bible-study` | micro | `assets/bible-study.svg` | Bible · header | — | none |
| `bible-study` | micro | `assets/bible-study.svg` | Today · Word card | — | none |
| `brotherhood` | control | `assets/crest-brotherhood-256.webp` | Brothers · chapter card | gold | sweep |
| `challenge` | hero | `assets/crest-breakthrough-640.webp` | Today · daily challenge | detail | sweep |
| `horizontal-wordmark` | lockup | `assets/lockup-horizontal-720.webp` | Today · install card | specular | sweep |
| `mantras` | micro | `assets/mirror-mantra.svg` | Today · Mirror Time · Mantras mode | — | none |
| `mirror-prayer` | micro | `assets/mirror-prayer.svg` | Mirror Time · live session | — | none |
| `mirror-time` | control | `assets/mirror-time.svg` | Me · private practice summary | — | none |
| `mirror-time` | control | `assets/mirror-time.svg` | Mirror Time · camera fallback | — | none |
| `mirror-time` | control | `assets/mirror-time.svg` | Today · Mirror Time hub | — | none |
| `prayer` | control | `assets/art-prayer-256.webp` | Today · Mirror Time · Prayer mode | — | none |
| `primary-mark` | control | `assets/mark-gold-256.webp` | Feed · brand watermark | gold | sweep |
| `primary-mark` | micro | `assets/mog-mark.svg` | Me · profile watermark | — | none |
| `primary-mark` | micro | `assets/mog-mark.svg` | Today · header | — | none |
| `rank` | control | `assets/badge-rank-256.webp` | Today · rank stat | gold | sweep |
| `self-forgiveness` | micro | `assets/mirror-forgive.svg` | Today · Mirror Time · Forgive mode | — | none |
| `streak` | control | `assets/crest-streak-256.webp` | Today · streak stat | emissive | pulse |
| `talents` | micro | `assets/talent.svg` | Challenges · Talents pill | — | none |
| `talents` | micro | `assets/talent.svg` | Today · Talents stat | — | none |
| `verified` | micro | `assets/verified.svg` | Brothers · verified name | — | sweep |
| `verified` | micro | `assets/verified.svg` | Feed · verified name | — | sweep |
| `verified` | micro | `assets/verified.svg` | Today · proof chip | — | sweep |
| `verified` | micro | `assets/verified.svg` | Today · verified name | — | sweep |

## Generic substitutes still present

MOG-owned concepts still standing on the pre-existing generic glyph, because no
approved micro-tier glyph exists. Declared in markup via `data-mog-generic` so
they cannot be quietly forgotten.


| Concept | Where | Blocked on |
|---|---|---|
| `challenge:micro` | Bottom nav · Challenges | Small Challenges nav glyph. The breakthrough crest is hero art, not a micro glyph. |
| `brotherhood:micro` | Bottom nav · Brothers | Small Brothers nav glyph. Do not shrink the brotherhood crest. |

## Manifest concepts with no runtime file

Approved in `asset-manifest.json`, absent from every branch, and currently
unmounted. No substitute was invented for any of them.


| Concept | Status |
|---|---|
| `faith` | No runtime file. The Today Word card now uses the approved `bible-study` glyph, so no Faith slot is rendered. |
| `discipline` | No runtime file. Streak and challenge art are explicitly not the Discipline glyph. |
| `serve` | No runtime file and no service surface in the app. |
| `prayer:micro` | Prayer artwork is control/hero tier. `mirror-prayer.svg` is a candidate but was authored for Mirror Time; promoting it is a brand decision. |

## Registered but not currently mounted

| Concept | Asset | Note |
|---|---|---|
| `secondary-brand-emblem` | `emblem-shield-128.webp` | Secondary. No surface currently calls for a shield. |
| `stacked-wordmark` | `lockup-stacked-960.webp` | Approved for splash/launch. The app has no launch surface; inventing one is a redesign, not a reskin. |
| `monochrome-mark` | `mark-silver-256.webp` | Approved low-contrast watermark. The profile watermark uses the canonical vector mark instead. |

## Withheld from the runtime on purpose

| Asset | Reason |
|---|---|
| `art-hourglass` | Quarantined. Legacy is canonically the forged signet ring. |
| `badge-creator` | Conditional. No explicit creator/founder product state is defined yet. |
| `app-icon` | System tier. PWA install identity only, never an in-app icon. |

## Mechanical controls left generic (allowed)

Close, share, reply, like, search, edit, add, back, and the Today/Feed/Me
navigation are ordinary mechanical actions with no MOG-owned semantic glyph in
the manifest, so they keep their existing symbols.


## Size tiers

| Tier | Rule |
|---|---|
| system | PWA/browser install identity. Never in-app content. |
| micro | 16-28px inline glyph or status mark. |
| control | 32-72px branded glyph inside an existing control or compact card. |
| hero | 96px+ art, used sparingly for a principal or ceremonial moment. |
| lockup | Brand wordmark composition. Never a button icon. |

`MOG.verifyTiers()` measures every mount after layout and reports anything
rendering outside its band. Current violations: **none**.

Vector marks are exempt from the px bands; they carry no resolution penalty.


During this pass the check caught ten violations, including a hero crest at 78px,
the legacy ring below its own tier floor, a 256px challenge crest rendering at
132px, and the brotherhood crest shrunk to a 22px inline accent inside a proof
chip. All are resolved.


## Known material gaps

- `crest-breakthrough` animates through `detail-mask`, an edge extraction covering
  22% of the frame. That is not crack geometry, so it takes one restrained sweep
  rather than a fracture pulse. A hand-authored `cracks-mask` is required first.

- `badge-rank` animates through `gold-mask`, covering chevrons, crown and rim
  together. Sequential chevron illumination needs a hand-authored `chevrons-mask`.

- `crest-streak` uses `emissive-mask`, reviewed: it isolates the flame and lit
  day-marks and excludes the calendar body, so a pulse is sanctioned.

- `crest-brotherhood` uses `gold-mask`, reviewed: it excludes the hands, matching
  the requirement that hands stay physically stable.

