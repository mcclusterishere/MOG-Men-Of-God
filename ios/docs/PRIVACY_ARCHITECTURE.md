# Privacy architecture

## Data minimization in MVP 0.1

The app keeps only four local values in the shared app-group `UserDefaults`:

- completed check-in count
- completed support-act count
- completed prayer-act count
- timestamp of the latest local activity

The app does **not** persist the selected emotional state, requested support,
reflection text, recipient, Apple ID, conversation, phone number, or message
history.

## What enters an iMessage

Apple's Messages framework requires app-specific state on an `MSMessage` URL so
another installed copy of the extension can reopen the round. The People of God
URL contains only:

- protocol version
- random round UUID
- activity type and stage
- public prompt
- public response deliberately approved by the sender
- public support choices deliberately approved by the sender
- collective Showing Up count

`CheckInState` is structurally absent from `MessagePayload`; it cannot be encoded
by accident. Unit tests enforce this boundary.

iMessage delivery and message history are handled by Apple and the participants'
devices. This app does not operate a relay or analytics endpoint.

## Future backend boundary

Before adding accounts, cloud sync, notifications, church/circle administration,
or aggregate reporting, complete a new threat model and explicit consent design.
The future service must never ingest detailed mental-health check-in content for
advertising, marketing, pastoral surveillance, or unrelated McCluster/HERE data.
