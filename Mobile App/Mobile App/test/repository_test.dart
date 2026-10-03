import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herly/core/repositories.dart';

void main() {
  test('consecutive period logs retain the start of the period', () {
    final entries = [1, 2, 3]
        .map(
          (day) => TrackingEntry(
            category: 'Period',
            value: 'Medium',
            date: DateTime(2026, 10, day),
          ),
        )
        .toList();
    expect(
      latestPeriodStart(entries, DateTime(2026, 9, 3)),
      DateTime(2026, 10, 1),
    );
    entries.add(
      TrackingEntry(
        category: 'Period',
        value: 'Light',
        date: DateTime(2026, 10, 29),
      ),
    );
    expect(
      latestPeriodStart(entries, DateTime(2026, 9, 3)),
      DateTime(2026, 10, 29),
    );
  });
  test('cycle calculation crosses month and year boundaries', () {
    final cycle = CycleEstimate(DateTime(2026, 12, 20));
    expect(cycle.nextPeriod, DateTime(2027, 1, 17));
    expect(cycle.daysUntil(DateTime(2027, 1, 14, 21)), 3);
    expect(cycle.dayOfCycle(DateTime(2026, 12, 20)), 1);
  });
  test('tracking persists and replaces same-day category only', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    final repo = MockTrackingRepository(p);
    await repo.save(
      TrackingEntry(
        category: 'Mood',
        value: 'Good',
        date: DateTime(2026, 10, 2),
      ),
    );
    await repo.save(
      TrackingEntry(
        category: 'Mood',
        value: 'Great',
        date: DateTime(2026, 10, 2, 10),
      ),
    );
    await repo.save(
      TrackingEntry(category: 'Water', value: '4', date: DateTime(2026, 10, 2)),
    );
    final reloaded = MockTrackingRepository(p).read();
    expect(reloaded.length, 2);
    expect(reloaded.first.value, 'Great');
    expect(trackingInsight(reloaded), contains('1 mood check-in.'));
  });
  test('mock authentication validates email', () async {
    expect(
      () => MockAuthRepository().signIn('Email', 'invalid'),
      throwsFormatException,
    );
    await MockAuthRepository().signIn('Email', 'samara@example.com');
  });
  test('concerning chat uses safety escalation', () async {
    expect(
      await MockChatRepository().reply('severe pain', personalized: false),
      startsWith('SAFETY:'),
    );
  });
  test('personalization consent is respected', () async {
    expect(
      await MockChatRepository().reply('pattern', personalized: false),
      contains('turned off'),
    );
  });
}
