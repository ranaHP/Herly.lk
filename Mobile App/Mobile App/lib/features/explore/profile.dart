import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../onboarding/welcome.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    const links = [
      ('My Profile', 'profile', Icons.person_outline),
      ('My Health Data', 'health', Icons.favorite_border),
      ('Reminders', 'reminders', Icons.notifications_none),
      ('My Goals', 'goals', Icons.flag_outlined),
      ('Health & Wellness', 'wellness', Icons.spa_outlined),
      ('Self-Care', 'self-care', Icons.wb_sunny_outlined),
      ('My Space', 'journal', Icons.book_outlined),
      ('Learn', 'learn', Icons.auto_stories_outlined),
      ('Privacy & Security', 'privacy', Icons.shield_outlined),
      ('Safety & Support', 'safety', Icons.support_agent),
      ('Appearance', 'appearance', Icons.palette_outlined),
      ('Help & About', 'help', Icons.info_outline),
    ];
    return HerlyPage(
      title: 'Your space',
      subtitle: 'Everything that makes Herly yours.',
      children: [
        HerlyCard(
          child: Row(
            children: [
              const Art('wellbeing', size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile['name']!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(profile['email']!),
                    const LText(
                      'Your wellbeing journey',
                      style: TextStyle(color: HerlyTokens.lavender),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        HerlyCard(
          tint: HerlyTokens.rose,
          onTap: () => context.push('/more/premium'),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: HerlyTokens.rose),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'Herly+',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const LText('A deeper understanding of you'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        HerlyCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final link in links)
                ListTile(
                  leading: Icon(
                    link.$3,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: LText(link.$1),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/more/${link.$2}'),
                ),
            ],
          ),
        ),
        const HerlyCard(
          child: Row(
            children: [
              Icon(Icons.language),
              SizedBox(width: 16),
              Expanded(child: LText('Language')),
              LanguageMenu(),
            ],
          ),
        ),
        const LText(
          'HERLY · HER LIFE. HER WAY.\nLocal demo · version 1.0',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return HerlyPage(
      title: 'Appearance',
      subtitle: 'Make Herly feel like you.',
      children: [
        const Section('Text size'),
        HerlyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: LText('Font size')),
                  LText(
                    '${(settings.fontScale * 100).round()}%',
                    key: const ValueKey('font-size-value'),
                  ),
                ],
              ),
              Slider(
                key: const ValueKey('font-size-slider'),
                value: settings.fontScale,
                min: .85,
                max: 1.5,
                divisions: 13,
                label: '${(settings.fontScale * 100).round()}%',
                semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).update(fontScale: v),
              ),
              const LText(
                'Adjust text across the app. Your device accessibility setting is also respected.',
              ),
              const SizedBox(height: 12),
              const LText(
                'A calmer space. A clearer you.',
                style: TextStyle(fontSize: 18),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(settingsProvider.notifier).update(fontScale: 1),
                child: const LText('Reset text size'),
              ),
            ],
          ),
        ),
        const HerlyCard(
          child: Row(
            children: [
              Expanded(child: LText('Language')),
              LanguageMenu(),
            ],
          ),
        ),
        const Section('Color story'),
        for (final color in [
          ('Herly Rose', HerlyTokens.rose),
          ('Quiet Lavender', Color(0xFF7954B3)),
          ('Soft Sage', Color(0xFF367D68)),
        ])
          HerlyCard(
            tint: color.$2,
            onTap: () =>
                ref.read(settingsProvider.notifier).update(accent: color.$2),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: color.$2, radius: 18),
                const SizedBox(width: 16),
                Expanded(child: LText(color.$1)),
                if (settings.accent == color.$2)
                  Icon(Icons.check_circle, color: color.$2),
              ],
            ),
          ),
        const Section('Light & shade'),
        for (final mode in ThemeMode.values)
          ChoiceTile(
            switch (mode) {
              ThemeMode.system => 'Use device setting',
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
            },
            selected: settings.mode == mode,
            onTap: () => ref.read(settingsProvider.notifier).update(mode: mode),
          ),
        const Section('A little preview'),
        const HerlyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Brand(width: 150),
              SizedBox(height: 12),
              LText('A calmer space. A clearer you.'),
              SizedBox(height: 16),
              HerlyButton('Your personal theme', onPressed: null),
            ],
          ),
        ),
      ],
    );
  }
}
