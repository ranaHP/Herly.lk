import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../home/home_style.dart';

class ReferenceBackground extends StatelessWidget {
  final Widget child;
  const ReferenceBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: HomeStyle.dark(context)
            ? [const Color(0xFF241A2B), const Color(0xFF352139)]
            : [
                const Color(0xFFFFFCFB),
                const Color(0xFFFDEBF1),
                const Color(0xFFFFF8F3),
              ],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: 160,
          left: -70,
          child: Opacity(opacity: .17, child: HomeArt('botanical', size: 290)),
        ),
        Positioned(
          top: 300,
          right: -110,
          child: Opacity(opacity: .15, child: HomeArt('botanical', size: 350)),
        ),
        child,
      ],
    ),
  );
}

class ReferenceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ReferenceButton(this.icon, this.label, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: HomeStyle.dark(context)
          ? const Color(0xFF422E49)
          : Colors.white.withValues(alpha: .9),
      boxShadow: [
        BoxShadow(
          color: HomeStyle.pink.withValues(alpha: .08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      tooltip: context.tr(label),
      icon: Icon(icon, size: 20, color: HomeStyle.text(context)),
      onPressed: onTap,
    ),
  );
}

class ReferenceLabel extends StatelessWidget {
  final String text;
  final double size;
  final bool bold, muted;
  final Color? color;
  final TextAlign? align;
  const ReferenceLabel(
    this.text, {
    super.key,
    this.size = 11,
    this.bold = false,
    this.muted = false,
    this.color,
    this.align,
  });
  @override
  Widget build(BuildContext context) => Text(
    context.tr(text),
    textAlign: align,
    style: HomeStyle.type(
      context,
      size,
      height: 1.35,
      weight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color ?? (muted ? HomeStyle.secondary(context) : null),
    ),
  );
}

class ReferenceSection extends StatelessWidget {
  final String title;
  final Widget child;
  final String? art;
  const ReferenceSection(
    this.title, {
    super.key,
    required this.child,
    this.art,
  });
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.all(9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (art != null) ...[
              HomeArt(art!, size: 18),
              const SizedBox(width: 6),
            ],
            Expanded(child: ReferenceLabel(title, size: 11, bold: true)),
            TextButton(
              onPressed: () => context.push('/more/learn'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(34, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: ReferenceLabel(
                'See All',
                size: 9,
                color: HomeStyle.accent(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        child,
      ],
    ),
  );
}

class ReferenceArticles extends StatelessWidget {
  const ReferenceArticles({super.key});
  @override
  Widget build(BuildContext context) => ReferenceSection(
    'Recommended Articles',
    art: 'calendar',
    child: SizedBox(
      height: 180 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2.5),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          const items = [
            ('How to manage period cramps naturally', 'article-cycle', 0, 5),
            ('Iron-rich foods for your period', 'article-food', 3, 4),
            ('Easy exercises during your period', 'article-mindful', 2, 5),
            ('Mood changes during your cycle', 'article-sleep', 1, 6),
          ];
          final item = items[i];
          return SizedBox(
            width: 94,
            child: HomePanel(
              padding: EdgeInsets.zero,
              onTap: () => context.push('/article/${item.$3}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/home/${item.$2}.png',
                    height: 45,
                    width: 94,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReferenceLabel(item.$1, size: 8.5),
                        const SizedBox(height: 4),
                        ReferenceLabel(
                          '${item.$4} min read',
                          size: 8,
                          muted: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
