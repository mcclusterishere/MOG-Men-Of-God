# Claude Handoff: Men of God Visual System

Treat `design/identity/` as the approved brand source of truth for the next visual implementation pass.

## Non-negotiables
1. The app must feel like metal, not like a dark UI with gold CSS accents.
2. Use the supplied marks and glyphs. Do not redraw or substitute them with emoji or generic icons.
3. Preserve mobile-first/PWA behavior and existing app routes while redesigning the presentation layer.
4. Keep install prompts skippable. Never block product use behind installation.
5. No em dashes in customer-facing copy.
6. Keep copy short. Show capability through interaction instead of explaining features in paragraphs.

## Materials
- Obsidian / blackened steel: near-black with subtle physical grain.
- Gunmetal: secondary surfaces, inactive hardware and dividers.
- Forged antique gold: selected navigation, Talents, verification, rank, achievements and important calls to action.
- Bone/platinum: readable text and neutral contrast.

## Interaction treatment
- Buttons should visually depress into a machined surface.
- Active controls should catch a restrained metallic edge highlight.
- Use very subtle moving specular reflections rather than glow effects.
- Progress tracks should resemble milled channels.
- Sheets/modals should read as metal plates or inset panels, not floating SaaS cards.

## UI glyph mapping
Faith = `glyphs/faith.png`
Discipline = `glyphs/discipline.png`
Brotherhood = `glyphs/brotherhood.png`
Legacy = `glyphs/legacy.png`
Prayer = `glyphs/prayer.png`
Study = `glyphs/study.png`
Serve = `glyphs/serve.png`
Challenge = `glyphs/challenge.png`
Streak = `glyphs/streak.png`
Rank = `glyphs/rank.png`
Verified = `glyphs/verified.png`
Talents = `glyphs/talents.png`

## Product IA to preserve
Primary tabs: Today, Feed, Challenges, Brothers, Me.

Today should prioritize the current action, daily word, streak, Talents and one challenge. Feed should feel visually consumable and social, not like a forum. Challenges should be instantly scannable. Brothers should feel like a private chapter/fraternity directory. Profiles should support a normal Brother profile and later a special Platform/Admin profile.

## Brand architecture
Men of God is intended to be bigger than one church. It should connect Christian men across churches while pointing men toward brotherhood, accountability, service, study and local church/community life. Avoid denomination-specific visual assumptions unless a chapter explicitly needs them.

## Future typography
A custom MOG Forge family is planned. Until the production font exists, use a disciplined temporary typography stack and avoid pretending a generic typeface is the final brand font.

## Implementation priority
First make the existing prototype feel unmistakably Men of God using these assets. Then wire real interactions and data states. Do not add more generic placeholder sections just to make the app look fuller.
