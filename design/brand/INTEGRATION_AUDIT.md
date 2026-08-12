# MOG Asset Integration Audit

Branch: `claude/mog-asset-integration-v2` — asset integration / reskin only.

Tables below are generated from `MOG.audit()` at runtime, not written by hand.
Regenerate by loading the app and calling `MOG.audit()` in the console.


## Branded concepts mounted through the registry

Every row was resolved by `assets/registry.js`. No component selects an asset
itself: markup declares `data-mog="concept:tier"` and the registry decides which
file, which material channel, and which motion.


| Concept | Tier | Runtime asset | Where it appears | Material channel | Motion |
|---|---|---|---|---|---|
| `brotherhood` | control | `assets/crest-brotherhood-256.webp` | Brothers · chapter card | gold | sweep |
| `challenge` | hero | `assets/crest-breakthrough-640.webp` | Today · daily challenge | detail | sweep |
| `horizontal-wordmark` | lockup | `assets/lockup-horizontal-720.webp` | Today · install card | specular | sweep |
| `legacy` | control | `assets/art-ring-256.webp` | Me · founding brother | specular | sweep |
| `primary-mark` | control | `assets/mark-gold-256.webp` | Feed · brand watermark | gold | sweep |
| `primary-mark` | micro | `assets/mog-mark.svg` | Me · profile watermark | — | none |
| `primary-mark` | micro | `assets/mog-mark.svg` | Today · header | — | none |
| `rank` | control | `assets/badge-rank-256.webp` | Today · rank stat | gold | sweep |
| `streak` | hero | `assets/crest-streak-640.webp` | Challenges · 7 Days of Iron | emissive | pulse |
| `streak` | control | `assets/crest-streak-256.webp` | Me · streak stat | emissive | pulse |
| `streak` | control | `assets/crest-streak-256.webp` | Today · streak stat | emissive | pulse |
| `talents` | micro | `assets/talent.svg` | Challenges · Talents pill | — | none |
| `talents` | micro | `assets/talent.svg` | Me · Talents stat | — | none |
| `talents` | micro | `assets/talent.svg` | Today · Talents stat | — | none |
| `verified` | micro | `assets/verified.svg` | Me · proofs stat | — | sweep |
| `verified` | micro | `assets/verified.svg` | Today · proof chip | — | sweep |
| `verified` | micro | `assets/verified.svg` | verified name | — | sweep |
| `verified` | micro | `assets/verified.svg` | verified name | — | sweep |
| `verified` | micro | `assets/verified.svg` | verified name | — | sweep |

## Slots awaiting an approved asset

Rendered as a neutral pending marker. No substitute glyph was invented, and no
lookalike asset was promoted into the slot.


| Concept | Where | Why it is empty |
|---|---|---|
| `faith:micro` | Today · Word card | Faith/Word/devotional glyph. No runtime file in any branch. |

## Generic substitutes still present

MOG-owned concepts still standing on the pre-existing generic glyph because the
approved micro-tier glyph does not exist. Declared in markup via
`data-mog-generic` so they cannot be quietly forgotten.


| Concept | Where | Blocked on |
|---|---|---|
| `challenge:micro` | Bottom nav · Challenges | Small Challenges nav glyph. The breakthrough crest is hero art, not a micro glyph. |
| `brotherhood:micro` | Bottom nav · Brothers | Small Brothers nav glyph. Do not shrink the brotherhood crest. |

## Registered but not yet mounted

Approved assets the registry governs that have no surface in the current app.


| Concept | Asset | Note |
|---|---|---|
| `study` | `assets/bible-study.svg` | Fills a manifest concept that previously had no runtime file. No study surface exists yet. |
| `prayer` | `assets/art-prayer-256/512.webp` | Approved, but the Today Word module is scripture, not prayer content, so mounting it there is disallowed. |
| `mirror-time`, `mirror-prayer`, `mirror-forgive`, `mirror-mantra` | `assets/mirror-*.svg` | Landed with the in-flight Mirror Time feature. See below. |
| `secondary-brand-emblem` | `assets/emblem-shield-128.webp` | Secondary. No surface currently calls for a shield. |
| `stacked-wordmark` | `assets/lockup-stacked-960.webp` | Approved for splash/launch. The app has no launch surface, and inventing one is a redesign, not a reskin. |

## Withheld from the runtime on purpose

| Asset | Reason |
|---|---|
| `art-hourglass` | Quarantined. Legacy is canonically the forged signet ring. |
| `badge-creator` | Conditional. No explicit creator/founder product state is defined yet. |
| `app-icon` | System tier. PWA install identity only, never an in-app icon. |

## In-flight feature on this branch

`feature-mirror-bible.js` / `.css` are present but not referenced by any script
tag, and none of the DOM they query (`#mirrorExperience`, `#bibleReader`,
`#todayWordText`, `#dailyWordCard`) exists in `index.html`. They are staged work,
left untouched by this pass. Wiring them would add a sixth screen, which is a
redesign rather than a reskin.

When that feature is wired, it should stop selecting icons from its own hardcoded
`MIRROR` map (`icon:'assets/mirror-prayer.svg'`) and resolve through
`MOG.resolve('mirror-prayer', 'micro')` instead, so the registry stays the single
authority.


## Mechanical controls left generic (allowed)

Close, share, reply, like, search, edit, add, and the Today/Feed/Me navigation are
ordinary mechanical actions with no MOG-owned semantic glyph in the manifest, so
they keep their existing symbols.


## Size tiers

| Tier | Rule |
|---|---|
| system | PWA/browser install identity. Never in-app content. |
| micro | 16-28px inline glyph or status mark. |
| control | 32-72px branded glyph inside an existing control or compact card. |
| hero | 96px+ art, used sparingly for a principal or ceremonial moment. |
| lockup | Brand wordmark composition. Never a button icon. |

`MOG.verifyTiers()` measures every mount after layout and reports anything that
renders outside its band. Current violations: **none**.

Vector marks are exempt from the px bands; they carry no resolution penalty.


## Known material gaps

- `crest-breakthrough` animates through `detail-mask`, an edge extraction covering
  22% of the frame. That is not crack geometry, so it takes one restrained sweep
  rather than a fracture pulse. A hand-authored `cracks-mask` is required before
  the intended crack-only pulse can ship.

- `badge-rank` animates through `gold-mask`, which covers chevrons, crown and rim
  together. Sequential chevron illumination needs a hand-authored `chevrons-mask`.

- `crest-streak` uses `emissive-mask`, reviewed: it isolates the flame and the lit
  day-marks and excludes the calendar body, so a pulse is sanctioned.

- `crest-brotherhood` uses `gold-mask`, reviewed: it excludes the hands, matching
  the requirement that hands stay physically stable.

