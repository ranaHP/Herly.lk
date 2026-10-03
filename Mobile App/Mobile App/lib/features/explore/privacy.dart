import '../../core/strings.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/widgets.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});
  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyState();
}

class _PrivacyState extends ConsumerState<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    final p = ref.read(preferencesProvider);
    return HerlyPage(
      title: 'Privacy & Security',
      subtitle: 'You decide what to share. Always.',
      children: [
        const Center(child: Art('privacy', size: 96)),
        const HerlyCard(
          child: LText(
            'Your privacy, made clear\n\nThis prototype stores sample data on this device in unencrypted app preferences. No backend or live AI receives your entries. Biometrics and PIN are demonstrations, not security protections.',
          ),
        ),
        for (final key in [
          'Biometric lock (demo)',
          'Discreet notifications',
          'Hide sensitive modules',
          'AI personalization',
        ])
          HerlyCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SwitchListTile.adaptive(
              title: LText(key),
              value: p.getBool(key) ?? false,
              onChanged: (v) async {
                await p.setBool(key, v);
                if (mounted) setState(() {});
              },
            ),
          ),
        HerlyButton(
          'Set demo PIN',
          secondary: true,
          onPressed: () async {
            final input = TextEditingController();
            await showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const LText('PIN preview'),
                content: TextField(
                  controller: input,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(hintText: '4 digits · not stored')
                      .localized(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const LText('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (RegExp(r'^\d{4}$').hasMatch(input.text)) {
                        Navigator.pop(context);
                        notify(
                          this.context,
                          'PIN preview complete. No lock is enabled.',
                        );
                      }
                    },
                    child: const LText('Preview'),
                  ),
                ],
              ),
            );
            input.dispose();
          },
        ),
        HerlyButton(
          'Export my data',
          secondary: true,
          icon: Icons.download_outlined,
          onPressed: () {
            final export = const JsonEncoder.withIndent('  ').convert({
              'preferences': {
                for (final key in p.getKeys())
                  if (!['tracking', 'chat'].contains(key)) key: p.get(key),
              },
              'tracking': ref
                  .read(trackingProvider)
                  .map((e) => e.toJson())
                  .toList(),
              'goals': p.getStringList('goals'),
              'chat': ref.read(chatProvider).map((e) => e.toJson()).toList(),
            });
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const LText('Your data export'),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(child: SelectableText(export)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const LText('Close'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: export));
                      if (context.mounted) {
                        notify(context, 'Export copied to clipboard.');
                      }
                    },
                    child: const LText('Copy JSON'),
                  ),
                ],
              ),
            );
          },
        ),
        HerlyButton(
          'Delete local demo data',
          secondary: true,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const LText('Delete your local data?'),
                content: const LText(
                  'This removes your profile, logs, chats, and preferences from this demo. This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const LText('Keep data'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const LText('Delete data'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await p.clear();
              ref.invalidate(trackingProvider);
              ref.invalidate(chatProvider);
              ref.invalidate(settingsProvider);
              ref.invalidate(profileProvider);
              ref.invalidate(cycleProvider);
              if (context.mounted) context.go('/welcome');
            }
          },
        ),
      ],
    );
  }
}
