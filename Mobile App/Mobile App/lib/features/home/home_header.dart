import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import 'home_style.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  const HomeHeader({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Semantics(
              label: context.tr('Herly. Her Life. Her Way.'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/brand/symbol.svg',
                    width: 43,
                    height: 43,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          'Herly',
                          style: HomeStyle.type(
                            context,
                            28,
                            weight: FontWeight.w800,
                            color: HomeStyle.accent(context),
                            height: 1,
                          ),
                        ),
                        LText(
                          'Her Life. Her Way.',
                          style: HomeStyle.type(
                            context,
                            6.5,
                            color: HomeStyle.accent(context),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          HomeCircleButton(
            icon: Icons.search_rounded,
            label: 'Search articles',
            onTap: () => context.push('/more/learn'),
          ),
          HomeCircleButton(
            icon: Icons.notifications_none_rounded,
            label: 'Reminders',
            badge: true,
            onTap: () => context.push('/more/reminders'),
          ),
          HomePress(
            label: 'My Profile',
            onTap: () => context.push('/more/profile'),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: Image.asset(
                  'assets/home/home-avatar.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      LayoutBuilder(
        builder: (context, c) {
          final large = (MediaQuery.textScalerOf(context).scale(12) > 16);
          final textWidth = c.maxWidth * .61;
          final needed =
              18 +
              HomeStyle.textHeight(
                context,
                '${context.tr('Good morning')},',
                textWidth,
                HomeStyle.type(context, 13, weight: FontWeight.w600),
              ) +
              HomeStyle.textHeight(
                context,
                name,
                textWidth - 30,
                HomeStyle.type(context, 25, weight: FontWeight.w800),
                maxLines: 1,
              ) +
              HomeStyle.textHeight(
                context,
                'You’re doing amazing!',
                textWidth - 20,
                HomeStyle.type(context, 11.5, weight: FontWeight.w700),
              ) +
              HomeStyle.textHeight(
                context,
                'Small steps create big changes.',
                textWidth,
                HomeStyle.type(context, 9.5),
              );
          final height = needed.clamp(102.0, double.infinity);
          return SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -8,
                  bottom: -18,
                  width: c.maxWidth * .65,
                  height: height + 30,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.transparent, Colors.white, Colors.white],
                      stops: [0, c.maxWidth < 340 ? .55 : .25, 1],
                    ).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/home/home-hero.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 8,
                  width: c.maxWidth * .61,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LText(
                        '${context.tr('Good morning')},',
                        style: HomeStyle.type(
                          context,
                          13,
                          weight: FontWeight.w600,
                          color: HomeStyle.dark(context)
                              ? const Color(0xFFFFB3D9)
                              : HomeStyle.plum,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HomeStyle.type(
                                context,
                                25,
                                weight: FontWeight.w800,
                                color: HomeStyle.dark(context)
                                    ? const Color(0xFFFFB3D9)
                                    : HomeStyle.plum,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const HomeArt('sun', size: 25),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: LText(
                              'You’re doing amazing!',
                              style: HomeStyle.type(
                                context,
                                11.5,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const HomeArt('flower', size: 17),
                        ],
                      ),
                      const SizedBox(height: 2),
                      LText(
                        'Small steps create big changes.',
                        style: HomeStyle.type(
                          context,
                          9.5,
                          color: HomeStyle.secondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!large)
                  Positioned(
                    right: 0,
                    bottom: 5,
                    child: Container(
                      width: 101,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: HomeStyle.dark(context)
                            ? const Color(0xED372139)
                            : const Color(0xF9FFF8FC),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .7),
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: LText(
                        '“A healthier, happier you\none day at a time.”',
                        textAlign: TextAlign.center,
                        style: HomeStyle.type(
                          context,
                          7.3,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
