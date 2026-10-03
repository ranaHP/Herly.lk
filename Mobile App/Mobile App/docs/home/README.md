# Home reference implementation — 3 October 2026

The Home screen has been rebuilt as native Flutter widgets around the supplied reference. It is not a screenshot used as the interface. The outer handset, camera cutout and fake status bar are excluded; real devices provide their own safe areas.

## Deliverables

- `source-reference.png`: original supplied screenshot.
- `reference.png`: actual Flutter render at 390×1060, saved at 2× resolution.
- `compact.png`: 320×740 layout.
- `large-text.png`: 390×844 at 1.7× text scaling.
- `tablet.png`: 768×1024 layout, centered at a readable width.
- `dark.png`: dark theme.
- `../../assets/home`: eight generated PNGs and 22 editable SVGs.
- `../../tool/generate_home_assets.py`: repeatable vector asset generator.
- `PROMPTS.md`: built-in image-generation prompt set and provenance.

## Implemented layout

Brand header, search, notifications and avatar; illustrated greeting with quote; three-column cycle card and animated ring; ten quick actions; insight card; hydration, steps and sleep; mini calendar and daily goal checklist; journey tools; AI and care cards; four recommended articles; a six-position navigation bar with a raised central check-in action.

The light palette follows the reference's bright pink, blush, lavender, peach and mint. The existing theme and language settings remain available. Home's new editorial copy is English, consistent with the prototype's partial-localization scope.

## Interactions

- Search opens the searchable learning library; notifications opens reminders; avatar opens profile.
- Quick actions open working trackers or their corresponding feature pages.
- Logged water, steps and sleep replace reference demo metrics.
- Cycle values use local configuration when provided; otherwise the reference's sample labels are shown.
- Mini-calendar month navigation and date selection work. Its arrow carries the selected date to Calendar.
- Goal completion toggles and persists per day.
- Journey tiles, AI CTA and article cards navigate to existing features.
- Doctor actions explicitly preview unavailable services; emergency support opens the existing safety screen.
- The center petal opens a quick check-in sheet.
- Tab state is retained by GoRouter's indexed shell.

## Motion and responsiveness

Cards enter with a subtle fade/translation; pressed controls scale gently; cycle and wellness indicators animate; goal selection and navigation respond visually. Entrance/progress/press animations respect reduced-motion settings. Compact screens reflow the cycle card; enlarged text stacks multi-column sections and reduces grid column counts. Content scrolls naturally instead of shrinking the whole page.

## Accuracy and limitations

Section order, proportions, palette, imagery subjects and visual hierarchy follow the supplied screenshot. The raster imagery is newly generated and the SVGs are recreated, so this is a close implementation rather than a mathematically pixel-identical reconstruction. The original fonts, layered design and illustration source files were not supplied.

Reference fertility dates, default metrics and daily insight are illustrative demo content, not personal medical predictions. The reference's literal date label is preserved in demo mode; actual user-configured dates are formatted from calendar values. AI and healthcare integrations remain simulated. The About these insights control explains the sample data.

## Verification

`flutter analyze` and all 13 tests pass. The tests cover the existing app flows plus Home rendering at five configurations, saving water via a quick action, central check-in navigation and persisted goal completion. Screenshot capture uses bundled fonts and precached assets.

```sh
flutter test --dart-define=CAPTURE=true test/home_reference_test.dart
flutter run
```
