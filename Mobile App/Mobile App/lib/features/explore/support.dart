import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});
  @override
  ConsumerState<SafetyScreen> createState() => _SafetyState();
}

class _SafetyState extends ConsumerState<SafetyScreen> {
  @override
  Widget build(BuildContext context) {
    final p = ref.read(preferencesProvider);
    final contacts = p.getStringList('contacts') ?? [];
    return HerlyPage(
      title: 'Safety & Support',
      subtitle: 'You deserve to feel safe and supported.',
      children: [
        const Center(child: Art('privacy', size: 96)),
        const HerlyCard(
          child: LText(
            'If you are in immediate danger, contact your local emergency services. This prototype does not make calls, send messages, or share location.',
          ),
        ),
        const Section('Trusted people'),
        if (contacts.isEmpty)
          const LText('Add a sample contact to explore this workflow.'),
        for (final contact in contacts)
          HerlyCard(
            child: Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 16),
                Expanded(child: Text(contact)),
                IconButton(
                  tooltip: context.tr('Remove contact'),
                  onPressed: () async {
                    contacts.remove(contact);
                    await p.setStringList('contacts', contacts);
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        HerlyButton(
          'Add trusted contact',
          secondary: true,
          onPressed: () async {
            final input = TextEditingController();
            final value = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const LText('Trusted contact (demo)'),
                content: TextField(
                  controller: input,
                  decoration: InputDecoration(labelText: 'Name and phone')
                      .localized(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const LText('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (input.text.trim().isNotEmpty) {
                        Navigator.pop(context, input.text.trim());
                      }
                    },
                    child: const LText('Save'),
                  ),
                ],
              ),
            );
            input.dispose();
            if (value != null) {
              contacts.add(value);
              await p.setStringList('contacts', contacts);
              setState(() {});
            }
          },
        ),
        HerlyButton(
          'Preview a safety check-in',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const LText('Safety check-in preview'),
              content: const LText(
                '“I’d appreciate a check-in. Could you contact me?”\n\nDemo only. Nothing is sent.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LText('Close preview'),
                ),
              ],
            ),
          ),
        ),
        HerlyButton(
          'Preview temporary location sharing',
          secondary: true,
          onPressed: () => notify(
            context,
            'Demo: location sharing would expire in 15 minutes. No location is accessed or shared.',
          ),
        ),
        const Section('Finding support'),
        const HerlyCard(
          child: LText(
            'Reach out to a trusted person, a qualified healthcare professional, or a local support organization. For urgent assistance, use the emergency services available in your location.',
          ),
        ),
      ],
    );
  }
}

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumState();
}

class _PremiumState extends ConsumerState<PremiumScreen> {
  bool annual = true;
  @override
  Widget build(BuildContext context) {
    final enabled = ref.read(preferencesProvider).getBool('premium') ?? false;
    return HerlyPage(
      title: 'Herly+',
      children: [
        const Center(child: Art('ai', size: 100)),
        LText(
          'Understand yourself\nmore deeply.',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const LText('More room for your story.', textAlign: TextAlign.center),
        for (final benefit in [
          'Advanced personal insights',
          'Longer history & reports',
          'Contextual Herly AI',
          'Premium routines',
          'Enhanced personalization',
        ])
          ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: HerlyTokens.lavender,
            ),
            title: LText(benefit),
          ),
        ChoiceTile(
          'Annual · LKR 4,900 / year',
          selected: annual,
          onTap: () => setState(() => annual = true),
        ),
        ChoiceTile(
          'Monthly · LKR 590 / month',
          selected: !annual,
          onTap: () => setState(() => annual = false),
        ),
        const LText(
          'Demo pricing only. No payment, subscription, or automatic renewal occurs. Premium capabilities are concept previews.',
        ),
        HerlyButton(
          enabled ? 'Demo membership active' : 'Explore Herly+ demo',
          onPressed: () async {
            await ref.read(preferencesProvider).setBool('premium', true);
            setState(() {});
            if (context.mounted) {
              notify(context, 'Herly+ demo activated. No charge was made.');
            }
          },
        ),
        if (enabled)
          TextButton(
            onPressed: () async {
              await ref.read(preferencesProvider).setBool('premium', false);
              setState(() {});
            },
            child: const LText('End demo membership'),
          ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => const HerlyPage(
    title: 'About Herly',
    children: [
      Brand(),
      LText('Her Life. Her Way.'),
      HerlyCard(
        child: LText(
          'Herly is a runnable Flutter design prototype for a personal wellbeing companion.\n\nTracking, preferences, reminders, and chat history are saved locally. Authentication, AI, subscriptions, security locks, notifications, and safety actions are simulations.\n\nEnglish, Sinhala and Tamil interface text changes with your language setting. Your own notes and messages stay as you wrote them.\n\nUse sample data only. This prototype does not provide diagnosis or emergency services.',
        ),
      ),
      LText('Version 1.0.0 · Made with care'),
    ],
  );
}
