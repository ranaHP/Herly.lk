import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});
  @override
  ConsumerState<InsightsScreen> createState() => _InsightsState();
}

class _InsightsState extends ConsumerState<InsightsScreen> {
  String tab = 'Cycle';
  @override
  void initState() {
    super.initState();
    if (ref.read(preferencesProvider).getString('cycleType') ==
        'I don’t get periods') {
      tab = 'Mood';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(cycleProvider);
    final cycleEnabled =
        ref.read(preferencesProvider).getString('cycleType') !=
        'I don’t get periods';
    final entries = ref.watch(trackingProvider);
    final category = switch (tab) {
      'Cycle' => 'Period',
      'Body' => 'Energy',
      _ => tab,
    };
    final filtered = entries.where((e) => e.category == category).toList();
    return HerlyPage(
      title: 'Insights',
      subtitle: 'Patterns to reflect on. A story only you can tell.',
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final value in [
              if (cycleEnabled) 'Cycle',
              'Mood',
              'Body',
              'Sleep',
            ])
              ChoiceChip(
                label: LText(value),
                selected: tab == value,
                onSelected: (_) => setState(() => tab = value),
              ),
          ],
        ),
        HerlyCard(
          tint: HerlyTokens.lavender,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'YOUR $tab STORY'.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(letterSpacing: 1.8),
                    ),
                    const SizedBox(height: 16),
                    LText(
                      tab == 'Cycle'
                          ? 'Every rhythm\nis personal.'
                          : 'Notice. Reflect.\nUnderstand.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    LText(
                      tab == 'Cycle'
                          ? 'Cycle day ${cycle.dayOfCycle(DateTime.now())} · based on your dates'
                          : trackingInsight(entries),
                    ),
                  ],
                ),
              ),
              Art(
                tab == 'Cycle'
                    ? 'cycle'
                    : tab == 'Sleep'
                    ? 'sleep'
                    : 'mood',
                size: 84,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Metric(
                tab == 'Cycle' ? '${cycle.length} days' : '${filtered.length}',
                tab == 'Cycle' ? 'Configured cycle' : 'Your entries',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Metric(
                tab == 'Cycle'
                    ? '${cycle.duration} days'
                    : filtered.isEmpty
                    ? '—'
                    : filtered.last.value,
                tab == 'Cycle' ? 'Configured period' : 'Latest entry',
                color: HerlyTokens.lavender,
              ),
            ),
          ],
        ),
        Section('$tab over time'),
        DemoChart(tab: tab),
        const HerlyCard(
          child: LText(
            'This chart uses sample values to demonstrate the design. Your saved entries appear below. No medical correlations or diagnoses are inferred.',
          ),
        ),
        const Section('Your observations'),
        if (filtered.isEmpty)
          const HerlyCard(
            child: Column(
              children: [
                Art('empty'),
                SizedBox(height: 12),
                LText('Your patterns start here'),
                LText('Log a few check-ins to see your own observations.'),
              ],
            ),
          ),
        ...filtered.reversed
            .take(5)
            .map(
              (e) => HerlyCard(
                child: Row(
                  children: [
                    Expanded(child: LText(e.value)),
                    LText(
                      '${e.date.day}/${e.date.month}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class DemoChart extends StatelessWidget {
  final String tab;
  const DemoChart({super.key, required this.tab});
  @override
  Widget build(BuildContext context) {
    const values = [.3, .65, .5, .8, .4, .55, .75, .9, .65, .45, .8, .6];
    return HerlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LText(
            'ILLUSTRATIVE DEMO CHART',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final end =
                    values[(i +
                            ['Cycle', 'Mood', 'Body', 'Sleep'].indexOf(tab)) %
                        12];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: end),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 600),
                      builder: (context, value, _) => Container(
                        height: 130 * value,
                        decoration: BoxDecoration(
                          color:
                              (i > 8
                                      ? HerlyTokens.lavender
                                      : Theme.of(context).colorScheme.primary)
                                  .withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [LText('Earlier'), LText('Recent')],
          ),
        ],
      ),
    );
  }
}
