# Men of God Brand Staging

This folder is the handoff point for the approved Men of God identity and UI-glyph system created during concept development.

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

## Material masks
Every production-ready raster should have mask channels in `material-masks/<asset>/` where useful:
- `alpha-mask.png`
- `gold-mask.png`
- `dark-metal-mask.png`
- `specular-mask.png`
- `detail-mask.png`

Add hand-authored semantic masks for exact animation targets, e.g. `cracks-mask.png`, `engraving-mask.png`, `cross-mask.png`, or `rim-mask.png`.

## Brand rule
The artwork is intended to feel physically manufactured: forged metal, blackened steel, antique gold, polished edges, engraving, seams and material wear. Motion should animate the material channels, not merely brighten or scale the whole image.

See `/AGENTS.md` and `MATERIAL_MOTION.md` before implementation.
