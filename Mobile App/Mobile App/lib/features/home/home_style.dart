import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reference palette, scoped to Home so other screens retain their theme.
abstract final class HomeStyle {
  static const pink = Color(0xFFFF278B);
  static const plum = Color(0xFF820752);
  static const ink = Color(0xFF191541);
  static const muted = Color(0xFF7D72A1);
  static const violet = Color(0xFFAD62FF);
  static const mint = Color(0xFF32D6A0);
  static const blue = Color(0xFF29ABFF);
  static Color text(BuildContext context) =>
      dark(context) ? const Color(0xFFFFEFF8) : ink;
  static Color secondary(BuildContext context) =>
      dark(context) ? const Color(0xFFCEC1DC) : muted;
  static bool dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color accent(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    // The reference's brighter rose is retained for the default rose theme.
    return primary.r > primary.b ? pink : primary;
  }

  static double textHeight(
    BuildContext context,
    String text,
    double width,
    TextStyle style, {
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: context.tr(text), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  static TextStyle type(
    BuildContext context,
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.25,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontFamilyFallback: const ['NotoSansSinhala', 'NotoSansTamil'],
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: -.25,
    color: color ?? text(context),
  );
}

class HomeArt extends StatelessWidget {
  final String name;
  final double size;
  const HomeArt(this.name, {super.key, this.size = 32});
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/home/$name.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}

class HomePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  const HomePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.gradient,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: HomeStyle.pink.withValues(
            alpha: HomeStyle.dark(context) ? .03 : .065,
          ),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: HomeStyle.dark(context)
                ? Colors.white.withValues(alpha: .08)
                : Colors.white.withValues(alpha: .95),
          ),
          gradient:
              gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: HomeStyle.dark(context)
                    ? [const Color(0xFF332237), const Color(0xFF2B2335)]
                    : [
                        Colors.white.withValues(alpha: .91),
                        const Color(0xFFFFF8FA).withValues(alpha: .82),
                      ],
              ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}

class HomePress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String label;
  const HomePress({
    super.key,
    required this.child,
    required this.onTap,
    required this.label,
  });
  @override
  State<HomePress> createState() => _HomePressState();
}

class _HomePressState extends State<HomePress> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.tr(widget.label),
    child: AnimatedScale(
      scale: pressed ? .95 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onHighlightChanged: (v) => setState(() => pressed = v),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: widget.child,
      ),
    ),
  );
}

class HomeEntrance extends StatelessWidget {
  final Widget child;
  final int order;
  const HomeEntrance({super.key, required this.child, this.order = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: 350 + order * 45),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    ),
    child: child,
  );
}

class HomeHeading extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const HomeHeading(this.title, {super.key, this.onSeeAll});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: LText(
          title,
          style: HomeStyle.type(context, 12, weight: FontWeight.w700),
        ),
      ),
      if (onSeeAll != null)
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: Row(
              children: [
                LText(
                  'See All',
                  style: HomeStyle.type(
                    context,
                    10,
                    color: HomeStyle.accent(context),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: HomeStyle.accent(context),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class HomeCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool badge;
  const HomeCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.badge = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: HomeStyle.dark(context)
                  ? const Color(0xFF3B2A40)
                  : Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: HomeStyle.pink.withValues(alpha: .08),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: context.tr(label),
              onPressed: onTap,
              icon: Icon(icon, size: 21, color: HomeStyle.text(context)),
            ),
          ),
        ),
        if (badge)
          Positioned(
            right: 2,
            top: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: HomeStyle.pink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}
