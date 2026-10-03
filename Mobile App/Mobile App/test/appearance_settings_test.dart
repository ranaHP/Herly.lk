import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herly/app/app.dart';
import 'package:herly/core/settings.dart';
import 'package:herly/features/home/quick_actions.dart';
import 'package:herly/features/home/cycle_card.dart';

void main() {
  test('font size persists, clamps, and preserves other preferences', () async {
    SharedPreferences.setMockInitialValues({
      'fontScale': 1.2,
      'language': 'ta',
    });
    final p = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(p)],
    );
    expect(c.read(settingsProvider).fontScale, 1.2);
    await c
        .read(settingsProvider.notifier)
        .update(fontScale: 1.4, mode: ThemeMode.dark);
    await c.read(settingsProvider.notifier).update(language: 'si');
    expect(c.read(settingsProvider).fontScale, 1.4);
    c.dispose();
    final restored = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(p)],
    );
    addTearDown(restored.dispose);
    expect(restored.read(settingsProvider).fontScale, 1.4);
    expect(restored.read(settingsProvider).mode, ThemeMode.dark);
    expect(restored.read(settingsProvider).language, 'si');
    await restored.read(settingsProvider.notifier).update(fontScale: 8);
    expect(restored.read(settingsProvider).fontScale, 1.5);
    expect(const AppTextScaler(TextScaler.linear(1.2), 1.5).scale(20), 36);
  });
  testWidgets('language preserves Home columns and text-size controls work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final font in ['Manrope', 'NotoSansSinhala', 'NotoSansTamil']) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final p = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(p)],
    );
    addTearDown(c.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: RepaintBoundary(key: boundary, child: const HerlyApp()),
      ),
    );
    await tester.runAsync(() async {
      for (final asset in [
        'home-hero',
        'home-avatar',
        'home-robot',
        'home-doctor',
        'article-cycle',
        'article-food',
        'article-mindful',
        'article-sleep',
      ]) {
        await precacheImage(
          AssetImage('assets/home/$asset.png'),
          tester.element(find.byType(Scaffold).first),
        );
      }
    });
    Future<void> capture(String name) async {
      if (!const bool.fromEnvironment('CAPTURE')) return;
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('docs/appearance/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.pumpAndSettle();
    double? ringX;
    for (final language in ['en', 'si', 'ta']) {
      await c.read(settingsProvider.notifier).update(language: language);
      await tester.pumpAndSettle();
      final metrics = find.byType(HomeMetric);
      expect(metrics, findsNWidgets(3));
      final positions = [
        for (var i = 0; i < 3; i++) tester.getTopLeft(metrics.at(i)),
      ];
      expect(positions[0].dy, positions[1].dy);
      expect(positions[1].dy, positions[2].dy);
      expect(positions[1].dx, greaterThan(positions[0].dx));
      final x = tester.getTopLeft(find.byType(CycleRing).first).dx;
      ringX ??= x;
      expect(x, closeTo(ringX, .01));
      expect(tester.takeException(), isNull, reason: language);
      await capture('home-$language');
    }
    await c.read(settingsProvider.notifier).update(language: 'en');
    c.read(routerProvider).go('/more/appearance');
    await tester.pumpAndSettle();
    await capture('settings');
    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('font-size-slider')),
    );
    slider.onChanged!(1.5);
    await tester.pumpAndSettle();
    expect(p.getDouble('fontScale'), 1.5);
    final context = tester.element(find.text('Font size'));
    expect(MediaQuery.textScalerOf(context).scale(20), 30);
    await tester.tap(find.text('Reset text size'));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).fontScale, 1);
    for (final language in ['en', 'si', 'ta']) {
      await c
          .read(settingsProvider.notifier)
          .update(language: language, fontScale: 1.5);
      for (final route in ['/home', '/calendar', '/ai', '/more/appearance']) {
        c.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$language $route 150%');
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
}
