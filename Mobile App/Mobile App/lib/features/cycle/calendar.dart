import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/strings.dart';
import '../home/home_style.dart';
import '../home/cycle_card.dart';
import '../shared/reference_ui.dart';
import '../tracking/tracker.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const CalendarScreen({super.key, this.initialDate});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<CalendarScreen> {
  late DateTime month, selected;
  bool get demo =>
      ref.read(preferencesProvider).getString('lastPeriod') == null &&
      ref.read(trackingProvider).isEmpty;
  @override
  void initState() {
    super.initState();
    selected = dateOnly(
      widget.initialDate ?? (demo ? DateTime(2026, 10, 27) : DateTime.now()),
    );
    month = DateTime(selected.year, selected.month);
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null &&
        widget.initialDate != oldWidget.initialDate) {
      select(widget.initialDate!);
    }
  }

  void select(DateTime date) => setState(() {
    selected = dateOnly(date);
    month = DateTime(date.year, date.month);
  });
  void move(int delta) =>
      setState(() => month = DateTime(month.year, month.month + delta));
  String date(DateTime d, [String pattern = 'yMMMd']) => DateFormat(
    pattern,
    Localizations.localeOf(context).languageCode,
  ).format(d);
  Future<void> picker() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) select(d);
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(trackingProvider);
    final cycle = ref.watch(cycleProvider);
    final enabled =
        ref.read(preferencesProvider).getString('cycleType') !=
        'I don’t get periods';
    final isDemo = demo && enabled;
    final shown = logs.where((e) => dateOnly(e.date) == selected).toList();
    final day = isDemo
        ? selected.difference(DateTime(2026, 10, 27)).inDays % 28 + 1
        : cycle.dayOfCycle(selected);
    final period =
        enabled &&
        ((isDemo && day <= 5) || shown.any((e) => e.category == 'Period'));
    final next = isDemo ? DateTime(2026, 11, 24) : cycle.nextPeriod;
    final roomy = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ReferenceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                children: [
                  Row(
                    children: [
                      ReferenceButton(
                        Icons.chevron_left,
                        'Back to Home',
                        () => context.go('/home'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReferenceLabel(
                          date(month, 'yMMMM'),
                          size: 19,
                          bold: true,
                        ),
                      ),
                      TextButton(
                        onPressed: () => select(DateTime.now()),
                        style: TextButton.styleFrom(
                          backgroundColor: HomeStyle.pink.withValues(
                            alpha: .05,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: ReferenceLabel(
                          'Today',
                          size: 10,
                          color: HomeStyle.accent(context),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ReferenceButton(
                        Icons.calendar_month_outlined,
                        'Choose date',
                        picker,
                      ),
                      const SizedBox(width: 5),
                      ReferenceButton(
                        Icons.more_horiz,
                        'Calendar settings',
                        () => context.push('/more/health'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _grid(logs, cycle, isDemo, enabled),
                  HomePanel(
                    padding: const EdgeInsets.all(9),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        for (final e in [
                          ('Period', HomeStyle.pink),
                          ('Fertile Window', HomeStyle.violet),
                          ('Ovulation', Color(0xFF902AFF)),
                          ('Special Day', Color(0xFFFF68A9)),
                          ('Symptoms', Color(0xFFFFBB18)),
                          ('Notes', Color(0xFFB8B3CF)),
                        ])
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: e.$2,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 3),
                              ReferenceLabel(e.$1, size: 7),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  HomeEntrance(
                    child: HomePanel(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: HomeStyle.accent(context),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ReferenceLabel(
                                  isDemo
                                      ? 'Demo'
                                      : selected == dateOnly(DateTime.now())
                                      ? 'Today'
                                      : 'Selected day',
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ReferenceLabel(
                                  date(selected, 'yMMMEd'),
                                  size: 10,
                                  muted: true,
                                ),
                              ),
                              ReferenceButton(
                                Icons.chevron_right,
                                'Next day',
                                () => select(
                                  selected.add(const Duration(days: 1)),
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              Positioned(
                                right: -10,
                                bottom: -25,
                                width: 150,
                                height: 145,
                                child: Opacity(
                                  opacity: roomy ? .22 : 1,
                                  child: Image.asset(
                                    'assets/home/home-hero.png',
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const HomeArt('period', size: 37),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ReferenceLabel(
                                            period
                                                ? 'Period Day $day'
                                                : 'Your daily wellbeing',
                                            size: 16,
                                            bold: true,
                                            color: HomeStyle.dark(context)
                                                ? const Color(0xFFFFABD4)
                                                : HomeStyle.plum,
                                          ),
                                          const SizedBox(height: 2),
                                          const ReferenceLabel(
                                            'Take it easy and be kind to yourself.',
                                            size: 10,
                                            muted: true,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 7,
                            children: [
                              for (final e in [
                                (
                                  'period',
                                  'Flow',
                                  period
                                      ? (shown
                                                .where(
                                                  (e) => e.category == 'Period',
                                                )
                                                .firstOrNull
                                                ?.value ??
                                            (isDemo ? 'Medium' : 'Not logged'))
                                      : 'Not logged',
                                ),
                                (
                                  'symptoms',
                                  'Cramps',
                                  isDemo ? 'Mild' : 'Not logged',
                                ),
                                (
                                  'mood',
                                  'Mood',
                                  shown
                                          .where((e) => e.category == 'Mood')
                                          .firstOrNull
                                          ?.value ??
                                      (isDemo ? 'Calm' : 'Not logged'),
                                ),
                                (
                                  'battery',
                                  'Energy',
                                  shown
                                          .where((e) => e.category == 'Energy')
                                          .firstOrNull
                                          ?.value ??
                                      (isDemo ? 'Low' : 'Not logged'),
                                ),
                              ])
                                SizedBox(
                                  width: roomy ? 85 : 51,
                                  child: HomePanel(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 3,
                                    ),
                                    onTap: () => openTracker(
                                      context,
                                      e.$2 == 'Flow'
                                          ? 'Period'
                                          : e.$2 == 'Cramps'
                                          ? 'Symptoms'
                                          : e.$2,
                                    ),
                                    child: Column(
                                      children: [
                                        HomeArt(e.$1, size: 22),
                                        ReferenceLabel(
                                          e.$2,
                                          size: 8,
                                          align: TextAlign.center,
                                        ),
                                        ReferenceLabel(
                                          e.$3,
                                          size: 8,
                                          align: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              OutlinedButton(
                                onPressed: () {
                                  final target =
                                      selected.isAfter(dateOnly(DateTime.now()))
                                      ? dateOnly(DateTime.now())
                                      : selected;
                                  if (target != selected) select(target);
                                  openTracker(context, 'Period', date: target);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: HomeStyle.accent(context),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReferenceLabel(
                                      'Log Today',
                                      size: 10,
                                      color: HomeStyle.accent(context),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.add,
                                      size: 17,
                                      color: HomeStyle.accent(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          for (final log in shown)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReferenceLabel(
                                    '${context.tr(log.category)} · ${context.tr(log.value)}',
                                    size: 11,
                                    bold: true,
                                  ),
                                  if (log.symptoms.isNotEmpty)
                                    ReferenceLabel(
                                      log.symptoms.map(context.tr).join(', '),
                                    ),
                                  if (log.notes.isNotEmpty) Text(log.notes),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  HomePanel(
                    onTap: () => context.go('/insights'),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const HomeArt('insight', size: 42),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReferenceLabel(
                                'Today’s Insights',
                                size: 12,
                                bold: true,
                              ),
                              ReferenceLabel(
                                'Your energy may be lower today. Try gentle movement, stay hydrated and consider iron-rich foods.',
                                size: 9.5,
                                muted: true,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 19),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  if (enabled)
                    LayoutBuilder(
                      builder: (context, c) {
                        final phase = HomePanel(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ReferenceLabel(
                                'Cycle Phase',
                                size: 11,
                                bold: true,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CycleRing(day: day, length: cycle.length),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ReferenceLabel(
                                          period
                                              ? 'Menstrual Phase'
                                              : 'Your cycle',
                                          size: 11,
                                          bold: true,
                                          color: HomeStyle.accent(context),
                                        ),
                                        const SizedBox(height: 4),
                                        ReferenceLabel(
                                          period
                                              ? 'Your period has started. This phase usually lasts 3–7 days.'
                                              : 'Keep logging to understand your pattern.',
                                          size: 9,
                                          muted: true,
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              context.push('/article/0'),
                                          child: ReferenceLabel(
                                            'Learn More →',
                                            size: 9,
                                            color: HomeStyle.accent(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                        final upcoming = Column(
                          children: [
                            HomePanel(
                              onTap: () => select(next),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  const HomeArt('calendar', size: 30),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ReferenceLabel(
                                          'Next Period',
                                          size: 9,
                                        ),
                                        ReferenceLabel(
                                          'In ${next.difference(selected).inDays} days',
                                          size: 11,
                                          bold: true,
                                          color: HomeStyle.accent(context),
                                        ),
                                        ReferenceLabel(
                                          date(next, 'yMMMEd'),
                                          size: 8,
                                          muted: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            HomePanel(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  const HomeArt('flower', size: 30),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ReferenceLabel(
                                          'Fertile Window',
                                          size: 10,
                                        ),
                                        ReferenceLabel(
                                          isDemo
                                              ? 'Nov 2 – Nov 6'
                                              : 'Not enabled',
                                          size: 9,
                                          muted: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                        return roomy || c.maxWidth < 330
                            ? Column(
                                children: [
                                  phase,
                                  const SizedBox(height: 8),
                                  upcoming,
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: phase),
                                  const SizedBox(width: 8),
                                  Expanded(flex: 4, child: upcoming),
                                ],
                              );
                      },
                    ),
                  const SizedBox(height: 9),
                  if (isDemo)
                    ReferenceSection(
                      'Upcoming Events',
                      art: 'calendar',
                      child: _tiles([
                        ('period', 'Oct 27', 'Period Start'),
                        ('consultation', 'Oct 31', 'Doctor Appt'),
                        ('flower', 'Nov 4', 'Ovulation (est.)'),
                        ('heart', 'Nov 15', 'Date Night'),
                        ('calendar', 'Nov 24', 'Next Period'),
                      ], roomy),
                    ),
                  const SizedBox(height: 9),
                  ReferenceSection(
                    'Daily Care Suggestions',
                    art: 'heart',
                    child: _tiles([
                      ('water', 'Stay', 'hydrated'),
                      ('nutrition', 'Eat iron-rich', 'foods'),
                      ('exercise', 'Try light', 'movement'),
                      ('sleep', 'Get extra', 'rest'),
                    ], roomy),
                  ),
                  const SizedBox(height: 9),
                  const ReferenceArticles(),
                  const SizedBox(height: 12),
                  ReferenceLabel(
                    isDemo
                        ? 'Sample calendar · Illustrative estimates, not for contraception.'
                        : 'Calendar estimates are illustrative, can be inaccurate, and must not be used for contraception.',
                    size: 9,
                    muted: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tiles(
    List<(String, String, String)> items,
    bool roomy,
  ) => LayoutBuilder(
    builder: (context, c) => Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final pair in items.indexed)
          SizedBox(
            width: roomy
                ? (c.maxWidth - 6) / 2
                : (c.maxWidth - (items.length - 1) * 6) / items.length,
            child: HomePanel(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              gradient: LinearGradient(
                colors: HomeStyle.dark(context)
                    ? [const Color(0xFF433049), const Color(0xFF36263C)]
                    : [
                        pair.$1.isEven
                            ? const Color(0xFFFFE6F0)
                            : const Color(0xFFEEEBFF),
                        const Color(0xFFFFF6FA),
                      ],
              ),
              onTap: () => context.push('/more/learn'),
              child: Column(
                children: [
                  HomeArt(pair.$2.$1, size: 24),
                  const SizedBox(height: 4),
                  ReferenceLabel(
                    pair.$2.$2,
                    size: 8.5,
                    align: TextAlign.center,
                  ),
                  ReferenceLabel(pair.$2.$3, size: 8, align: TextAlign.center),
                ],
              ),
            ),
          ),
      ],
    ),
  );
  Widget _grid(
    List<TrackingEntry> logs,
    CycleEstimate cycle,
    bool isDemo,
    bool enabled,
  ) {
    final first = DateTime(month.year, month.month);
    final offset = first.weekday % 7;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final referenceMonth = isDemo && month.year == 2026 && month.month == 10;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Column(
                  children: [
                    ReferenceLabel(
                      date(DateTime(2026, 10, 4 + i), 'E'),
                      size: 9,
                      muted: true,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 24,
              child: ReferenceButton(
                Icons.chevron_left,
                'Previous month',
                () => move(-1),
              ),
            ),
            SizedBox(
              height: 24,
              child: ReferenceButton(
                Icons.chevron_right,
                'Next month',
                () => move(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ((offset + count) / 7).ceil() * 7,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? 42
                : 31,
          ),
          itemBuilder: (context, i) {
            final d = DateTime(month.year, month.month, i - offset + 1);
            final n = d.day;
            final inside = d.month == month.month;
            final active = d == selected;
            final dayLogs = logs.where((e) => dateOnly(e.date) == d);
            final logged = dayLogs.any((e) => e.category == 'Period');
            final pink =
                enabled &&
                (logged || (referenceMonth && [5, 6, 7].contains(n) && inside));
            final fertile =
                referenceMonth && inside && [15, 16, 17].contains(n);
            final marker =
                dayLogs.isNotEmpty ||
                (referenceMonth &&
                    inside &&
                    [
                      2,
                      3,
                      4,
                      5,
                      6,
                      7,
                      8,
                      14,
                      15,
                      18,
                      19,
                      20,
                      21,
                      23,
                      26,
                      27,
                      28,
                      29,
                      30,
                    ].contains(n));
            final color = active
                ? HomeStyle.pink
                : fertile && n == 16
                ? HomeStyle.violet
                : pink
                ? const Color(0xFFFFDEEB)
                : fertile
                ? const Color(0xFFECDFFF)
                : Colors.transparent;
            return Semantics(
              selected: active,
              button: true,
              label: date(d, 'yMMMMEEEEd'),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => select(d),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(30),
                    border: active ? Border.all(color: Colors.white) : null,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: HomeStyle.pink.withValues(alpha: .25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReferenceLabel(
                        '$n',
                        size: 12,
                        bold: active,
                        color: active || fertile && n == 16
                            ? Colors.white
                            : !inside
                            ? HomeStyle.muted.withValues(alpha: .5)
                            : null,
                      ),
                      if (marker)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? Colors.white
                                : fertile
                                ? HomeStyle.violet
                                : n == 23
                                ? Colors.amber
                                : n == 30
                                ? Colors.teal
                                : HomeStyle.pink,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 9),
      ],
    );
  }
}
