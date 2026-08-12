# Men of God Brand Staging

This folder is the handoff point for the approved Men of God identity and UI-glyph system created during concept development.

## MANDATORY RUNTIME REGISTRIES

Before placing, replacing, animating, resizing, or repurposing **any MOG asset**, read:

- `RUNTIME_ASSET_REGISTRY.json` — all previously uploaded runtime assets.
- `FEATURE_ASSET_REGISTRY.json` — new feature-family assets, currently Mirror Time and Bible.

The registries control:
- semantic meaning
- approved use
- prohibited use
- size tier (`micro`, `control`, `hero`, `lockup`, `system`)
- motion behavior
- whether the asset is canonical, secondary, conditional, derivative, or quarantined

**Filename appearance is not authority. The registries are authority.**

Examples:
- `art-ring-256.webp` is the canonical Legacy signet-ring treatment.
- `art-hourglass-*` is quarantined and must never be used for Legacy.
- `badge-rank-*` is Rank hardware and must not be used as generic Feed artwork.
- `crest-streak-*` is Streak artwork and must not be used as a generic Challenge icon.
- `crest-brotherhood-*` is Brotherhood artwork, not generic brand decoration.
- `mirror-time.svg` is the parent identity for private Mirror Time practice.
- `mirror-prayer.svg`, `mirror-forgive.svg`, and `mirror-mantra.svg` are semantic Mirror Time controls, not generic decoration.
- `bible-study.svg` belongs to Scripture/Bible reading contexts.
- PWA/app icons are install-system assets only, never normal in-app icons.
- Hero rasters must not be shrunk into tiny navigation glyphs.

If the canonical semantic glyph is missing from the runtime folder, source the approved glyph from the design system. **Do not invent a generic replacement just to finish the screen.**

## Identity assets
Canonical names:
- `identity/primary-mark.png`
- `identity/horizontal-wordmark.png`
- `identity/stacked-wordmark.png`
- `identity/monochrome-mark.png`
- `identity/app-icon.png`

## UI glyphs
Canonical names:
- `glyphs/faith.png`
- `glyphs/discipline.png`
- `glyphs/brotherhood.png`
- `glyphs/legacy.png`
- `glyphs/prayer.png`
- `glyphs/study.png`
- `glyphs/serve.png`
- `glyphs/challenge.png`
- `glyphs/streak.png`
- `glyphs/rank.png`
- `glyphs/verified.png`
- `glyphs/talents.png`

## Asset tiers
Use the least visually expensive asset that still communicates the concept correctly.

- **micro**: 16–28px inline glyph/status mark
- **control**: 32–72px detailed glyph/badge in an existing control or compact card
- **hero**: 96px+ rendered art used sparingly for a principal section or ceremonial moment
- **lockup**: wordmark/brand composition, never a button icon
- **system**: PWA/browser/install identity, not normal in-app content

Do not use a hero asset where a micro glyph belongs.

## Material masks
Every production-ready raster should have mask channels in `material-masks/<asset>/` where useful:
- `alpha-mask.png`
- `gold-mask.png`
- `dark-metal-mask.png`
- `specular-mask.png`
- `detail-mask.png`

Add hand-authored semantic masks for exact animation targets, e.g. `cracks-mask.png`, `engraving-mask.png`, `cross-mask.png`, `flame-mask.png`, `chevrons-mask.png`, `glyph-mask.png`, or `rim-mask.png`.

## Brand rule
The artwork is intended to feel physically manufactured: forged metal, blackened steel, antique gold, polished edges, engraving, seams and material wear. Motion should animate the material channels, not merely brighten or scale the whole image.

See `/AGENTS.md`, both runtime registries, `asset-manifest.json`, and `MATERIAL_MOTION.md` before implementation.
