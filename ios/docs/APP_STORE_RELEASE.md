# TestFlight and App Store release checklist

## 1. Apple account and identifiers

- Enroll the publishing organization in the Apple Developer Program.
- Create or confirm the app ID `org.mccluster.peopleofgod`.
- Create or confirm the extension ID `org.mccluster.peopleofgod.messages`.
- Enable the App Groups capability for both IDs.
- Create `group.org.mccluster.peopleofgod` and attach both targets.
- In Xcode, choose the publishing team for the app, extension, and tests.

If another developer owns one of those identifiers, use a domain McCluster Corp
controls and update all four occurrences documented in `ios/README.md`.

## 2. Device alpha

- Install the PeopleOfGod scheme on two physical iPhones with different iMessage
  accounts.
- Confirm the extension appears under Messages → + → More.
- Test each new card, card tap, response, update, and Showing Up count.
- Confirm a private Circle Check inserts no message.
- Confirm “share only that I checked in” reveals no feeling or support selection.
- Confirm “share what support I want” reveals only the selected support request.
- Test Text 988, Call 988, text a trusted person, and Call 911 links on a device.
- Test VoiceOver, Dynamic Type, Reduce Motion, light/dark system settings, airplane
  mode, and a conversation with several participants.
- Test an older supported phone running iOS 17 if iOS 17 remains the deployment
  target at release.

## 3. App Store Connect

- Create a new app record named **People of God: Check-Ins**.
- Use primary category **Lifestyle**. Do not market the MVP as treatment or diagnosis.
- Complete age-rating questions for an adults-only launch.
- Add a support URL and a publicly hosted privacy-policy URL.
- Upload iPhone screenshots of the container app and Messages experience.
- In App Privacy, answer based on the shipped binary. This MVP has no account,
  analytics SDK, ads, tracking, or server collection.
- Add review notes explaining how to find the iMessage extension and provide a
  short screen recording if App Review requests one.

Suggested review note:

> People of God is a faith-based peer-support tool, not therapy or medical care.
> Open any Messages conversation, tap +, tap More, and choose People of God.
> The reviewer can send Circle Check, Prayer Chain, and Speak Life cards. Detailed
> check-in answers stay on-device; only text the reviewer intentionally selects
> is placed in the message. The Support tab contains 988 and emergency options.

## 4. Archive and TestFlight

1. Set the version and build number for both app and extension targets.
2. Choose **Any iOS Device (arm64)**.
3. Product → Archive.
4. In Organizer, run **Validate App** and resolve every warning.
5. Distribute App → App Store Connect → Upload.
6. Add internal testers first.
7. Complete TestFlight compliance questions and submit an external group for Beta
   App Review when the internal alpha is stable.

## 5. Release gate

Do not submit publicly until all of the following are true:

- a qualified mental-health/safety reviewer has reviewed wording and crisis flow
- the 988 and emergency links have been tested on a U.S. physical device
- the public privacy notice matches the actual binary and any future backend
- no sensitive response is logged, analyzed, advertised against, or exposed to a
  leader dashboard
- account deletion exists before any later version introduces accounts
- the support contact and incident-response owner are staffed

The current source intentionally ships without a backend. Adding one is a new
privacy/security phase, not a configuration toggle.
