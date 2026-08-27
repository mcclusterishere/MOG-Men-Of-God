# People of God for iPhone and Messages

This folder contains a native SwiftUI iPhone app plus a real Messages app
extension. It does not wrap the existing website.

## What is playable now

1. Open People of God from the Messages app drawer.
2. Start a Circle Check, Prayer Chain, or Speak Life round.
3. Insert the interactive card into the conversation and tap Send.
4. Another person with the app taps the card, responds, and sends the updated
   card back into the same `MSSession`.
5. The card's Showing Up count increases without publishing private check-in
   details unless the responder deliberately chooses to share a support request.

Sensitive selections are saved only in the shared app container on that iPhone.
They are never placed in the message URL. The URL carries only the intentionally
public response, activity type, round identifier, and collective count.

## Run it on your iPhone

Requirements:

- a Mac with a current App Store-supported version of Xcode
- an iPhone signed into iMessage
- an Apple ID added in Xcode

Steps:

1. Open `PeopleOfGod.xcodeproj`.
2. Select the **PeopleOfGod** project, then **Signing & Capabilities**.
3. Choose your Apple development team for all three targets.
4. If `org.mccluster.peopleofgod` is unavailable, replace it in both app bundle
   identifiers and replace `group.org.mccluster.peopleofgod` in both entitlement
   files and `SharedStore.swift` with the same unique suffix.
5. Select the **PeopleOfGod** scheme and your connected iPhone, then press Run.
6. After installation, open Messages, open a conversation, tap **+**, choose
   **More**, and enable **People of God** if it is not already visible.
7. For extension debugging, select the **PeopleOfGodMessages** scheme, choose
   your iPhone, press Run, and let Xcode launch Messages.

The sender still taps Apple's Send arrow after the extension inserts a card.
That confirmation is intentional and required by the Messages experience.

## TestFlight and App Store path

See [`docs/APP_STORE_RELEASE.md`](docs/APP_STORE_RELEASE.md) for the complete
signing, archive, TestFlight, privacy, review, and release checklist.

## Architecture

- `PeopleOfGod/` — the installed iPhone container app
- `PeopleOfGodMessages/` — `MSMessagesAppViewController` extension
- `Shared/` — models, message URL codec, privacy-first local counters, and UI
- `PeopleOfGodTests/` — payload and privacy-boundary unit tests

Minimum deployment target: iOS 17.0. No third-party dependencies are used.
