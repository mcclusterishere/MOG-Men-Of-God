# MOG Asset Integration Audit

Branch: `claude/mog-asset-integration-v2`. Asset integration and reskin only.

Tables are generated from `MOG.audit()` at runtime unless marked as a user-confirmed design-system correction. `design/brand/ASSET_IDENTITY_CORRECTIONS.json` has highest semantic precedence over historical filenames and older audit language.

## User-confirmed design-system corrections

| Existing runtime file | Canonical concept | Correction |
|---|---|---|
| `assets/emblem-shield-128.webp` | `faith` | The forged MOG shield/monogram with central cross and gold star/compass point is **FAITH**, not a generic secondary emblem. |
| `assets/badge-verified-128.webp` / `assets/badge-verified-256.webp` | `verified` | The scalloped black-and-gold seal with dimensional checkmark is **VERIFIED**. |
| `assets/badge-creator-256.webp` | `talents` | The circular crest containing headphones, studio microphone, paint brush, camera lens and piano keys is **TALENTS**, not creator/founder status. `assets/talent.svg` remains the compact inline Talents mark. |

## Branded concepts mounted through the registry

Every row is resolved by `assets/registry.js`. No component selects an asset itself: markup declares `data-mog="concept:tier"` and the registry decides the file, material channel and motion.

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

| Concept | Where | Blocked on |
|---|---|---|
| `challenge:micro` | Bottom nav · Challenges | Small Challenges nav glyph. The breakthrough crest is hero art, not a micro glyph. |
| `brotherhood:micro` | Bottom nav · Brothers | Small Brothers nav glyph. Do not shrink the brotherhood crest. |

## Manifest concepts with no runtime file

| Concept | Status |
|---|---|
| `discipline` | No confirmed runtime file yet. Streak and challenge art are explicitly not the Discipline glyph. |
| `serve` | No confirmed runtime file yet and no service surface is currently mounted. |
| `prayer:micro` | Prayer artwork is control/hero tier. `mirror-prayer.svg` is specific to Mirror Time until the brand canon says otherwise. |

## Confirmed assets registered but not currently mounted

| Concept | Asset | Note |
|---|---|---|
| `faith` | `assets/emblem-shield-128.webp` | Canonical user-confirmed Faith glyph; available to replace incorrect/missing Faith treatment when the corresponding UI mount is wired. |
| `talents` | `assets/badge-creator-256.webp` | Canonical user-confirmed detailed Talents crest; `talent.svg` remains the micro treatment already mounted in balances/rewards. |
| `stacked-wordmark` | `lockup-stacked-960.webp` | Approved for splash/launch. |
| `monochrome-mark` | `mark-silver-256.webp` | Approved low-contrast watermark. |

## Withheld from the runtime on purpose

| Asset | Reason |
|---|---|
| `art-hourglass` | Quarantined. Legacy is canonically the forged signet ring. |
| `app-icon` | System tier. PWA install identity only, never an in-app icon. |

## Mechanical controls left generic (allowed)

Close, share, reply, like, search, edit, add, and back are ordinary mechanical actions with no MOG-owned semantic glyph in the current canon.

## Size tiers

| Tier | Rule |
|---|---|
| system | PWA/browser install identity. Never in-app content. |
| micro | 16-28px inline glyph or status mark. |
| control | 32-72px branded glyph inside an existing control or compact card. |
| hero | 96px+ art used sparingly for a principal section or ceremonial moment. |
| lockup | Brand wordmark composition. Never a button icon. |

`MOG.verifyTiers()` measures mounts after layout and reports anything rendering outside its allowed band. Vector marks are exempt from raster resolution constraints.

## Known material gaps

- `crest-breakthrough` still needs a hand-authored `cracks-mask` for true fracture emission.
- `badge-rank` still needs a hand-authored `chevrons-mask` for sequential rank illumination.
- `crest-streak` uses a reviewed emissive mask that isolates the flame/lit day marks.
- `crest-brotherhood` uses a reviewed gold mask that excludes the hands.
- The newly corrected detailed Talents crest should not receive semantic motion until its own gold/specular/detail masks are reviewed.
