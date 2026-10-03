# Verification — 2 October 2026

Environment: Flutter 3.47.5, Dart 3.13.4, macOS with Xcode 27.0.

- `dart format .`: clean.
- `flutter analyze`: no issues.
- `flutter test --dart-define=CAPTURE=true`: 10 tests passed.
- 21 routes rendered at 390×844 with bundled fonts and assets.
- Core routes checked with 1.7× text, theme changes and English/Sinhala/Tamil locales.
- Small-phone widget coverage at 320×640.
- Release web compilation succeeded; artifacts in `build/web`.
- Debug iOS simulator compilation succeeded; app in `build/ios/iphonesimulator/Runner.app`.
- Android source and launcher resources are included, but Android compilation is unverified because no Android SDK is installed.

UI screenshots are actual Flutter renders in `docs/screenshots`. The welcome was checked for readable controls and separation between illustration and benefit labels. The startup splash is the supplied reference image resized to 780×1560, preserving its phone frame.

A localhost server is available at http://127.0.0.1:8080 while the session is running. Browser security review denied the agent access, so live browser interaction was not verified. Runtime interactions were verified through Flutter widget tests; no native simulator was launched.

These checks do not constitute clinical, security, full localization, or app-store readiness certification. See README for the implemented mock boundaries.

## Calendar, Chat and localization — 3 October 2026

- 17 tests pass, including 25 routes across all three locales with font loading and scroll-through checks.
- New screens checked at 320px phone width, tablet width, dark theme and 1.7x text.
- Catalog parity, dynamic number templates, every canned chat response and live locale switching are verified.
- User-authored chat content stays unchanged when language changes.
- Previews: `docs/calendar-chat/`. Bundled Noto Sinhala/Tamil fonts include redistribution licenses.

## Language layout stability and Appearance

- 19 tests pass; Flutter analysis reports no issues.
- Home metric columns and cycle-ring horizontal position are asserted across English, Sinhala and Tamil.
- Text size persists, clamps to 85–150%, updates immediately, resets, and composes with device scaling.
- Home, Calendar, Chat and Appearance render in all three locales at 150% app text size.
- Content-sized promotional cards and wrapped action labels replace clipped fixed-height text.
