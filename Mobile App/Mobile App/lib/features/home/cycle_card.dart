import '../../core/strings.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_style.dart';

class HomeCycleCard extends StatelessWidget {
  final int days, day, length;
  final String date;
  final bool enabled, isDemo;
  const HomeCycleCard({
    super.key,
    required this.days,
    required this.day,
    required this.length,
    required this.date,
    required this.enabled,
    required this.isDemo,
  });
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.all(8),
    gradient: LinearGradient(
      colors: HomeStyle.dark(context)
          ? [const Color(0xFF48213E), const Color(0xFF302132)]
          : [
              const Color(0xFFFFFCFD),
              const Color(0xFFFFE9F0),
              const Color(0xFFFFF7FA),
            ],
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final stacked =
            c.maxWidth < 300 ||
            (MediaQuery.textScalerOf(context).scale(12) > 16);
        final overview = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LText(
              enabled ? 'Your next period in' : 'Your daily wellbeing',
              style: HomeStyle.type(context, 9, weight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            LText(
              enabled ? (days >= 0 ? '$days days' : 'Check in') : 'Your rhythm',
              style: HomeStyle.type(
                context,
                25,
                weight: FontWeight.w800,
                color: HomeStyle.accent(context),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            LText(
              enabled ? date : 'A little time for you',
              style: HomeStyle.type(
                context,
                11,
                color: HomeStyle.secondary(context),
              ),
            ),
            const SizedBox(height: 3),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 24),
              child: OutlinedButton(
                onPressed: () => context.go('/calendar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  side: BorderSide(color: HomeStyle.accent(context)),
                  minimumSize: const Size(0, 24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: LText(
                        'View Calendar',
                        style: HomeStyle.type(
                          context,
                          9,
                          color: HomeStyle.accent(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: HomeStyle.accent(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        final ring = CycleRing(day: day, length: length, enabled: enabled);
        final legend = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legend(
              context,
              HomeStyle.pink,
              'Period',
              enabled ? '$days days' : 'Not tracked',
            ),
            const SizedBox(height: 7),
            _legend(
              context,
              HomeStyle.violet,
              'Fertile window',
              enabled && isDemo ? 'Nov 2 – 6' : 'Not enabled',
            ),
            const SizedBox(height: 7),
            _legend(
              context,
              const Color(0xFFFFBC41),
              'Ovulation',
              enabled && isDemo ? 'Nov 4 (est.)' : 'Not enabled',
            ),
          ],
        );
        if (stacked) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: overview),
                  ring,
                ],
              ),
              const SizedBox(height: 12),
              legend,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 14, child: overview),
            const SizedBox(width: 6),
            ring,
            const SizedBox(width: 12),
            Expanded(flex: 11, child: legend),
          ],
        );
      },
    ),
  );
  Widget _legend(
    BuildContext context,
    Color color,
    String title,
    String value,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color.withValues(alpha: .5), color],
          ),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .25), blurRadius: 5),
          ],
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LText(
              title,
              style: HomeStyle.type(context, 8.5, weight: FontWeight.w700),
            ),
            LText(
              value,
              style: HomeStyle.type(
                context,
                9,
                color: HomeStyle.secondary(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class CycleRing extends StatelessWidget {
  final int day, length;
  final bool enabled;
  const CycleRing({
    super.key,
    required this.day,
    required this.length,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.tr(
      enabled ? 'Cycle day $day of $length' : 'Cycle tracking is off',
    ),
    child: SizedBox(
      width: 82,
      height: 82,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: enabled ? (day / length).clamp(0, 1) : 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(value, HomeStyle.accent(context)),
          child: child,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HomeArt('flower', size: 20),
            const SizedBox(height: 3),
            LText(
              enabled ? 'Day $day' : 'Your pace',
              style: HomeStyle.type(context, 11, weight: FontWeight.w800),
            ),
            LText(
              enabled ? 'of $length' : 'Always',
              style: HomeStyle.type(
                context,
                9,
                color: HomeStyle.secondary(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color accent;
  _RingPainter(this.value, this.accent);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    paint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: math.pi * 1.5,
      colors: [
        accent,
        const Color(0xFFFF84AE),
        const Color(0xFFFFD9A8),
        accent,
      ],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);
    canvas.drawOval(rect, paint);
    final angle = -math.pi / 2 + 2 * math.pi * value;
    final center = Offset(size.width / 2, size.height / 2);
    final point =
        center +
        Offset(math.cos(angle), math.sin(angle)) * (size.width / 2 - 5);
    canvas.drawCircle(point, 3.6, Paint()..color = Colors.white);
    canvas.drawCircle(point, 2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.accent != accent;
}
