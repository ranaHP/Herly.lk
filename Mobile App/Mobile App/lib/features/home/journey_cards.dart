import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_style.dart';
import 'home_data.dart';

class HomeJourney extends StatelessWidget {
  const HomeJourney({super.key});
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
    child: Column(
      children: [
        HomeHeading(
          'Tools for Your Journey',
          onSeeAll: () => context.push('/more/health'),
        ),
        LayoutBuilder(
          builder: (context, c) {
            final columns = MediaQuery.textScalerOf(context).scale(12) > 16
                ? 2
                : 4;
            return Wrap(
              runSpacing: 8,
              children: [
                for (final item in [
                  ('Track\nYour Cycle', 'calendar', '/calendar', 0xFFF7E3FB),
                  ('Plan\nYour Goals', 'goals', '/more/goals', 0xFFFFE9EF),
                  (
                    'Set\nReminders',
                    'reminders',
                    '/more/reminders',
                    0xFFF0E9FF,
                  ),
                  ('Ask\nHerly AI', 'home-robot', '/ai', 0xFFFCE6F3),
                ])
                  SizedBox(
                    width: c.maxWidth / columns,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: HomePress(
                        label: item.$1.replaceAll('\n', ' '),
                        onTap: () => item.$3 == '/calendar' || item.$3 == '/ai'
                            ? context.go(item.$3)
                            : context.push(item.$3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(item.$4).withValues(
                              alpha: HomeStyle.dark(context) ? .12 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              item.$2 == 'home-robot'
                                  ? Image.asset(
                                      'assets/home/home-robot.png',
                                      height: 38,
                                      width: 44,
                                      fit: BoxFit.contain,
                                      excludeFromSemantics: true,
                                    )
                                  : HomeArt(item.$2, size: 38),
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
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class HomeAiCard extends StatelessWidget {
  const HomeAiCard({super.key});
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: EdgeInsets.zero,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFA32B94), Color(0xFFBB6BC7), Color(0xFF79296B)],
    ),
    onTap: () => context.go('/ai'),
    child: LayoutBuilder(
      builder: (context, c) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 86),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              bottom: -17,
              width: c.maxWidth * .68,
              height: 112,
              child: Image.asset(
                'assets/home/home-robot.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    'Herly AI',
                    style: HomeStyle.type(
                      context,
                      16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: c.maxWidth * .57,
                    child: LText(
                      'Your private wellbeing companion',
                      style: HomeStyle.type(
                        context,
                        8,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF87BB), HomeStyle.pink],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: LText(
                            'Chat Now',
                            style: HomeStyle.type(
                              context,
                              9,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeDoctorCard extends StatelessWidget {
  const HomeDoctorCard({super.key});
  @override
  Widget build(BuildContext context) => HomePanel(
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, c) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 86),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              bottom: -5,
              width: c.maxWidth * .4,
              height: 100,
              child: Image.asset(
                'assets/home/home-doctor.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    'Need a Doctor?',
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
                    'Get trusted care quickly',
                    style: HomeStyle.type(context, 7.5),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: c.maxWidth * .72,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in [
                          ('Online\nConsultation', 'consultation'),
                          ('Nearby\nClinics', 'location'),
                          ('Emergency\nSupport', 'emergency'),
                        ])
                          Expanded(
                            child: HomePress(
                              label: item.$1.replaceAll('\n', ' '),
                              onTap: () {
                                if (item.$2 == 'emergency') {
                                  context.push('/more/safety');
                                } else {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: LText(
                                        item.$1.replaceAll('\n', ' '),
                                      ),
                                      content: const LText(
                                        'This care directory is a design preview. No provider search, location access, or booking takes place.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const LText('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: HomeStyle.dark(context)
                                      ? const Color(0xFF3D3045)
                                      : Colors.white.withValues(alpha: .85),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Column(
                                  children: [
                                    HomeArt(item.$2, size: 18),
                                    const SizedBox(height: 4),
                                    LText(
                                      item.$1,
                                      textAlign: TextAlign.center,
                                      style: HomeStyle.type(
                                        context,
                                        6.8,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeRecommendations extends StatelessWidget {
  const HomeRecommendations({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      HomeHeading(
        'Recommended for You',
        onSeeAll: () => context.push('/more/learn'),
      ),
      LayoutBuilder(
        builder: (context, c) {
          final count = MediaQuery.textScalerOf(context).scale(12) > 16 ? 2 : 4;
          return Wrap(
            runSpacing: 8,
            children: [
              for (final article in HomeDemo.articles)
                SizedBox(
                  width: c.maxWidth / count,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: HomePanel(
                      padding: EdgeInsets.zero,
                      onTap: () => context.push('/article/${article.$4}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 2.1,
                                child: Image.asset(
                                  'assets/home/${article.$2}.png',
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    size: 12,
                                    color: HomeStyle.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LText(
                                  article.$1,
                                  style: HomeStyle.type(
                                    context,
                                    7.5,
                                    weight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 9,
                                      color: HomeStyle.secondary(context),
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: LText(
                                        '${article.$3} min read',
                                        style: HomeStyle.type(
                                          context,
                                          7,
                                          color: HomeStyle.secondary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
