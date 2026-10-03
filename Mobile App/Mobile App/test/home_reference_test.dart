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
import 'package:herly/features/home/home_data.dart';

void main() {
  testWidgets(
    'reference Home renders at phone, compact, tablet and large text sizes',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final font = FontLoader('Manrope')
        ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      SharedPreferences.setMockInitialValues({'onboarded': true});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(preferences)],
      );
      addTearDown(container.dispose);
      final boundary = GlobalKey();
      tester.view.physicalSize = const Size(390, 1060);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(key: boundary, child: const HerlyApp()),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold).first);
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
          await precacheImage(AssetImage('assets/home/$asset.png'), context);
        }
      });
      for (final configuration in [
        ('reference', const Size(390, 1060), 1.0, ThemeMode.light),
        ('compact', const Size(320, 740), 1.0, ThemeMode.light),
        ('large-text', const Size(390, 844), 1.7, ThemeMode.light),
        ('tablet', const Size(768, 1024), 1.0, ThemeMode.light),
        ('dark', const Size(390, 1060), 1.0, ThemeMode.dark),
      ]) {
        tester.view.physicalSize = configuration.$2;
        tester.platformDispatcher.textScaleFactorTestValue = configuration.$3;
        await container
            .read(settingsProvider.notifier)
            .update(mode: configuration.$4);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: configuration.$1);
        if (const bool.fromEnvironment('CAPTURE')) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('docs/home/${configuration.$1}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('quick action saves water and center action opens check-in', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesProvider.overrideWithValue(preferences)],
        child: const HerlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Water').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '4');
    await tester.scrollUntilVisible(
      find.text('Save'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(preferences.getString('tracking'), contains('"value":"4"'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Quick check-in'));
    await tester.pumpAndSettle();
    expect(find.text('A moment for you'), findsOneWidget);
    expect(find.text('Log Mood'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  test('goal completion persists across provider containers', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    await container.read(homeGoalsProvider.notifier).toggle(2);
    expect(container.read(homeGoalsProvider), [true, true, true, false]);
    container.dispose();
    final reloaded = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    expect(reloaded.read(homeGoalsProvider), [true, true, true, false]);
    reloaded.dispose();
  });
}
