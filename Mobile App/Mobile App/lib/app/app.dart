import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings.dart';
import '../core/strings.dart';
import '../features/home/home_navigation.dart';
import '../core/theme.dart';
import '../features/onboarding/welcome.dart';
import '../features/onboarding/onboarding.dart';
import '../features/home/home.dart';
import '../features/cycle/calendar.dart';
import '../features/insights/insights.dart';
import '../features/ai/chat.dart';
import '../features/explore/profile.dart';
import '../features/explore/privacy.dart';
import '../features/explore/reminders.dart';
import '../features/explore/library.dart';
import '../features/explore/spaces.dart';
import '../features/explore/support.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(preferencesProvider).getBool('onboarded') == true
        ? '/home'
        : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          login: state.uri.queryParameters['login'] == 'true',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => CalendarScreen(
                  initialDate: DateTime.tryParse(
                    state.uri.queryParameters['date'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/more/:section',
        builder: (context, state) => switch (state.pathParameters['section']) {
          'appearance' => const AppearanceScreen(),
          'privacy' => const PrivacyScreen(),
          'reminders' => const RemindersScreen(),
          'learn' => const LearnScreen(),
          'profile' => const EditProfileScreen(),
          'safety' => const SafetyScreen(),
          'premium' => const PremiumScreen(),
          'help' => const HelpScreen(),
          _ => SpaceScreen(kind: state.pathParameters['section']!),
        },
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) => ArticleScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class HerlyApp extends ConsumerWidget {
  const HerlyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Herly · Her Life. Her Way.',
      onGenerateTitle: (context) => context.tr('Herly · Her Life. Her Way.'),
      debugShowCheckedModeBanner: false,
      theme: HerlyTokens.theme(Brightness.light, settings.accent),
      darkTheme: HerlyTokens.theme(Brightness.dark, settings.accent),
      themeMode: settings.mode,
      locale: Locale(settings.language),
      supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
      localizationsDelegates: const [
        HerlyStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: AppTextScaler(media.textScaler, settings.fontScale),
          ),
          child: child!,
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: [1, 3].contains(shell.currentIndex)
        ? null
        : HerlyHomeNavigation(shell: shell),
  );
}
