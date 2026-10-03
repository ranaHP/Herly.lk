import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herly/app/app.dart';
import 'package:herly/core/settings.dart';
import 'package:herly/core/strings.dart';
import 'package:herly/core/catalog.dart';
import 'package:herly/core/repositories.dart';

void main() {
  testWidgets('reference screens and all routes localize without overflow', (
    tester,
  ) async {
    final originalShadows = debugDisableShadows;
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = originalShadows);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final font in [
      ('Manrope', 'assets/fonts/Manrope.ttf'),
      ('NotoSansSinhala', 'assets/fonts/NotoSansSinhala.ttf'),
      ('NotoSansTamil', 'assets/fonts/NotoSansTamil.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final p = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(p)],
    );
    addTearDown(container.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: boundary, child: const HerlyApp()),
      ),
    );
    await tester.runAsync(() async {
      for (final a in [
        'home-hero',
        'home-avatar',
        'home-robot',
        'article-cycle',
        'article-food',
        'article-mindful',
        'article-sleep',
      ]) {
        await precacheImage(
          AssetImage('assets/home/$a.png'),
          tester.element(find.byType(Scaffold).first),
        );
      }
    });
    final errors = <String>[];
    for (final locale in ['en', 'si', 'ta']) {
      await container.read(settingsProvider.notifier).update(language: locale);
      for (final route in [
        '/calendar',
        '/ai',
        '/home',
        '/insights',
        '/more',
        '/more/privacy',
        '/more/appearance',
        '/more/reminders',
        '/more/learn',
        '/more/profile',
        '/more/safety',
        '/more/premium',
        '/more/help',
        '/more/health',
        '/more/wellness',
        '/more/self-care',
        '/more/journal',
        '/more/goals',
        '/article/0',
        '/article/1',
        '/article/2',
        '/article/3',
        '/article/4',
        '/welcome',
        '/onboarding',
      ]) {
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        for (final element in find.byType(Scrollable).evaluate()) {
          (element as StatefulElement).state is ScrollableState
              ? ((element.state) as ScrollableState).position.jumpTo(0)
              : null;
        }
        await tester.pumpAndSettle();
        var ex = tester.takeException();
        if (ex != null) errors.add('$locale $route $ex');
        if (['/calendar', '/ai'].contains(route) &&
            const bool.fromEnvironment('CAPTURE')) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('docs/calendar-chat/${route.substring(1)}-$locale.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          for (var i = 0; i < 5; i++) {
            await tester.drag(scrollables.first, const Offset(0, -550));
            await tester.pumpAndSettle();
            final error = tester.takeException();
            if (error != null) errors.add('$locale $route scrolled $error');
          }
        }
      }
    }
    for (final config in [
      (const Size(320, 740), 1.0, 'en', ThemeMode.light),
      (const Size(390, 844), 1.7, 'ta', ThemeMode.dark),
      (const Size(768, 1024), 1.0, 'si', ThemeMode.light),
    ]) {
      tester.view.physicalSize = config.$1;
      tester.platformDispatcher.textScaleFactorTestValue = config.$2;
      await container
          .read(settingsProvider.notifier)
          .update(language: config.$3, mode: config.$4);
      for (final route in ['/calendar', '/ai']) {
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        for (final element in find.byType(Scrollable).evaluate()) {
          final state = (element as StatefulElement).state;
          if (state is ScrollableState) state.position.jumpTo(0);
        }
        await tester.pumpAndSettle();
        final error = tester.takeException();
        if (error != null) errors.add('$config $route $error');
      }
    }
    await tester.runAsync(
      () =>
          File('/tmp/herly-missing-runtime.txt')
              .writeAsString(HerlyStrings.missing.join('\n')),
    );
    debugDisableShadows = originalShadows;
    expect(errors, isEmpty);
    expect(HerlyStrings.missing, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
  test('dynamic localized strings preserve numbers', () {
    expect(const HerlyStrings('si').t('Period Day 1'), 'ඔසප් දින 1');
    expect(const HerlyStrings('ta').t('In 28 days'), '28 நாட்களில்');
  });
  test(
    'catalogs have matching keys and translate every demo response',
    () async {
      expect(catalog['si']!.keys.toSet(), catalog['ta']!.keys.toSet());
      HerlyStrings.missing.clear();
      for (final language in ['si', 'ta']) {
        final strings = HerlyStrings(language);
        for (final article in DemoContent.articles) {
          strings.t(article.title);
          strings.t(article.category);
          strings.t(article.body);
        }
        for (final prompt in [
          'sleep',
          'cramp',
          'anxious',
          'pattern',
          'severe',
          'hello',
        ]) {
          final response = await MockChatRepository().reply(
            prompt,
            personalized: true,
          );
          expect(strings.t(response), isNot(response));
        }
      }
      expect(HerlyStrings.missing, isEmpty);
    },
  );
  testWidgets(
    'language switch updates existing chat without changing user text',
    (tester) async {
      SharedPreferences.setMockInitialValues({'onboarded': true});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(preferences)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const HerlyApp(),
        ),
      );
      container.read(routerProvider).go('/ai');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My own sleep question');
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      final reply = container.read(chatProvider).last.text;
      await container.read(settingsProvider.notifier).update(language: 'ta');
      await tester.pumpAndSettle();
      expect(find.text('My own sleep question'), findsOneWidget);
      expect(find.text(const HerlyStrings('ta').t(reply)), findsOneWidget);
      expect(find.text(reply), findsNothing);
      expect(container.read(chatProvider)[1].text, 'My own sleep question');
      await tester.pumpWidget(const SizedBox());
    },
  );
}
