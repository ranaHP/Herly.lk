import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../tracking/tracker.dart';
import 'home_style.dart';
import 'home_data.dart';
import 'home_header.dart';
import 'cycle_card.dart';
import 'quick_actions.dart';
import 'calendar_goals.dart';
import 'journey_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.read(preferencesProvider);
    final cycle = ref.watch(cycleProvider);
    final logs = ref.watch(trackingProvider);
    final name = ref.watch(profileProvider)['name']!;
    final today = logs.where(
      (entry) => dateOnly(entry.date) == dateOnly(DateTime.now()),
    );
    double value(String category, double fallback) {
      final entries = today.where((entry) => entry.category == category);
      return entries.isEmpty
          ? fallback
          : double.tryParse(entries.last.value) ?? fallback;
    }

    final water = value('Water', HomeDemo.water);
    final steps = value('Steps', HomeDemo.steps.toDouble());
    final sleep = value('Sleep', HomeDemo.sleep);
    final sleepText =
        '${sleep.floor()}h ${((sleep - sleep.floor()) * 60).round()}m';
    final waterText =
        '${water.toStringAsFixed(water == water.roundToDouble() ? 0 : 1)}/8';
    final stepsText = NumberFormat.decimalPattern().format(steps.round());
    final isDemo =
        preferences.getString('lastPeriod') == null &&
        !logs.any((e) => e.category == 'Period');
    final enabled = preferences.getString('cycleType') != 'I don’t get periods';
    final large = (MediaQuery.textScalerOf(context).scale(12) > 16);
    final sections = <Widget>[
      HomeHeader(name: name),
      HomeCycleCard(
        days: isDemo ? 3 : cycle.daysUntil(DateTime.now()),
        day: isDemo ? 25 : cycle.dayOfCycle(DateTime.now()),
        length: cycle.length,
        date: isDemo
            ? 'Tue, 28 Oct 2026'
            : DateFormat(
                'EEE, d MMM yyyy',
                Localizations.localeOf(context).languageCode,
              ).format(cycle.nextPeriod),
        enabled: enabled,
        isDemo: isDemo,
      ),
      const HomeQuickActions(),
      const HomeInsight(),
      _responsiveRow(large, [
        HomeMetric(
          title: 'Water',
          value: '$waterText cups',
          art: 'water',
          progress: water / 8,
          color: HomeStyle.blue,
          onTap: () => openTracker(context, 'Water'),
        ),
        HomeMetric(
          title: 'Steps',
          value: '$stepsText /7,000',
          art: 'steps',
          progress: steps / 7000,
          color: HomeStyle.mint,
          onTap: () => openTracker(context, 'Steps'),
        ),
        HomeMetric(
          title: 'Sleep',
          value: sleepText,
          art: 'sleep',
          progress: sleep / 8,
          color: HomeStyle.violet,
          onTap: () => openTracker(context, 'Sleep'),
        ),
      ]),
      _responsiveRow(large, [
        const HomeMiniCalendar(),
        HomeGoals(water: waterText, steps: stepsText, sleep: sleepText),
      ]),
      const HomeJourney(),
      _responsiveRow(large, [const HomeAiCard(), const HomeDoctorCard()]),
      const HomeRecommendations(),
      Center(
        child: TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const LText('About this preview'),
              content: const LText(
                'Unlogged metrics, fertility dates, and the daily insight are sample content from the design reference. They are not personalized medical predictions. Saved check-ins replace the corresponding sample metric. Do not use cycle estimates for contraception. Doctor services are visual previews.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LText('Got it'),
                ),
              ],
            ),
          ),
          child: LText(
            'Demo preview · About these insights',
            style: HomeStyle.type(
              context,
              8,
              color: HomeStyle.secondary(context),
            ),
          ),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HomeStyle.dark(context)
                ? [
                    const Color(0xFF251B2B),
                    const Color(0xFF302033),
                    const Color(0xFF211E2B),
                  ]
                : [
                    const Color(0xFFFFF8FB),
                    const Color(0xFFFFF0EC),
                    const Color(0xFFFFF6F3),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: .35,
                  child: SvgPicture.asset(
                    'assets/home/botanical.svg',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    key: const PageStorageKey('home-scroll'),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                    children: [
                      for (final pair in sections.indexed)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: pair.$1 == 0 ? 0 : 7,
                          ),
                          child: HomeEntrance(order: pair.$1, child: pair.$2),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsiveRow(bool stack, List<Widget> children) => stack
      ? Column(
          children: [
            for (final child in children)
              Padding(padding: const EdgeInsets.only(bottom: 7), child: child),
          ],
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final pair in children.indexed) ...[
              if (pair.$1 > 0) const SizedBox(width: 7),
              Expanded(child: pair.$2),
            ],
          ],
        );
}
