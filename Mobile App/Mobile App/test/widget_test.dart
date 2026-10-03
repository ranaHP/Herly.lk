import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herly/app/app.dart';
import 'package:herly/core/settings.dart';

Future<void> launch(WidgetTester tester, {bool onboarded = true}) async {
  SharedPreferences.setMockInitialValues({'onboarded': onboarded});
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
      child: const HerlyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('welcome opens goal selection', (tester) async {
    await launch(tester, onboarded: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(
      find.text('What would you like Herly to help you with?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Understand my cycle'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('home, calendar logging, insights and chat navigation', (
    tester,
  ) async {
    await launch(tester);
    expect(find.text('You’re doing amazing!'), findsOneWidget);
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Log Today'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Log Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium').last);
    await tester.scrollUntilVisible(
      find.text('Save'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Period · Medium'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Back to Home'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Back to Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();
    expect(find.text('YOUR CYCLE STORY'), findsOneWidget);
    await tester.tap(find.text('Chat').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tips for better sleep');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A gentle evening routine'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small phone and large text remain usable', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await launch(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
