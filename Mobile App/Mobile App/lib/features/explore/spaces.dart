import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../tracking/tracker.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final String kind;
  const SpaceScreen({super.key, required this.kind});
  @override
  ConsumerState<SpaceScreen> createState() => _SpaceState();
}

class _SpaceState extends ConsumerState<SpaceScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(trackingProvider);
    final p = ref.read(preferencesProvider);
    final kind = widget.kind;
    if (kind == 'health') {
      return HerlyPage(
        title: 'My Health Data',
        subtitle: 'Your observations, together in one place.',
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in DemoContent.trackers)
                ActionChip(
                  label: LText(category),
                  avatar: const Icon(Icons.add, size: 16),
                  onPressed: () => openTracker(context, category),
                ),
            ],
          ),
          if (logs.isEmpty)
            const HerlyCard(
              child: Column(
                children: [
                  Art('empty'),
                  LText('Nothing logged yet. Start with how you feel.'),
                ],
              ),
            ),
          for (final log in logs.reversed)
            HerlyCard(
              onTap: () => openTracker(context, log.category, date: log.date),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    '${context.tr(log.category)} · ${DemoContent.trackers.contains(log.category) && ['Nutrition', 'Medication', 'Journal'].contains(log.category) ? log.value : context.tr(log.value)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  LText('${log.date.day}/${log.date.month}/${log.date.year}'),
                  if (log.notes.isNotEmpty) Text(log.notes),
                ],
              ),
            ),
        ],
      );
    }
    if (kind == 'wellness') {
      return HerlyPage(
        title: 'Health & Wellness',
        subtitle: 'Small steps. A little more balance.',
        children: [
          const Art('wellbeing', size: 100),
          for (final pair in [
            ('Water', 'glasses', 8.0),
            ('Exercise', 'minutes', 30.0),
            ('Sleep', 'hours', 8.0),
          ])
            Builder(
              builder: (context) {
                final matching = logs.where(
                  (e) =>
                      e.category == pair.$1 &&
                      dateOnly(e.date) == dateOnly(DateTime.now()),
                );
                final n = matching.isEmpty
                    ? 0.0
                    : double.tryParse(matching.last.value) ?? 0;
                return ProgressCard(
                  title: pair.$1,
                  value: '$n ${pair.$2} today',
                  progress: n / pair.$3,
                  onTap: () => openTracker(context, pair.$1),
                );
              },
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in ['Nutrition', 'Weight', 'Energy'])
                ActionChip(
                  label: LText('Log $category'),
                  onPressed: () => openTracker(context, category),
                ),
            ],
          ),
          HerlyCard(
            tint: HerlyTokens.mint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  'A mindful minute',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const LText(
                  'Pause. Notice your surroundings. Give yourself a little room to breathe.',
                ),
                TextButton(
                  onPressed: () =>
                      notify(context, 'Take this moment at your own pace.'),
                  child: const LText('Begin a quiet moment'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (kind == 'self-care') {
      return HerlyPage(
        title: 'Self-Care',
        subtitle: 'Care that fits your day.',
        children: [
          const Center(child: Art('self-care', size: 100)),
          for (final title in [
            'Morning skincare',
            'Evening skincare',
            'Hair care',
            'A moment outdoors',
          ])
            HerlyCard(
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: LText(title),
                subtitle: const LText('Your daily ritual'),
                value:
                    p.getBool('routine-${dateOnly(DateTime.now())}-$title') ??
                    false,
                onChanged: (v) async {
                  await p.setBool(
                    'routine-${dateOnly(DateTime.now())}-$title',
                    v!,
                  );
                  setState(() {});
                },
              ),
            ),
          HerlyButton(
            'Log a skin observation',
            secondary: true,
            onPressed: () => openTracker(context, 'Skin'),
          ),
          HerlyButton(
            'Add a product note',
            secondary: true,
            onPressed: () => openTracker(context, 'Journal'),
          ),
          HerlyCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.photo_camera_outlined),
              title: const LText('Progress photos'),
              subtitle: const LText('Photo upload preview'),
              onTap: () =>
                  notify(context, 'Photo storage is a demo placeholder.'),
            ),
          ),
        ],
      );
    }
    if (kind == 'journal') {
      return HerlyPage(
        title: 'My Space',
        subtitle: 'A quiet place. Just for you.',
        children: [
          const Center(child: Art('mood', size: 100)),
          LText(
            'What’s on your mind?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(hintText: 'Today, I’m grateful for…')
                .localized(context),
          ),
          HerlyButton(
            'Save a reflection',
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                notify(context, 'Write a little something first.');
                return;
              }
              await ref
                  .read(trackingProvider.notifier)
                  .save(
                    TrackingEntry(
                      category: 'Journal',
                      value: 'Reflection',
                      notes: controller.text.trim(),
                      date: DateTime.now(),
                    ),
                  );
              controller.clear();
              if (context.mounted) notify(context, 'Your reflection is saved.');
            },
          ),
          HerlyButton(
            'Voice note · demo',
            secondary: true,
            onPressed: () =>
                notify(context, 'Voice recording is a demo placeholder.'),
          ),
          const Section('Your reflections'),
          if (!logs.any((e) => e.category == 'Journal'))
            const LText('A fresh page is waiting for you.'),
          for (final log
              in logs.where((e) => e.category == 'Journal').toList().reversed)
            HerlyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText('${log.date.day}/${log.date.month} · ${log.value}'),
                  const SizedBox(height: 8),
                  Text(log.notes),
                ],
              ),
            ),
        ],
      );
    }
    if (kind == 'goals') {
      final selected = p.getStringList('goals') ?? [];
      return HerlyPage(
        title: 'My Goals',
        subtitle: 'There is no one right journey.',
        children: [
          for (final goal in DemoContent.goals.where(
            (goal) =>
                !(p.getBool('Hide sensitive modules') ?? false) ||
                ![
                  'Sexual health',
                  'Trying for pregnancy',
                  'Pregnancy',
                  'Motherhood',
                ].contains(goal),
          ))
            ChoiceTile(
              goal,
              selected: selected.contains(goal),
              onTap: () async {
                selected.contains(goal)
                    ? selected.remove(goal)
                    : selected.add(goal);
                await p.setStringList('goals', selected);
                setState(() {});
              },
            ),
        ],
      );
    }
    return const HerlyPage(
      title: 'Your space',
      children: [LText('Choose a section from More.')],
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfileScreen> {
  final name = TextEditingController(),
      email = TextEditingController(),
      country = TextEditingController();
  @override
  void initState() {
    super.initState();
    final p = ref.read(preferencesProvider);
    name.text = p.getString('name') ?? 'Samara';
    email.text = p.getString('email') ?? 'samara@example.com';
    country.text = p.getString('country') ?? 'Sri Lanka';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HerlyPage(
    title: 'My Profile',
    children: [
      const Center(child: Art('wellbeing', size: 100)),
      TextField(
        controller: name,
        decoration: InputDecoration(labelText: 'Your name').localized(context),
      ),
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: 'Email').localized(context),
      ),
      TextField(
        controller: country,
        decoration: InputDecoration(labelText: 'Country').localized(context),
      ),
      HerlyButton(
        'Save',
        onPressed: () async {
          if (name.text.trim().isEmpty ||
              !email.text.contains('@') ||
              country.text.trim().isEmpty) {
            notify(context, 'Please complete your profile with a valid email.');
            return;
          }
          final p = ref.read(preferencesProvider);
          await p.setString('name', name.text.trim());
          await p.setString('email', email.text.trim());
          await p.setString('country', country.text.trim());
          ref.invalidate(profileProvider);
          if (context.mounted) notify(context, 'Profile updated.');
        },
      ),
    ],
  );
}
