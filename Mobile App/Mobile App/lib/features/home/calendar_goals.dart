import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'home_data.dart';
import 'home_style.dart';

class HomeMiniCalendar extends StatefulWidget {
  const HomeMiniCalendar({super.key});
  @override
  State<HomeMiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<HomeMiniCalendar> {
  DateTime selected = DateTime(2026, 10, 27);
  late DateTime month = DateTime(selected.year, selected.month);
  void changeMonth(int delta) => setState(() {
    month = DateTime(month.year, month.month + delta);
    selected = DateTime(month.year, month.month, 27);
  });
  @override
  Widget build(BuildContext context) {
    final first = selected.subtract(Duration(days: selected.weekday % 7));
    return HomePanel(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _arrow(
                context,
                Icons.chevron_left,
                'Previous month',
                () => changeMonth(-1),
              ),
              Expanded(
                child: LText(
                  DateFormat.yMMMM(Localizations.localeOf(context).languageCode)
                      .format(month),
                  textAlign: TextAlign.center,
                  style: HomeStyle.type(context, 10, weight: FontWeight.w700),
                ),
              ),
              _arrow(
                context,
                Icons.chevron_right,
                'Next month',
                () => changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              for (final label in List.generate(
                7,
                (i) =>
                    DateFormat.E(Localizations.localeOf(context).languageCode)
                        .format(DateTime(2026, 10, 4 + i)),
              ))
                Expanded(
                  child: LText(
                    label,
                    textAlign: TextAlign.center,
                    style: HomeStyle.type(
                      context,
                      8,
                      color: HomeStyle.secondary(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: List.generate(7, (i) {
              final date = first.add(Duration(days: i));
              final active = date == selected;
              return Expanded(
                child: Semantics(
                  selected: active,
                  button: true,
                  label: DateFormat.yMMMMd(
                    Localizations.localeOf(context).languageCode,
                  ).format(date),
                  child: InkWell(
                    onTap: () => setState(() => selected = date),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFFFF93C1), HomeStyle.pink],
                              )
                            : null,
                        border: active ? Border.all(color: Colors.white) : null,
                      ),
                      child: LText(
                        '${date.day}',
                        style: HomeStyle.type(
                          context,
                          9,
                          color: active ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const HomeArt('period', size: 15),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton.filled(
                  tooltip: context.tr('Open selected calendar date'),
                  onPressed: () => context.go(
                    '/calendar?date=${DateFormat('yyyy-MM-dd').format(selected)}',
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: HomeStyle.accent(context),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 19),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _arrow(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback action,
  ) => SizedBox(
    width: 25,
    height: 25,
    child: IconButton(
      tooltip: context.tr(label),
      onPressed: action,
      padding: EdgeInsets.zero,
      icon: Icon(
        icon,
        size: 18,
        color: HomeStyle.dark(context) ? HomeStyle.pink : HomeStyle.plum,
      ),
    ),
  );
}

class HomeGoals extends ConsumerWidget {
  final String water, steps, sleep;
  const HomeGoals({
    super.key,
    required this.water,
    required this.steps,
    required this.sleep,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(homeGoalsProvider);
    return HomePanel(
      padding: const EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: HomeStyle.accent(context),
                size: 19,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'Today’s Goal',
                      style: HomeStyle.type(
                        context,
                        11,
                        weight: FontWeight.w700,
                        color: HomeStyle.dark(context)
                            ? const Color(0xFFFFB2D4)
                            : HomeStyle.plum,
                      ),
                    ),
                    LText(
                      '${values.where((v) => v).length} of 4 done',
                      style: HomeStyle.type(
                        context,
                        8,
                        color: HomeStyle.accent(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.verified_user_rounded,
                size: 18,
                color: const Color(0xFFFF7696),
              ),
            ],
          ),
          const SizedBox(height: 5),
          for (final pair in [
            'Drink $water cups',
            'Step goal $steps',
            'Sleep $sleep',
            'Self-care time',
          ].indexed)
            Semantics(
              checked: values[pair.$1],
              label: context.tr(pair.$2),
              child: InkWell(
                onTap: () =>
                    ref.read(homeGoalsProvider.notifier).toggle(pair.$1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: values[pair.$1]
                              ? HomeStyle.mint
                              : Colors.transparent,
                          border: Border.all(
                            color: values[pair.$1]
                                ? const Color(0xFF18C895)
                                : HomeStyle.muted,
                          ),
                        ),
                        child: values[pair.$1]
                            ? const Icon(
                                Icons.check,
                                size: 11,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: LText(
                          pair.$2,
                          style: HomeStyle.type(
                            context,
                            8.5,
                            color: HomeStyle.secondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
