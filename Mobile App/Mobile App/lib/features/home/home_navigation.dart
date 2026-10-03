import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../tracking/tracker.dart';
import 'home_style.dart';

class HerlyHomeNavigation extends StatelessWidget {
  final StatefulNavigationShell shell;
  const HerlyHomeNavigation({super.key, required this.shell});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: HomeStyle.dark(context)
          ? const Color(0xFF271E2B)
          : const Color(0xFFFFFAFA),
      border: Border(
        top: BorderSide(color: HomeStyle.pink.withValues(alpha: .08)),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 1, 8, 4),
            child: Row(
              children: [
                _destination(
                  context,
                  0,
                  'Home',
                  Icons.home_outlined,
                  Icons.home_rounded,
                ),
                _destination(
                  context,
                  1,
                  'Calendar',
                  Icons.calendar_month_outlined,
                  Icons.calendar_month,
                ),
                _destination(
                  context,
                  2,
                  'Insights',
                  Icons.bar_chart_outlined,
                  Icons.bar_chart_rounded,
                ),
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: Transform.translate(
                      offset: const Offset(0, -8),
                      child: HomePress(
                        label: 'Quick check-in',
                        onTap: () => _quickCheckIn(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFA2CB), HomeStyle.pink],
                            ),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: HomeStyle.pink.withValues(alpha: .3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const HomeArt('petal', size: 31),
                        ),
                      ),
                    ),
                  ),
                ),
                _destination(
                  context,
                  3,
                  'Chat',
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                ),
                _destination(
                  context,
                  4,
                  'More',
                  Icons.menu_rounded,
                  Icons.menu_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _destination(
    BuildContext context,
    int index,
    String label,
    IconData icon,
    IconData selected,
  ) {
    final active = shell.currentIndex == index;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: label == 'Chat' ? 'Herly AI' : context.tr(label),
        child: InkWell(
          onTap: () => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: Icon(
                    active ? selected : icon,
                    key: ValueKey(active),
                    size: 22,
                    color: active
                        ? HomeStyle.accent(context)
                        : HomeStyle.secondary(context),
                  ),
                ),
                const SizedBox(height: 3),
                LText(
                  context.tr(label),
                  style: HomeStyle.type(
                    context,
                    8,
                    color: active
                        ? HomeStyle.accent(context)
                        : HomeStyle.secondary(context),
                    weight: active ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _quickCheckIn(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LText(
            'A moment for you',
            style: HomeStyle.type(context, 22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          for (final category in ['Period', 'Mood', 'Water'])
            ListTile(
              leading: HomeArt(
                category == 'Period' ? 'period' : category.toLowerCase(),
                size: 28,
              ),
              title: LText('Log $category'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(sheetContext);
                openTracker(context, category);
              },
            ),
        ],
      ),
    ),
  );
}
