# Men of God Agent Handoff

## Mission
Men of God (MOG) is an invite-only, cross-church fraternity/social platform for Christian men. It is not a replacement church. The product should connect men across churches around faith, discipline, brotherhood, service, study, prayer, challenges, streaks, rank, and earned Talents.

The product is mobile-first and PWA-first. It should feel like a real phone app, not a responsive marketing site.

## Non-negotiable visual direction
The interface must feel physically manufactured from metal.

Do not interpret this as "dark mode with gold accents." The system language is:
- blackened steel
- forged gunmetal
- antique/forged gold
- bone/platinum text
- machined grooves
- engraved labels
- recessed wells
- stamped seals
- polished edges
- controlled scratches, patina, seams, cracks, and material grain

Avoid generic glassmorphism, neon, SaaS dashboards, random gradients, emoji-as-icons, and AI-looking generic cards.

## Canonical identity
Brand name: **MEN OF GOD**
Short mark: **MOG**
Brand idea: **One brotherhood. Many churches. One God.**
Core values: **Faith. Discipline. Brotherhood.**

Do not redraw or casually reinterpret the supplied identity assets. Use supplied masters as the source of truth until a deliberate brand revision is approved.

## Canonical asset inventory
Core identity:
- `primary-mark`
- `horizontal-wordmark`
- `stacked-wordmark`
- `monochrome-mark`
- `app-icon`

UI glyphs:
- `faith`
- `discipline`
- `brotherhood`
- `legacy`
- `prayer`
- `study`
- `serve`
- `challenge`
- `streak`
- `rank`
- `verified`
- `talents`

The current approved Legacy concept is the forged signet ring. Do not use lions, hourglasses, globes, or over-composed heraldic scenes for Legacy.

## Spatial material architecture
The long-term design target is not merely a "3D website." It is a **physical digital interface**: normal HTML remains the accessible/product layer while selected assets behave like real manufactured objects with physically plausible light, depth, roughness, reflections, and material-state transitions.

Use a hybrid format strategy rather than forcing every asset into one format:

### SVG
Use for:
- canonical flat logos and wordmarks
- line/outline glyphs
- scalable UI symbols
- clip paths and semantic masks
- animated strokes, engraving paths, crack paths, edge glows

SVG elements should be logically grouped and named so individual material regions can animate independently.

### glTF / GLB
Use for objects that should physically exist in the interface:
- Talents coin
- Legacy signet ring
- rank and verification hardware
- collectible seals/badges
- selected buttons or hero objects
- future chapter artifacts

Preferred production materials are physically based rendering (PBR):
- baseColor
- metallic
- roughness
- normal
- ambient occlusion
- emissive where justified

A gold object should glisten because virtual light moves across actual surface normals and material roughness, not because a flat image's opacity pulses.

### Gaussian splats
Do **not** use Gaussian splats for ordinary glyphs, buttons, badges, or compact product UI. Reserve splats for photoreal captured spaces/objects where their strengths matter, such as a future chapter room, gym, church, studio, or environmental experience.

### WebGL / WebGPU presentation layer
The core application should remain HTML/CSS/DOM for speed, accessibility, text, forms, feed content, and resilient fallbacks. A WebGL/WebGPU layer may sit above or within specific interface regions to render selected GLB assets and physically responsive materials.

Do not turn every screen into a canvas. 3D earns its place only where it improves the physical illusion or interaction.

### WebXR future path
When a 3D object is authored cleanly as GLB/glTF, preserve a path for optional spatial presentation later. The same Talent coin or rank object should be capable of appearing in normal mobile UI today and a future AR/VR scene without being rebuilt from scratch.

## Material channel architecture
The raster artwork must not be treated as a single flat image when motion is applied.

Animation should be able to move through a MATERIAL CHANNEL, not pulse the entire asset. Example: if a tile contains cracks, only the cracks may glow/pulse while the rest of the tile remains physically stable.

Each production asset should be modeled as layered channels:
1. `base` - canonical rendered artwork
2. `alpha` - silhouette
3. `gold` - forged-gold regions
4. `dark-metal` - gunmetal/blackened-steel regions
5. `specular` - edges and polished highlights
6. `detail` - scratches, cracks, engraving, seams, micro-detail
7. optional semantic masks such as `cracks`, `engraving`, `cross`, `glyph`, `rim`, `talent-core`

For true 3D assets, semantic masks can be implemented as separate material assignments, UV regions, vertex groups, emissive maps, or named mesh primitives instead of raster masks.

Never fake a material animation by changing opacity/brightness of the entire PNG unless the motion is intentionally global.

### Example interaction language
- verified badge: one restrained gold specular sweep, then settle
- streak: heat travels only through flame/emissive channels
- Talent: rim catches light while the core glyph remains readable; optional small real 3D coin rotation
- challenge: energy may travel through fracture/detail channels
- rank: chevrons illuminate sequentially, not the whole badge
- button/tile: crack mask can pulse from beneath while the base metal remains static
- pressed control: surface appears to depress into a machined well; avoid scale-bounce toy motion
- gold bar / metallic object: drive a real moving key light or environment reflection across a GLB/PBR material rather than animating a flat shine overlay

### Recommended implementation
For DOM/CSS implementation, stack layers in an isolated wrapper. Place animated overlays above the base and mask them with the relevant grayscale/alpha channel via CSS `mask-image` / `-webkit-mask-image` or SVG masks.

For richer material response, use WebGL/WebGPU only where it earns its complexity. A compact shader/material system may combine base texture, metallic/roughness/normal information, environment lighting, and semantic masks so light affects only intended material regions.

Respect `prefers-reduced-motion`, battery constraints, and low-power devices. Always provide a static/material-safe fallback.

## Asset production rules going forward
Prefer source assets that can support interactive material treatment:
- SVG for graphic marks/glyphs
- GLB/glTF for physical 3D objects
- PNG/WebP only for raster masters, photography, or rendered fallbacks

When building a GLB asset, preserve named materials/meshes for interactive regions, e.g.:
- `gold_trim`
- `blackened_steel`
- `engraving`
- `cracks`
- `emissive_core`
- `rim`

Do not bake all visual information into one flattened texture if the region is expected to animate independently later.

## Generated staging masks
The design staging pack includes automatically derived masks for rapid prototyping:
- alpha-mask
- gold-mask
- dark-metal-mask
- specular-mask
- detail-mask

These are PROVISIONAL. `detail-mask` is a high-frequency texture extraction and is not guaranteed to isolate only cracks. For production, hand-author semantic masks when an interaction requires exact geometry such as crack-only illumination.

Do not claim a derived mask is semantically exact unless it has been reviewed.

## UI direction
Reference behavior is closer to Apple Fitness + FitPlan discipline, Orb-style social restraint, TikTok feed immediacy, and BFF-like brother/group energy. Do not clone those products.

Primary navigation remains intentionally small:
- Today
- Feed
- Challenges
- Brothers
- Me

Today should be a command center, not a dashboard dump: one Word, one principal challenge, streak, Talents, and the next action.

Feed should support visual proof posts and concise discussions without becoming a noisy general-purpose social network.

## Membership direction
There are only two intended doors:
1. founding/inaugural group-chat access
2. invitation by an existing Brother, followed by approval

The approval ritual/workflow is intentionally not finalized. Model it as a state machine so approval logic can be replaced later without rewriting membership identity.

Suggested states: `invited -> candidate -> pending_approval -> active -> suspended/removed`.

## Talents
Talents are earned reputation/reward points, not cash and not purchasable currency.

Use an append-only ledger. Do not store only a mutable balance. Derive balance from ledger entries.

Potential unlock classes:
- status/rank
- access/challenges/mentorship
- approved discounts/rewards later

Do not make monetary redemption assumptions without explicit product/legal approval.

## Integration boundary with HERE
Men of God remains its own product and data domain. HERE remains the commerce/platform authority.

Do not merge MOG databases into HERE or let MOG directly rewrite HERE ledgers/prices.

Future integration should be narrow:
- read approved catalog/offer data
- deep-link to approved HERE checkout/payment flows
- expose platform/founder profile content intentionally

MOG social identity, membership, challenge proofs, Talents, and discussion data stay within MOG.

## Work protocol for Claude
Before changing the visual system:
1. inspect `design/brand/`
2. use the asset manifest
3. preserve canonical files
4. stage derivatives separately
5. show a visual comp before broad UI rewrites when changing material language

When implementing assets, do not substitute emoji, Lucide/FontAwesome icons, or generic symbols for supplied MOG glyphs.

When a required semantic material mask is missing, create it as a separate derivative file and document how it was produced. Never destructively overwrite the source artwork.

When introducing 3D, preserve the DOM application's behavior first. Treat 3D as a progressive enhancement layer, not a reason to rewrite functioning product architecture.
