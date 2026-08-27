# People of God

**Check in. Pray. Show up.**

People of God is a privacy-first, faith-based peer-support app for adults. The
native iPhone app and its Messages extension turn an existing iMessage group
into a care circle without turning somebody's pain into a competition.

## Native iPhone + iMessage app

The playable SwiftUI MVP is in [`ios/`](ios/README.md). It includes:

- Circle Check — a private wellness check-in with group-safe sharing controls
- Prayer Chain — request prayer and let the circle confirm that they showed up
- Speak Life — send a specific affirmation into the conversation
- collective Showing Up milestones instead of individual leaderboards
- a dedicated 988 / emergency safety flow
- on-device storage only; no accounts, analytics, ads, or backend in this MVP

Open `ios/PeopleOfGod.xcodeproj` on a Mac with Xcode to run the iPhone app or
the Messages extension.

## Android + web app

The repository root is now the installable **People of God PWA**, built around
the same privacy and safety rules as the iPhone app. Open the live app at:

**https://mcclusterishere.github.io/MOG-Men-Of-God/**

On Android, open that URL in Chrome, tap the menu, then choose **Install app**
or **Add to Home screen**. The web MVP supports private Circle Checks, Prayer
Chain, Speak Life, Showing Up milestones, the device Share sheet, offline app
shell caching, and immediate 988/911 links.

This is the fastest Android release path. A Play Store package can later wrap
the PWA as a Trusted Web Activity or reproduce the interface in native Kotlin.

## Product boundary

People of God is peer support, not therapy, diagnosis, medical treatment, or an
emergency service. Prayer is offered alongside professional support and never
as a replacement for it.

## Verification

- `.github/workflows/ios-ci.yml` builds both Apple targets, runs privacy and
  payload tests, and exports real iPhone Simulator screenshots.
- `tests/web-privacy.test.js` verifies that emotional state, support choices,
  prayer text, and affirmations never enter browser persistence.
