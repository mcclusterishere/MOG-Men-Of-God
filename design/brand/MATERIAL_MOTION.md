# Material Motion System

The Men of God interface should behave like a physical object made from blackened steel, gunmetal, antique gold and engraved material surfaces.

## Core rule
Do not animate a raster asset as one flat bitmap when the intended effect belongs to a texture channel.

A pulse, sheen, heat, crack glow or electrical travel effect should be constrained by a mask that represents the physical part being animated.

## Layer model
Recommended rendering stack:

```text
asset-shell
  base artwork
  dark-metal response layer
  gold response layer
  semantic/detail response layer
  specular highlight layer
  UI content / labels
```

All response layers should share the exact geometry of the base asset and use masks.

## DOM/CSS pattern

```css
.material-asset {
  position: relative;
  isolation: isolate;
}

.material-asset > .base {
  display: block;
  width: 100%;
}

.material-asset > .fx {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background: linear-gradient(110deg, transparent 20%, rgba(255,221,136,.85) 48%, transparent 70%);
  background-size: 220% 100%;
  -webkit-mask: var(--asset-mask) center / contain no-repeat;
  mask: var(--asset-mask) center / contain no-repeat;
  mix-blend-mode: screen;
}

.material-asset[data-motion="pulse"] > .fx {
  animation: materialPulse 2.2s ease-in-out infinite;
}

.material-asset[data-motion="sweep"] > .fx {
  animation: materialSweep 2.8s cubic-bezier(.2,.7,.2,1) 1;
}

@keyframes materialPulse {
  0%,100% { opacity:.08; filter:brightness(.85); }
  50% { opacity:.75; filter:brightness(1.35); }
}

@keyframes materialSweep {
  from { background-position:180% 0; opacity:0; }
  20% { opacity:.9; }
  to { background-position:-80% 0; opacity:0; }
}

@media (prefers-reduced-motion: reduce) {
  .material-asset > .fx { animation:none !important; }
}
```

## Exact crack-only example
To make only cracks pulse:

```html
<div class="material-asset" data-motion="pulse" style="--asset-mask:url('./cracks-mask.png')">
  <img class="base" src="./tile.png" alt="">
  <span class="fx" aria-hidden="true"></span>
</div>
```

The critical requirement is that `cracks-mask.png` contain white only where the cracks exist and black/transparent everywhere else. The base tile never pulses.

## Mask quality levels

### Staging masks
Automatically derived masks can help prototype:
- `gold-mask`
- `dark-metal-mask`
- `specular-mask`
- `detail-mask`

### Production semantic masks
Hand-author whenever exact geometry matters:
- cracks
- engraving
- glyph
- cross
- chevrons
- flame
- rim
- inset
- seams
- Talent core

Do not call `detail-mask` a crack mask unless it has been visually reviewed and corrected.

## Motion by glyph

### Faith
Gold edge response may sweep once through the cross and halo. Keep the steel body stable.

### Discipline
Allow controlled energy to travel through chain fractures or sword edges. Avoid full-badge pulsing.

### Brotherhood
A small metallic catch-light may travel across cuffs / insignia. Hands should remain natural and stable.

### Legacy
Signet ring should behave like polished jewelry: directional edge glint and subtle engraved-face shimmer only.

### Prayer
Use extremely restrained light response. No theatrical glow around hands.

### Study
Page-edge gold and pen hardware can catch light. Do not animate fake page movement unless intentionally interactive.

### Serve
Water can have its own motion layer while basin and hands remain physically stable.

### Challenge
Fracture/crack channels are ideal for a pulse that runs through the broken chain. Debris should not constantly bounce.

### Streak
Flame/emissive channel may travel. Calendar body should stay stable.

### Rank
Chevrons illuminate sequentially according to rank/progression state.

### Verified
One short specular sweep after verification is enough. Verification should feel authoritative, not gamified.

### Talents
Currency can use a rotating rim sheen or core-glyph catch-light. Avoid slot-machine animation.

## Interaction physics
Pressed surfaces should feel mechanically depressed into a recessed well rather than cartoon-scaled. Use small translate/depth, shadow inversion and specular changes instead of springy bounce.

## Performance
Prefer CSS/SVG masks for most UI. Reserve WebGL/canvas shaders for hero moments or surfaces where roughness/specular interaction clearly improves the experience.
