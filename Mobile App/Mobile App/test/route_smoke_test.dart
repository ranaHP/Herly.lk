import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herly/app/app.dart';
import 'package:herly/core/settings.dart';

void main() {
  testWidgets('all routes render at phone size, themes and locales switch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
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
    for (final route in [
      '/home',
      '/calendar',
      '/insights',
      '/ai',
      '/more',
      '/more/appearance',
      '/more/privacy',
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
      '/welcome',
      '/onboarding',
    ]) {
      container.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      if (route == '/welcome') {
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/illustrations/welcome.png'),
            tester.element(find.byType(Scaffold).first),
          ),
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull, reason: route);
      if (const bool.fromEnvironment('CAPTURE')) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/screenshots/${route.substring(1).replaceAll('/', '-')}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    for (final locale in ['si', 'ta', 'en']) {
      await container
          .read(settingsProvider.notifier)
          .update(language: locale, mode: ThemeMode.dark);
      container.read(routerProvider).go('/home');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: locale);
    }
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final route in [
      '/welcome',
      '/calendar',
      '/insights',
      '/ai',
      '/more',
      '/more/privacy',
      '/more/appearance',
    ]) {
      container.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Large text $route');
    }
    await tester.pumpWidget(const SizedBox());
  });
}
