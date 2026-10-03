# Herly flows

## First visit

Splash → Welcome → Goals (multiple choice) → Demo sign-in → Personal information → Cycle setup → Privacy choices → Home. Returning local sessions enter Home. Welcome also links directly to demo sign-in. Back navigation works throughout onboarding. Required profile fields and email entry are validated.

## Main navigation

| Tab | Actions and states |
| --- | --- |
| Home | Personalized greeting, cycle estimate, quick trackers, mood check-in, hydration/rest, self-care, article, AI |
| Calendar | Month changes, selected day, saved entries, estimate legend, future logging disabled, editable period flow |
| Insights | Cycle/Mood/Body/Sleep tabs, animated sample chart, configured metrics, actual log observations and empty state |
| Herly AI | Suggested prompts, typed messages, scripted reply, typing, persisted history, contextual consent, safety escalation |
| More | Profile, health, reminders, goals, wellness, self-care, journal, learning, privacy, safety, themes, premium, help |

## Logging

Choose category → date → option/value → optional notes → Save → confirmation → update local state. Period also supports multiple symptoms. Numeric inputs validate units and ranges. Empty inputs cannot save. Failed writes preserve the form and show retry guidance.

Categories: Period, Symptoms, Mood, Sleep, Energy, Water, Weight, Exercise, Nutrition, Medication, Skin, Journal. One entry per category per date; subsequent saves edit that entry.

## Secondary routes

- `/more/profile`: edit name, email and country.
- `/more/health`: browse and edit saved entries; access all trackers.
- `/more/goals`: toggle interests.
- `/more/wellness`: actual daily water/exercise/sleep totals; additional trackers.
- `/more/self-care`: dated routine checkboxes, skin tracking, product note, photo placeholder.
- `/more/journal`: daily reflection, history, voice placeholder.
- `/more/learn`: search and category filtering; empty results.
- `/article/:id`: sample article and persisted completion state.
- `/more/reminders`: create/edit/delete, time, recurrence, enabled state; no OS scheduling.
- `/more/privacy`: stored consent, preview locks, JSON clipboard export, confirmed local deletion.
- `/more/safety`: trusted sample contacts, check-in preview, location preview, support guidance.
- `/more/appearance`: persisted theme mode and accent.
- `/more/premium`: plan choice, demo membership activation/deactivation; no purchase.
- `/more/help`: scope, privacy, localization and version information.

## Visual behavior

280 ms selection transitions, animated progress bars, 600 ms demo chart entrance, native Material interaction feedback, haptic-ready buttons, SVG art and loading feedback. Reduced-motion preferences remove custom chart/progress/logo animations. The welcome screen scrolls on short displays.

## Remaining production work

Full localization, fully adaptive large-text welcome composition, real identity/security/payment integrations, clinical data validation, advanced cycle calculations, opt-in fertility journeys, robust data migration and device-level QA. The prototype does not claim these integrations exist.
