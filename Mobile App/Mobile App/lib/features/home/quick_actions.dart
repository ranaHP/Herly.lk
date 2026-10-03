import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tracking/tracker.dart';
import 'home_data.dart';
import 'home_style.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
    child: LayoutBuilder(
      builder: (context, c) {
        final columns = MediaQuery.textScalerOf(context).scale(12) > 16 ? 3 : 5;
        return Wrap(
          runSpacing: 6,
          children: HomeDemo.quickActions
              .map(
                (item) => SizedBox(
                  width: c.maxWidth / columns,
                  child: HomePress(
                    label: item.$1,
                    onTap: () {
                      if (item.$3.startsWith('/')) {
                        context.push(item.$3);
                      } else {
                        openTracker(context, item.$3);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(item.$4).withValues(
                                alpha: HomeStyle.dark(context) ? .16 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: HomeArt(item.$2, size: 28),
                          ),
                          const SizedBox(height: 2),
                          LText(
                            item.$1,
                            textAlign: TextAlign.center,
                            style: HomeStyle.type(
                              context,
                              8.5,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}

class HomeInsight extends StatelessWidget {
  const HomeInsight({super.key});
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    onTap: () => context.go('/insights'),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFF1DC),
          ),
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: HomeArt('insight'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                'Today’s Insight',
                style: HomeStyle.type(
                  context,
                  11,
                  weight: FontWeight.w800,
                  color: HomeStyle.dark(context)
                      ? const Color(0xFFFFB2D4)
                      : HomeStyle.plum,
                ),
              ),
              const SizedBox(height: 2),
              LText(
                'Your energy may be slightly lower today.\nTry some light exercise and stay hydrated.',
                style: HomeStyle.type(
                  context,
                  8.5,
                  color: HomeStyle.secondary(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 19, color: HomeStyle.text(context)),
      ],
    ),
  );
}

class HomeMetric extends StatelessWidget {
  final String title, value, art;
  final double progress;
  final Color color;
  final VoidCallback onTap;
  const HomeMetric({
    super.key,
    required this.title,
    required this.value,
    required this.art,
    required this.progress,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.all(7),
    onTap: onTap,
    child: Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 27,
              height: 27,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 4,
                    color: color,
                    backgroundColor: color.withValues(alpha: .15),
                  ),
                  HomeArt(art, size: 22),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    title,
                    style: HomeStyle.type(context, 8, weight: FontWeight.w700),
                  ),
                  LText(
                    value,
                    style: HomeStyle.type(context, 9, weight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0, 1)),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 800),
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              color: color,
              backgroundColor: HomeStyle.dark(context)
                  ? const Color(0xFF543A52)
                  : const Color(0xFFF0E4EC),
            ),
          ),
        ),
      ],
    ),
  );
}
