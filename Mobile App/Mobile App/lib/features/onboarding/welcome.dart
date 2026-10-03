import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings.dart';
import '../../core/strings.dart';
import '../../core/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5DDE2),
    body: Center(
      child: Semantics(
        label: context.tr(
          'Herly. Her Life. Her Way. Loading your welcome screen.',
        ),
        child: Localizations.localeOf(context).languageCode != 'en'
            ? const Brand(width: 260, lightBackground: true)
            : Image.asset(
                'assets/brand/splash-reference.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                excludeFromSemantics: true,
              ),
      ),
    ),
  );
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: LayoutBuilder(
          builder: (context, c) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final minimumHeight = 844.0 + (scale > 1 ? (scale - 1) * 720 : 0);
            final height = c.maxHeight < minimumHeight
                ? minimumHeight
                : c.maxHeight;
            return SingleChildScrollView(
              child: SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/illustrations/welcome.png',
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 12,
                      right: 24,
                      child: const LanguageMenu(),
                    ),
                    Positioned(
                      top: height * .05,
                      left: 24,
                      right: 24,
                      child: const Center(
                        child: Brand(width: 210, lightBackground: true),
                      ),
                    ),
                    Positioned(
                      top: height * .215,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _benefit(
                            context,
                            'wellbeing',
                            'Understand\nyour body',
                          ),
                          _benefit(
                            context,
                            'self-care',
                            'Feel better\nevery day',
                          ),
                          _benefit(context, 'ai', 'A safer, happier\nyou'),
                        ],
                      ),
                    ),
                    Positioned(
                      top: height * .695,
                      left: 30,
                      right: 30,
                      child: Column(
                        children: [
                          LText(
                            '${context.tr('Welcome to')} Herly',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: const Color(0xFF302537)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          LText(
                            context.tr(
                              'Your personal companion for every stage of your journey.',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF67566A)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: i == 0 ? 18 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? const Color(0xFFD6336C)
                                      : const Color(0xFFDFD4D8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          HerlyButton(
                            'Get Started',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () => context.go('/onboarding'),
                          ),
                          const SizedBox(height: 10),
                          HerlyButton(
                            'I already have an account',
                            secondary: true,
                            onPressed: () =>
                                context.go('/onboarding?login=true'),
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
    ),
  );
  Widget _benefit(BuildContext context, String art, String text) => Expanded(
    child: Column(
      children: [
        Art(art, size: 44),
        const SizedBox(height: 7),
        LText(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: const Color(0xFF67475B)),
        ),
      ],
    ),
  );
}

class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(settingsProvider).language;
    return PopupMenuButton<String>(
      tooltip: context.tr('Language'),
      initialValue: language,
      onSelected: (v) =>
          ref.read(settingsProvider.notifier).update(language: v),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'en', child: LText('English')),
        PopupMenuItem(value: 'si', child: LText('සිංහල')),
        PopupMenuItem(value: 'ta', child: LText('தமிழ்')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: Color(0xFF4A1D3C)),
            const SizedBox(width: 7),
            LText(
              language.toUpperCase(),
              style: const TextStyle(color: Color(0xFF4A1D3C)),
            ),
            const Icon(Icons.expand_more, size: 18, color: Color(0xFF4A1D3C)),
          ],
        ),
      ),
    );
  }
}
