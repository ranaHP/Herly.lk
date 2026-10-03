import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'strings.dart';
import 'theme.dart';

class HerlyPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget>? actions;
  const HerlyPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.actions,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: LText(
        context.tr(title),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: actions,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            if (subtitle != null) ...[
              LText(
                context.tr(subtitle!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
            ...children.expand((w) => [w, const SizedBox(height: 16)]),
          ],
        ),
      ),
    ),
  );
}

class HerlyCard extends StatelessWidget {
  final Widget child;
  final Color? tint;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const HerlyCard({
    super.key,
    required this.child,
    this.tint,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Material(
      color: tint?.withValues(alpha: .12) ?? c.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(HerlyTokens.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HerlyTokens.radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HerlyTokens.radius),
            border: Border.all(color: c.outlineVariant.withValues(alpha: .28)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class HerlyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool busy;
  final IconData? icon;
  const HerlyButton(
    this.label, {
    super.key,
    this.onPressed,
    this.secondary = false,
    this.busy = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final content = busy
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: LText(context.tr(label), textAlign: TextAlign.center),
              ),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(icon, size: 20),
              ],
            ],
          );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
    void action() {
      HapticFeedback.selectionClick();
      onPressed?.call();
    }

    return secondary
        ? OutlinedButton(
            onPressed: busy || onPressed == null ? null : action,
            style: style,
            child: content,
          )
        : FilledButton(
            onPressed: busy || onPressed == null ? null : action,
            style: style,
            child: content,
          );
  }
}

class Art extends StatelessWidget {
  final String name;
  final double size;
  const Art(this.name, {super.key, this.size = 72});
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/illustrations/$name.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}

class Brand extends StatelessWidget {
  final double width;
  final bool lightBackground;
  const Brand({super.key, this.width = 210, this.lightBackground = false});
  @override
  Widget build(BuildContext context) {
    final variant =
        Theme.of(context).brightness == Brightness.dark && !lightBackground
        ? 'logo-dark'
        : 'logo';
    final localized = Localizations.localeOf(context).languageCode != 'en';
    return Semantics(
      label: context.tr('Herly. Her Life. Her Way.'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/brand/$variant${localized ? '-wordmark' : ''}.svg',
            width: width,
            excludeFromSemantics: true,
          ),
          if (localized)
            SizedBox(
              width: width,
              child: LText(
                'Her Life. Her Way.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * .035,
                  color: lightBackground ? HerlyTokens.plum : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const Section(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: LText(
            context.tr(title),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class Metric extends StatelessWidget {
  final String value, label;
  final Color? color;
  const Metric(this.value, this.label, {super.key, this.color});
  @override
  Widget build(BuildContext context) => HerlyCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LText(
          value,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: color ?? Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 4),
        LText(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class ChoiceTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String? art;
  const ChoiceTile(
    this.title, {
    super.key,
    required this.selected,
    required this.onTap,
    this.art,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : HerlyTokens.motion,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: HerlyCard(
        onTap: onTap,
        tint: selected ? Theme.of(context).colorScheme.primary : null,
        child: Row(
          children: [
            if (art != null) ...[
              Art(art!, size: 42),
              const SizedBox(width: 12),
            ],
            Expanded(child: LText(context.tr(title))),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 21,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    ),
  );
}

void notify(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: LText(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

class ProgressCard extends StatelessWidget {
  final String title, value;
  final double progress;
  final Color color;
  final VoidCallback? onTap;
  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    this.color = HerlyTokens.lavender,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => HerlyCard(
    onTap: onTap,
    child: Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0, 1)),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 650),
            builder: (context, v, _) => CircularProgressIndicator(
              value: v,
              backgroundColor: color.withValues(alpha: .15),
              color: color,
              strokeWidth: 5,
              semanticsLabel: context.tr(title),
              semanticsValue: '${(v * 100).round()}%',
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(title, style: Theme.of(context).textTheme.titleMedium),
              LText(value),
            ],
          ),
        ),
        if (onTap != null) const Icon(Icons.add_circle_outline),
      ],
    ),
  );
}
