import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/strings.dart';
import '../../core/widgets.dart';
import 'welcome.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool login;
  const OnboardingScreen({super.key, this.login = false});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  int step = 0;
  final goals = <String>{};
  final name = TextEditingController();
  final email = TextEditingController();
  final country = TextEditingController(text: 'Sri Lanka');
  DateTime? birth;
  DateTime lastPeriod = dateOnly(DateTime.now())
      .subtract(const Duration(days: 25));
  int cycle = 28, period = 5;
  String cycleType = 'I get my period regularly';
  bool busy = false, emailMode = false;
  String? error;
  final privacy = {
    'Reminders': false,
    'Biometric lock (demo)': false,
    'Discreet notifications': true,
    'Hide sensitive modules': false,
    'AI personalization': false,
  };
  @override
  void initState() {
    super.initState();
    if (widget.login) step = 1;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    country.dispose();
    super.dispose();
  }

  Future<void> authenticate(String method) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(authProvider).signIn(method, email.text);
      if (mounted) setState(() => step = 2);
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Enter a valid email address to continue.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> next() async {
    if (step == 2 &&
        (name.text.trim().isEmpty ||
            birth == null ||
            country.text.trim().isEmpty)) {
      setState(
        () => error = 'Please add your name, date of birth, and country.',
      );
      return;
    }
    if (step < 4) {
      setState(() {
        step++;
        error = null;
      });
      return;
    }
    setState(() => busy = true);
    final p = ref.read(preferencesProvider);
    await p.setString('name', name.text.trim());
    await p.setString(
      'email',
      email.text.trim().isEmpty ? 'samara@example.com' : email.text.trim(),
    );
    await p.setString('country', country.text.trim());
    await p.setString('birth', birth!.toIso8601String());
    await p.setStringList('goals', goals.toList());
    await p.setString('cycleType', cycleType);
    await p.setInt('cycleLength', cycle);
    await p.setInt('periodLength', period);
    await p.setString('lastPeriod', lastPeriod.toIso8601String());
    for (final entry in privacy.entries) {
      await p.setBool(entry.key, entry.value);
    }
    await p.setBool('onboarded', true);
    ref.invalidate(cycleProvider);
    if (mounted) {
      context.go('/home');
      notify(context, 'Welcome to your space. You’re all set.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'What would you like Herly to help you with?',
      'Create your account',
      'A few details about you',
      'Let’s understand your cycle',
      'Your privacy is our priority',
    ];
    final subtitles = [
      'Choose what matters to you. You can change this any time.',
      'A little space for a healthier, happier you.',
      'Make this space feel like yours.',
      'Your experience is unique. We’ll meet you where you are.',
      'You control your data. Every permission is your choice.',
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (step == 0) {
              context.go('/welcome');
            } else {
              setState(() => step--);
            }
          },
        ),
        title: LinearProgressIndicator(
          value: (step + 1) / 5,
          minHeight: 4,
          borderRadius: BorderRadius.circular(4),
        ),
        actions: const [LanguageMenu(), SizedBox(width: 16)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            children: [
              LText(
                'YOUR JOURNEY  /  0${step + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              LText(
                context.tr(titles[step]),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              LText(subtitles[step]),
              const SizedBox(height: 28),
              if (step == 0)
                ...List.generate(
                  DemoContent.goals.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChoiceTile(
                      DemoContent.goals[i],
                      art: DemoContent.goalArt[i],
                      selected: goals.contains(DemoContent.goals[i]),
                      onTap: () => setState(() {
                        if (!goals.add(DemoContent.goals[i])) {
                          goals.remove(DemoContent.goals[i]);
                        }
                      }),
                    ),
                  ),
                ),
              if (step == 1) ...[
                const Center(child: Art('journey', size: 110)),
                const SizedBox(height: 28),
                for (final method in ['Google', 'Apple', 'Email'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HerlyButton(
                      'Continue with $method',
                      secondary: true,
                      busy: busy,
                      onPressed: () {
                        if (method == 'Email') {
                          setState(() => emailMode = true);
                        } else {
                          authenticate(method);
                        }
                      },
                    ),
                  ),
                if (emailMode) ...[
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email')
                        .localized(context),
                  ),
                  const SizedBox(height: 12),
                  HerlyButton(
                    'Continue',
                    busy: busy,
                    onPressed: () => authenticate('Email'),
                  ),
                ],
                const SizedBox(height: 16),
                const LText(
                  'Demo sign-in · No connection to Google or Apple is made.',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const LText('Demo terms & privacy'),
                      content: const LText(
                        'Herly is a local prototype. Entries are stored on this device using unencrypted app preferences. Use sample information only. No account is created and no medical service is provided.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const LText('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: const LText('Terms & Privacy'),
                ),
              ],
              if (step == 2) ...[
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    hintText: 'Samara',
                  ).localized(context),
                ),
                const SizedBox(height: 16),
                HerlyCard(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: birth ?? DateTime(2000),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => birth = d);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: LText(
                          birth == null
                              ? 'Date of birth'
                              : DateFormat.yMMMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(birth!),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: country,
                  decoration: InputDecoration(labelText: 'Country')
                      .localized(context),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [LText('Language'), Spacer(), LanguageMenu()],
                ),
              ],
              if (step == 3) ...[
                for (final option in [
                  'I get my period regularly',
                  'My cycle is sometimes irregular',
                  'I’m not sure yet',
                  'I don’t get periods',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChoiceTile(
                      option,
                      selected: cycleType == option,
                      onTap: () => setState(() => cycleType = option),
                    ),
                  ),
                if (cycleType != 'I don’t get periods') ...[
                  HerlyCard(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: lastPeriod,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => lastPeriod = d);
                    },
                    child: LText(
                      'Last period · ${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(lastPeriod)}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  LText('Average cycle · $cycle days'),
                  Slider(
                    value: cycle.toDouble(),
                    min: 21,
                    max: 45,
                    divisions: 24,
                    label: '$cycle',
                    onChanged: (v) => setState(() => cycle = v.round()),
                  ),
                  LText('Average period · $period days'),
                  Slider(
                    value: period.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 8,
                    label: '$period',
                    onChanged: (v) => setState(() => period = v.round()),
                  ),
                ],
                const LText(
                  'Estimates are for reflection only, never for contraception or diagnosis.',
                ),
              ],
              if (step == 4) ...[
                const Center(child: Art('privacy', size: 96)),
                const SizedBox(height: 16),
                for (final entry in privacy.entries)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: LText(entry.key),
                    value: entry.value,
                    onChanged: (v) => setState(() => privacy[entry.key] = v),
                  ),
                const SizedBox(height: 16),
                const HerlyCard(
                  child: LText(
                    'Prototype privacy: data stays in this browser or device, in unencrypted local storage. Biometrics and notifications are interface demos.',
                  ),
                ),
              ],
              if (error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LText(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (step != 1)
                HerlyButton(
                  step == 4 ? 'Make yourself at home' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  busy: busy,
                  onPressed: next,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
