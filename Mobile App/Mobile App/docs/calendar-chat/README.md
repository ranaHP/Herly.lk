# Calendar and Herly AI

Implemented in the Flutter project at `/Users/bee/.codex/worktrees/6d08/Herly.lk/Mobile App`.

## Design

The supplied screenshots guide the rose/ivory surfaces, navy text, pill calendar states, illustrated day card, cycle ring, event/care/article cards, robot introduction, feature cards, chat bubbles and fixed composer. The phone hardware and OS status bar are supplied by the actual device. Artwork reuses the project's generated assets; this is a responsive recreation, not a pixel-identical raster overlay. Translated copy and larger accessibility text reflow.

- [Calendar — English](calendar-en.png)
- [Chat — English](ai-en.png)
- [Calendar — Sinhala](calendar-si.png)
- [Chat — Sinhala](ai-si.png)
- [Calendar — Tamil](calendar-ta.png)
- [Chat — Tamil](ai-ta.png)

Screenshots are actual Flutter renders at 390 logical pixels wide. Content scrolls below the preview viewport.

## Assets

Reuses `assets/home/home-hero.png`, `home-robot.png`, `home-avatar.png` and the four article images, plus botanical, cycle and wellbeing SVGs. New editable SVGs: `battery.svg`, `heart.svg`, `shield.svg`, `chat.svg`. Wordmark-only light/dark variants allow the tagline to translate. The original reference splash is retained in English; other languages show the localized brand splash. No text is baked into the new screen assets. Earlier image generation prompts and provenance remain in `docs/home/PROMPTS.md`.

New bundled fonts: Noto Sans Sinhala and Noto Sans Tamil, from the Google Fonts repository, under their included SIL Open Font Licenses. Manrope remains the Latin typeface.

## Behavior

- Calendar: real month arithmetic, locale-aware weekdays/date picker, Today, selected-day logs, period/mood/energy values, tracker editing and article navigation. A clearly labeled October 2026 sample appears before personal data exists. Future selections log today's date via the Log Today action, without saving future health observations.
- Chat: persistent scripted replies, localized canned prompts/responses, copy and feedback controls, history, privacy navigation, suggestion rotation, typing indicator and fixed composer. Voice and attachment actions are explicitly labeled demos.
- Language changes: all app-owned labels, paragraphs, buttons, validation, hints, dialogs, tooltips, articles and canned chat replies resolve through the selected catalog. Data stays in canonical storage values. Personal notes, names and typed messages retain their original text. Brand/product names and native language names are retained.

## Validation

`flutter analyze`, `flutter test`, release web compilation, and iOS simulator compilation. Tests include all 25 routes in English/Sinhala/Tamil with real fonts, scroll-through checks, 320px and tablet widths, dark mode, 1.7× text, dynamic translation templates, all canned responses, and switching the language of an existing conversation without modifying user text.
