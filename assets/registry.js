/* ==========================================================================
   MOG RUNTIME ASSET REGISTRY
   --------------------------------------------------------------------------
   The single authority that maps a PRODUCT CONCEPT to an exact asset file.

   No component may choose an asset ad hoc. Markup declares a concept and a
   size tier:

       <span data-mog="challenge:hero"></span>

   and this module resolves it to the approved file, the material channel
   mask, and the sanctioned motion. Changing what a concept looks like is a
   change to this file, never to a component.

   Source of truth: design/brand/asset-manifest.json (semantics)
                    design/brand/RUNTIME_ASSET_REGISTRY.json (runtime labels)
                    AGENTS.md (usage law)

   Rule that governs the gaps: if a concept has no approved runtime file, we
   render a documented, visually neutral placeholder and report it. We never
   invent a substitute and never promote a lookalike asset into the slot.
   ========================================================================== */

const MOG = (() => {
  const A = 'assets/';
  const M = 'assets/masks/';

  /* Size tiers. A hero raster must never be shrunk into a navigation glyph. */
  const TIERS = {
    system: 'PWA/browser install identity. Never in-app content.',
    micro: '16-28px inline glyph or status mark.',
    control: '32-72px branded glyph inside an existing control or compact card.',
    hero: '96px+ art, used sparingly for a principal or ceremonial moment.',
    lockup: 'Brand wordmark composition. Never a button icon.'
  };

  /* Concept -> tier -> approved asset.
     `mask` names the material channel that may animate; `motion` names the
     only sanctioned behaviour. Anything absent here animates nothing. */
  const CONCEPTS = {
    verified: {
      micro: { file: A + 'verified.svg', status: 'canonical', scalable: true, motion: 'sweep' },
      control: {
        file: A + 'badge-verified-256.webp', status: 'approved-runtime',
        mask: M + 'badge-verified-256/specular-mask.png', channel: 'specular', motion: 'sweep'
      }
    },
    talents: {
      micro: { file: A + 'talent.svg', status: 'canonical', scalable: true, motion: 'none' }
    },
    rank: {
      micro: {
        file: A + 'badge-rank-128.webp', status: 'approved-runtime',
        mask: M + 'badge-rank-128/gold-mask.png', channel: 'gold', motion: 'sweep'
      },
      control: {
        file: A + 'badge-rank-256.webp', status: 'approved-runtime',
        mask: M + 'badge-rank-256/gold-mask.png', channel: 'gold', motion: 'sweep'
      },
      hero: { file: A + 'badge-rank-512.webp', status: 'approved-runtime', motion: 'none' }
    },
    streak: {
      control: {
        file: A + 'crest-streak-256.webp', status: 'approved-runtime',
        mask: M + 'crest-streak-256/emissive-mask.png', channel: 'emissive', motion: 'pulse'
      },
      hero: {
        file: A + 'crest-streak-640.webp', status: 'approved-runtime',
        mask: M + 'crest-streak-640/emissive-mask.png', channel: 'emissive', motion: 'pulse'
      }
    },
    challenge: {
      control: { file: A + 'crest-breakthrough-256.webp', status: 'approved-derivative', motion: 'none' },
      /* detail-mask is an edge extraction covering 22% of the frame, not crack
         geometry. A continuous pulse through it over-lights the whole crest, so
         this takes one restrained sweep instead. A true crack pulse needs a
         hand-authored cracks-mask; tracked as a gap in the audit. */
      hero: {
        file: A + 'crest-breakthrough-640.webp', status: 'approved-derivative',
        mask: M + 'crest-breakthrough-640/detail-mask.png', channel: 'detail', motion: 'sweep',
        gap: 'Awaiting hand-authored cracks-mask for true fracture pulse.'
      }
    },
    brotherhood: {
      control: {
        file: A + 'crest-brotherhood-256.webp', status: 'approved-runtime',
        mask: M + 'crest-brotherhood-256/gold-mask.png', channel: 'gold', motion: 'sweep'
      },
      hero: {
        file: A + 'crest-brotherhood-512.webp', status: 'approved-runtime',
        mask: M + 'crest-brotherhood-512/gold-mask.png', channel: 'gold', motion: 'sweep'
      }
    },
    legacy: {
      control: {
        file: A + 'art-ring-256.webp', status: 'canonical',
        mask: M + 'art-ring-256/specular-mask.png', channel: 'specular', motion: 'sweep'
      }
    },
    prayer: {
      control: { file: A + 'art-prayer-256.webp', status: 'approved-runtime', motion: 'none' },
      hero: { file: A + 'art-prayer-512.webp', status: 'approved-runtime', motion: 'none' }
    },
    'primary-mark': {
      micro: { file: A + 'mog-mark.svg', status: 'canonical', scalable: true, motion: 'none' },
      control: {
        file: A + 'mark-gold-256.webp', status: 'approved-runtime',
        mask: M + 'mark-gold-256/gold-mask.png', channel: 'gold', motion: 'sweep'
      }
    },
    'monochrome-mark': {
      control: { file: A + 'mark-silver-256.webp', status: 'approved-runtime', motion: 'none' }
    },
    'secondary-brand-emblem': {
      micro: { file: A + 'emblem-shield-128.webp', status: 'secondary', motion: 'none' }
    },
    'horizontal-wordmark': {
      lockup: {
        file: A + 'lockup-horizontal-720.webp', status: 'approved-concept-runtime',
        mask: M + 'lockup-horizontal-720/specular-mask.png', channel: 'specular', motion: 'sweep'
      }
    },
    'stacked-wordmark': {
      lockup: { file: A + 'lockup-stacked-960.webp', status: 'approved-concept-runtime', motion: 'none' }
    },
    /* Bible/study. Fills a manifest concept that had no runtime file. */
    study: {
      micro: { file: A + 'bible-study.svg', status: 'approved-runtime', scalable: true, motion: 'none' }
    },

    /* Mirror Time glyphs, landed with the in-flight Mirror/Bible feature.
       Registered so that feature resolves through here instead of its own
       hardcoded icon map when it is wired up. */
    'mirror-time': {
      micro: { file: A + 'mirror-time.svg', status: 'approved-runtime', scalable: true, motion: 'none' }
    },
    'mirror-prayer': {
      micro: { file: A + 'mirror-prayer.svg', status: 'approved-runtime', scalable: true, motion: 'none' }
    },
    'mirror-forgive': {
      micro: { file: A + 'mirror-forgive.svg', status: 'approved-runtime', scalable: true, motion: 'none' }
    },
    'mirror-mantra': {
      micro: { file: A + 'mirror-mantra.svg', status: 'approved-runtime', scalable: true, motion: 'none' }
    },

    'app-identity': {
      system: { file: A + 'app-icon-512.png', status: 'approved-runtime', motion: 'none' }
    }
  };

  /* Concepts approved in the brand manifest with NO runtime file anywhere.
     These render a neutral placeholder and are reported by audit(). */
  const MISSING = {
    faith: 'Faith/Word/devotional glyph. No runtime file in any branch.',
    discipline: 'Discipline/accountability glyph. Streak and challenge art are NOT the Discipline glyph.',
    serve: 'Service/community-action glyph. No runtime file in any branch.',
    'challenge:micro': 'Small Challenges nav glyph. The breakthrough crest is hero art, not a micro glyph.',
    'brotherhood:micro': 'Small Brothers nav glyph. Do not shrink the brotherhood crest.',
    'streak:micro': 'Small streak status glyph.',
    'prayer:micro': 'Small prayer control glyph. Prayer artwork is not a micro glyph. '
      + 'mirror-prayer.svg is a candidate but was authored for Mirror Time; '
      + 'confirm with brand before promoting it to the canonical Prayer glyph.',
    'legacy:micro': 'Small Legacy control glyph. Must derive from the ring, never an hourglass.'
  };

  /* Held out of the runtime on purpose. Never resolvable. */
  const WITHHELD = {
    'art-hourglass': 'Quarantined. Legacy is canonically the forged signet ring.',
    'badge-creator': 'Conditional. No explicit creator/founder product state is defined yet.',
    'app-icon': 'System tier. PWA install identity only, never an in-app icon.'
  };

  const unresolved = [];
  const mounted = [];
  const generic = [];
  const tierViolations = [];

  /* px bands the tiers promise; hero art must never render at glyph size */
  const BANDS = { micro: [16, 28], control: [32, 72], hero: [96, Infinity] };

  function resolve(concept, tier) {
    const entry = CONCEPTS[concept] && CONCEPTS[concept][tier];
    if (entry) return entry;
    const key = MISSING[`${concept}:${tier}`] ? `${concept}:${tier}` : concept;
    return { missing: true, concept, tier, reason: MISSING[key] || 'Not an approved concept/tier pair.' };
  }

  /* Builds the layered material shell from MATERIAL_MOTION.md:
     base artwork underneath, one masked response layer above it. The base is
     never animated — only the named channel is. */
  function markup(entry, label) {
    if (entry.missing) {
      return `<span class="mog-missing" role="img" aria-label="${label || entry.concept} artwork pending"
              title="Awaiting approved ${entry.concept} asset"></span>`;
    }
    const alt = label ? ` alt="${label}"` : ' alt="" aria-hidden="true"';
    const base = `<img class="mog-base" src="${entry.file}"${alt}>`;
    if (!entry.mask || entry.motion === 'none') return base;
    return base + `<span class="mog-fx" aria-hidden="true"></span>`;
  }

  function hydrate(root = document) {
    root.querySelectorAll('[data-mog]').forEach(el => {
      if (el.dataset.mogReady) return;
      const [concept, tier = 'control'] = el.dataset.mog.split(':');
      const entry = resolve(concept, tier);

      el.classList.add('mog-asset');
      el.dataset.mogReady = '1';
      el.dataset.mogTier = tier;

      if (entry.scalable) el.dataset.mogScalable = '1';
      if (entry.missing) {
        el.dataset.mogMissing = concept;
        unresolved.push({ concept, tier, where: el.dataset.mogWhere || '(unlabelled)', reason: entry.reason });
      } else {
        if (entry.mask) el.style.setProperty('--mog-mask', `url('${entry.mask}')`);
        if (entry.motion && entry.motion !== 'none') el.dataset.motion = entry.motion;
        mounted.push({
          concept, tier, file: entry.file, channel: entry.channel || '—',
          motion: entry.motion || 'none', where: el.dataset.mogWhere || '(unlabelled)'
        });
      }
      el.innerHTML = markup(entry, el.dataset.mogLabel);
    });

    /* Controls still standing on a generic glyph because the approved MOG
       glyph for that concept does not exist yet. Declared, not disguised. */
    root.querySelectorAll('[data-mog-generic]').forEach(el => {
      if (el.dataset.mogGenericLogged) return;
      el.dataset.mogGenericLogged = '1';
      const [concept, tier = 'micro'] = el.dataset.mogGeneric.split(':');
      generic.push({
        concept, tier,
        where: el.dataset.mogWhere || '(unlabelled)',
        reason: MISSING[`${concept}:${tier}`] || MISSING[concept] || 'No approved runtime file.'
      });
    });
  }

  /* Enforces the tier contract instead of merely documenting it: if a mount
     renders outside its tier's px band, that is a defect, not a style choice. */
  function verifyTiers(root = document) {
    root.querySelectorAll('.mog-asset[data-mog-tier]').forEach(el => {
      const band = BANDS[el.dataset.mogTier];
      if (!band || !el.offsetWidth || el.dataset.mogScalable) return;
      const size = Math.max(el.offsetWidth, el.offsetHeight);
      if (size < band[0] || size > band[1]) {
        const v = {
          concept: (el.dataset.mog || '').split(':')[0],
          tier: el.dataset.mogTier,
          rendered: Math.round(size) + 'px',
          allowed: band[1] === Infinity ? `${band[0]}px+` : `${band[0]}-${band[1]}px`,
          where: el.dataset.mogWhere || '(unlabelled)'
        };
        if (!tierViolations.some(x => x.where === v.where)) tierViolations.push(v);
      }
    });
    if (tierViolations.length) console.warn('[MOG] tier violations', tierViolations);
  }

  /* Fires the one-shot channel sweeps once, on reveal. */
  function reveal(root = document) {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    root.querySelectorAll('.mog-asset[data-motion="sweep"]').forEach((el, i) => {
      setTimeout(() => el.classList.add('mog-lit'), 120 + i * 90);
    });
  }

  /* Produces the branded-concept audit: what is mounted, and what is still
     standing on a generic or absent asset. */
  function audit() {
    return { mounted, unresolved, generic, tierViolations, withheld: WITHHELD, tiers: TIERS };
  }

  return { resolve, hydrate, reveal, verifyTiers, audit, CONCEPTS, MISSING, WITHHELD, TIERS };
})();
