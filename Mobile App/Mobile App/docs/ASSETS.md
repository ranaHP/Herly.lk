# Asset kit

| Location | Contents |
| --- | --- |
| `assets/brand` | Logo, dark and monochrome SVG variants with outlined text; symbol; SVG/1024px app icon; palette JSON |
| `assets/illustrations` | Generated welcome background plus coordinated SVGs for wellbeing, cycle, mood, sleep, self-care, AI, privacy, learning, journey, empty, success and water; botanical decoration |
| `assets/icons` | Matching rounded outline SVG icon family |
| `assets/fonts` | Manrope and Delius Swash Caps source fonts and SIL Open Font Licenses |
| Platform resources | Android density icons, iOS app icon sizes and web icons |
| `docs/ui-concept.png` | AI-generated design exploration |
| `docs/screenshots` | Rendered Flutter screens |

Palette: rose #D6336C, pink #F47294, peach #FDBA74, lavender #A78BFA, blush #FDE7EC, plum #4A1D3C, ivory #FFF9F5, mint #80B9A5. Runtime theme maps these into semantic Material color roles; dark mode and alternative accents use generated schemes. Typography is bundled offline.

The user supplied three Herly references. Two new raster images were produced using the built-in image generation tool. SVGs were authored as editable vector assets; logo text was converted to outlines with FontTools. The logo is a recreation rather than an exact tracing. `tool/outline_logos.py` and `tool/export-icons.cjs` record the local production helpers; adjust their runtime paths when using another machine.

## Welcome generation prompt

Edit the first attached Herly welcome reference into a production mobile background asset. Remove the entire physical phone frame, status bar, notch, home indicator and all UI text, logo, icons, language selector, dots and buttons. Preserve as exactly as possible the illustrated woman's face, long dark wavy hair, pink blouse, pose with cheek resting on hand, botanical blush peach lavender background and creamy lower wave. Full bleed portrait 9:19.5 composition. Woman centered in middle 40 percent, top 30 percent quiet warm ivory for separately rendered logo and benefits; lower 30 percent ivory curved panel for separately rendered live buttons. No text, no device, no UI. Match the original illustration closely.

## Concept board generation prompt

Use case: ui-mockup. Create a premium Herly mobile app UI concept board, 6 screens in a clean 3 by 2 grid on warm ivory background. Brand rose #D6336C, deep plum #4A1D3C, lavender #A78BFA, blush #FDE7EC. Refined Manrope typography, soft cards, restrained botanical details. Screens: Today with greeting Samara, period estimate hero, mood check-in and hydration; Calendar with correct 7-column calendar and log period button; Insights with cycle chart and metrics; Herly AI chat with suggested questions and demo label; Appearance with Rose/Lavender/Sage themes plus light/dark toggles; dark mode Today. Cohesive realistic mobile UI, readable labels, rounded outlines, no physical phone frames. This is the mockup design board before Flutter implementation. Title Herly — Her Life. Her Way.

The startup splash uses `assets/brand/splash-reference.png`, an aspect-preserving 780×1560 resize of the exact first uploaded image, including its phone frame. It transitions to the separate interactive welcome screen. The live welcome is a recreation, not a pixel-exact copy.
