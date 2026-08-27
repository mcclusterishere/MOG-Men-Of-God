# People of God on Android

## Test it now

The repository-root Progressive Web App is the Android MVP. It runs in Chrome,
uses the Android Share sheet, works as a standalone home-screen app, and keeps
detailed check-in answers out of browser storage.

1. Open `https://mcclusterishere.github.io/MOG-Men-Of-God/` in Chrome.
2. Open Chrome's menu.
3. Choose **Install app** or **Add to Home screen**.

## Google Play path

The next packaging decision is intentionally separate from the MVP:

- **Trusted Web Activity:** fastest Play Store package; keeps one web codebase.
- **Native Kotlin + Jetpack Compose:** strongest Android platform integration;
  requires a separate UI implementation and Google Play signing pipeline.
- **Shared cross-platform rewrite:** useful only if maintaining two native user
  interfaces becomes too expensive.

The current recommendation is to pilot the installable PWA first, confirm that
circles actually complete check-ins, then choose Trusted Web Activity or native
Kotlin based on retention and notification needs.
