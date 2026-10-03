# Herly — Her Life. Her Way.

A runnable Flutter wellbeing **mock application** for Android, iOS and web. Includes a reference-led welcome screen, local onboarding, a persistent five-tab shell with focused Calendar and Chat views, twelve tracking categories, calendar, illustrative insights, scripted AI, wellness, self-care, journal, learning, reminders, privacy, safety previews and Herly+.

## Run

Verified with Flutter 3.47.5 / Dart 3.13.4.

```sh
flutter pub get
flutter run
```

Choose an installed simulator/device. For a browser preview without Chrome:

```sh
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8080 --directory build/web
```

Open `http://localhost:8080`. The app uses responsive, scrollable layouts and constrains wide screens to a readable mobile column. Android requires an Android SDK. iOS deployment requires Xcode and appropriate signing; a simulator build does not require distribution signing.

## Verify

```sh
dart format .
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
flutter build ios --simulator --debug
```

Generate actual Flutter screen captures:

```sh
flutter test --dart-define=CAPTURE=true test/route_smoke_test.dart
```

Ten tests cover cycle date boundaries and consecutive-period grouping, same-day log replacement and persistence, authentication validation, AI escalation and consent, onboarding, period logging, navigation, chat, all 21 routes, small screens, locale changes, dark mode and enlarged text.

## Implementation

- `lib/app`: application bootstrap, GoRouter and persistent tab shell.
- `lib/core`: semantic themes, reusable UI, localization delegate, local repositories and Riverpod state.
- `lib/features`: onboarding, home, cycle, tracking, insights, AI and secondary spaces.
- `assets`: outlined SVG branding, launcher icons, SVG illustrations and icons, palette JSON, offline Manrope typography, generated welcome artwork.
- `docs/screenshots`: actual Flutter renders; `docs/ui-concept.png` is an AI concept board, not a screenshot.
- `docs/FLOWS.md`: route and behavior inventory.
- `docs/ASSETS.md`: assets, provenance and generation prompts.

Settings use Riverpod with persisted theme mode, color story (rose/lavender/sage), and locale. GoRouter's indexed stateful shell retains tabs. Tracking, chat, reminders, profile, goals, article completion and routine checkboxes persist through SharedPreferences. A same-day tracking category has one editable entry; saving replaces that day's value. Journals likewise currently store one entry per day.

## Scope and limitations

This is a functional design prototype, not a production healthcare service. Local preferences are **unencrypted**; use sample data. Auth is simulated, AI replies are scripted, all prices are demo values, and security locks, notifications, location sharing, voice and attachments are explicitly marked previews. Nothing calls emergency services or charges a card.

English, Sinhala and Tamil now cover the app interface, dialogs, validation, learning content and scripted chat replies. Dates use the selected locale; Sinhala and Tamil fonts are bundled offline. Authored names, notes and messages stay unchanged. Native-speaker editorial QA remains. The generated welcome illustration and recreated SVG wordmark closely follow the reference but are not pixel-identical to the uploaded art. The physical phone frame and baked-in controls are intentionally excluded from the live UI.

Cycle estimates use user-configured lengths; they are not medical predictions and must not be used for contraception. Insights charts are clearly labeled illustrative demo data. No clinical correlations are inferred. Choosing “I don’t get periods” hides cycle estimates; hiding sensitive modules removes sensitive goal choices. The AI concept board may contain invented labels/copy and must not be used as clinical content.

Future backend work: replace AuthRepository, TrackingRepository and ChatRepository implementations; move local profile, reminder, subscription and library storage behind dedicated service interfaces; introduce encrypted storage, authenticated APIs, audited deletion/export, real notification scheduling, reviewed health content and professional translation review. Before release, complete accessibility audits, device testing, platform signing and professional security/content review.

The English startup splash uses `assets/brand/splash-reference.png`, an aspect-preserving 780×1560 resize of the exact first uploaded image, including its phone frame. It transitions to the separate interactive welcome screen. Sinhala and Tamil use a localized brand splash. The live welcome is a recreation, not a pixel-exact copy.

## Reference Home redesign (3 October 2026)

The Home page now follows the new supplied reference, with eight new generated images, 22 SVGs, responsive animated cards, daily goal persistence, a Steps tracker, date-aware calendar navigation and a central check-in action. See [Home design and verification](docs/home/README.md) and [asset prompts](docs/home/PROMPTS.md). 

## Calendar, Chat and full localization (3 October 2026)

The supplied Calendar and AI references are rebuilt as interactive Flutter screens with responsive layouts, motion, illustration assets, SVG icons and dark-theme support. Calendar includes month navigation, date selection and saved tracking entries. Chat includes local history, feedback, copy, suggestions and a fixed composer; responses remain scripted.

See [implementation and previews](docs/calendar-chat/README.md). Interface translations live in `lib/core/catalog.dart`; `LText`, input decorations, tooltips and locale-aware dates update when language changes. The regression suite checks all 25 routes in three languages, translated content, compact/tablet/large text layouts, and language changes in existing chats.

## Stable language layouts and text size

Language changes now preserve the same Home, Calendar and Chat column arrangements. Longer copy wraps and cards grow as needed; responsive changes depend on viewport and text size, not language. In **More > Appearance**, the font-size slider adjusts all app text from 85% to 150%, with immediate preview and a reset control. The setting persists alongside language, theme and accent color, and multiplies the device accessibility scaler. Comparison renders are in `docs/appearance/`.
