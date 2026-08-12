# Mirror Time + Bible — Product Contract

## Mirror Time
Mirror Time is the private inner-work layer of Men of God. The front camera acts as a mirror; it is not a recording feature.

### Privacy contract
- Camera is requested only after the member deliberately opens a Mirror Time practice.
- No video or audio is recorded, uploaded, or attached to Brotherhood posts.
- Only a local completion event is stored: practice type, optional mantra category, and timestamp.
- Mirror Time completion is never treated as social proof.

### Prayer
The member looks himself in the eyes and speaks to God. The first implementation is a guided sequence with an explicit Amen ending. `art-prayer-256.webp` is entry artwork; the live camera remains visually dominant during the practice.

### Forgive Yourself
Self-forgiveness with accountability, not denial. The sequence moves through acknowledgment, responsibility, release of shame, forgiveness of the person in the mirror, and repair/forward motion.

### Mantras
Spoken affirmations are grouped into **Self**, **Family**, and **Relationships**. The canonical first Self mantra is **I AM ENOUGH.**

## Bible
The Bible is a secondary product screen opened from Today’s Word so the five-tab primary navigation remains intact.

Reader requirements implemented in this pass:
- Daily Word
- full book/chapter/verse reader
- translation and language selection
- jump-to-reference
- local verse saving
- remember last translation/book/chapter

The first runtime adapter is GetBible API v2. The app loads translation metadata, the selected translation’s book map, chapter map, and complete chapter JSON. Translation/license metadata from the provider is shown in the UI. Provider failure must not break the rest of MOG.

## Asset semantics
| Asset | Meaning | Tier | Use |
| --- | --- | --- | --- |
| `assets/mirror-time.svg` | Mirror Time parent identity | control | Today hub, private-practice summary |
| `assets/mirror-prayer.svg` | Prayer inside Mirror Time | micro/control | live Prayer session |
| `assets/mirror-forgive.svg` | self-forgiveness | micro/control | Forgive Yourself entry/session |
| `assets/mirror-mantra.svg` | spoken mantra / affirmation | micro/control | Mantras entry/session |
| `assets/bible-study.svg` | Bible / Scripture reader | micro/control | Today’s Word, Bible screen |
| `assets/art-prayer-256.webp` | Prayer rendered artwork | control | Prayer entry art only; never cover the face during Mirror Time |
| `assets/crest-streak-256.webp` | streak | control | streak stat / continuity |
| `assets/badge-rank-128.webp` | rank | micro | rank stat |
| `assets/crest-breakthrough-256.webp` | challenge | control | Daily Challenge |
| `assets/crest-brotherhood-256.webp` | Brotherhood | control | Brotherhood/chapter context |

Do not use a feature asset as decoration outside its semantic meaning.
