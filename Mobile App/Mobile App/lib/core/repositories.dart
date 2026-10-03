import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class CycleEstimate {
  final DateTime lastPeriod;
  final int length, duration;
  const CycleEstimate(this.lastPeriod, {this.length = 28, this.duration = 5});
  DateTime get nextPeriod => lastPeriod.add(Duration(days: length));
  int daysUntil(DateTime now) => nextPeriod.difference(dateOnly(now)).inDays;
  int dayOfCycle(DateTime date) =>
      dateOnly(date).difference(dateOnly(lastPeriod)).inDays % length + 1;
}

class TrackingEntry {
  final String category, value, notes;
  final DateTime date;
  final List<String> symptoms;
  TrackingEntry({
    required this.category,
    required this.value,
    required this.date,
    this.notes = '',
    this.symptoms = const [],
  });
  Map<String, dynamic> toJson() => {
    'category': category,
    'value': value,
    'notes': notes,
    'date': date.toIso8601String(),
    'symptoms': symptoms,
  };
  factory TrackingEntry.fromJson(Map<String, dynamic> j) => TrackingEntry(
    category: j['category'],
    value: j['value'],
    date: DateTime.parse(j['date']),
    notes: j['notes'] ?? '',
    symptoms: List<String>.from(j['symptoms'] ?? []),
  );
}

abstract interface class TrackingRepository {
  List<TrackingEntry> read();
  Future<void> save(TrackingEntry entry);
}

class MockTrackingRepository implements TrackingRepository {
  final SharedPreferences preferences;
  MockTrackingRepository(this.preferences);
  @override
  List<TrackingEntry> read() {
    final raw = preferences.getString('tracking');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => TrackingEntry.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(TrackingEntry entry) async {
    final list = read()
      ..removeWhere(
        (e) =>
            e.category == entry.category &&
            dateOnly(e.date) == dateOnly(entry.date),
      );
    list.add(entry);
    if (!await preferences.setString(
      'tracking',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    )) {
      throw StateError('Could not save. Please try again.');
    }
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => MockTrackingRepository(ref.read(preferencesProvider)),
);
final trackingProvider =
    NotifierProvider<TrackingController, List<TrackingEntry>>(
      TrackingController.new,
    );

class TrackingController extends Notifier<List<TrackingEntry>> {
  @override
  List<TrackingEntry> build() => ref.read(trackingRepositoryProvider).read();
  Future<void> save(TrackingEntry entry) async {
    await ref.read(trackingRepositoryProvider).save(entry);
    state = ref.read(trackingRepositoryProvider).read();
  }

  void reload() => state = ref.read(trackingRepositoryProvider).read();
}

final cycleProvider = Provider<CycleEstimate>((ref) {
  final entries =
      ref.watch(trackingProvider).where((e) => e.category == 'Period').toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  final p = ref.watch(preferencesProvider);
  final saved = DateTime.tryParse(p.getString('lastPeriod') ?? '');
  final fallback =
      saved ?? dateOnly(DateTime.now()).subtract(const Duration(days: 25));
  return CycleEstimate(
    latestPeriodStart(entries, fallback),
    length: p.getInt('cycleLength') ?? 28,
    duration: p.getInt('periodLength') ?? 5,
  );
});

/// Consecutive daily logs belong to one period, not separate cycle starts.
DateTime latestPeriodStart(List<TrackingEntry> entries, DateTime fallback) {
  final dates =
      entries
          .where((entry) => entry.category == 'Period')
          .map((entry) => dateOnly(entry.date))
          .toSet()
          .toList()
        ..sort();
  if (dates.isEmpty) return dateOnly(fallback);
  var start = dates.first;
  for (var i = 1; i < dates.length; i++) {
    if (dates[i].difference(dates[i - 1]).inDays > 1) start = dates[i];
  }
  final configured = dateOnly(fallback);
  if (configured.isBefore(start) && start.difference(configured).inDays <= 5) {
    return configured;
  }
  return start;
}

abstract interface class AuthRepository {
  Future<void> signIn(String method, String email);
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<void> signIn(String method, String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (method == 'Email' &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw const FormatException('Enter a valid email address.');
    }
  }
}

final authProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

abstract interface class ChatRepository {
  Future<String> reply(String prompt, {required bool personalized});
}

class MockChatRepository implements ChatRepository {
  @override
  Future<String> reply(String prompt, {required bool personalized}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final q = prompt.toLowerCase();
    if ([
      'suicid',
      'hurt myself',
      'severe',
      'faint',
      'chest pain',
      'heavy bleeding',
    ].any(q.contains)) {
      return 'SAFETY: This demo cannot assess urgent symptoms or provide crisis care. If you may be in immediate danger, contact local emergency services or a trusted person now. Seek professional help promptly for severe or worsening symptoms.';
    }
    if (['sleep', 'නින්ද', 'தூக்க'].any(q.contains)) {
      return 'A gentle evening routine can be a useful place to start. Try a consistent wind-down time, a comfortable room, and a few quiet minutes away from screens. What helps you feel settled?';
    }
    if (['cramp', 'කැක්කුම', 'பிடிப்பு'].any(q.contains)) {
      return 'I can help you record when discomfort happens and prepare questions for a clinician. This is a simulated conversation, not a diagnosis. Severe, unusual, or worsening pain deserves professional attention.';
    }
    if (['anx', 'කනස්සල්ල', 'பதட்ட'].any(q.contains)) {
      return 'That sounds difficult. You could take a quiet moment and notice what is around you, or reach out to someone you trust. Would you like to write down how you feel?';
    }
    if (q.contains('pattern')) {
      return personalized
          ? 'Your demo history includes several mood and sleep entries. These are examples, not a medical finding. Keep logging what you notice to build a more useful personal record.'
          : 'Personalized responses are turned off. You can choose whether to enable them in Privacy & Security.';
    }
    return 'Thank you for sharing. I’m a demo wellbeing companion with scripted replies. You can use your journal to reflect, log how you feel, or explore the learning library. What would feel useful today?';
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => MockChatRepository(),
);

class ChatMessage {
  final String text;
  final bool user;
  final bool localizable;
  const ChatMessage(this.text, {this.user = false, this.localizable = false});
  Map<String, dynamic> toJson() => {
    'text': text,
    'user': user,
    'localizable': localizable,
  };
}

final chatProvider = NotifierProvider<ChatController, List<ChatMessage>>(
  ChatController.new,
);

class ChatController extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    try {
      final raw = ref.read(preferencesProvider).getString('chat');
      if (raw != null) {
        return (jsonDecode(raw) as List)
            .map(
              (m) => ChatMessage(
                m['text'],
                user: m['user'],
                localizable: m['localizable'] ?? false,
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [
      const ChatMessage(
        'Hi, I’m Herly. A little space to ask, reflect, and feel heard. How can I help today?',
      ),
    ];
  }

  Future<void> send(String prompt, {bool localizable = false}) async {
    state = [
      ...state,
      ChatMessage(prompt, user: true, localizable: localizable),
    ];
    final p = ref.read(preferencesProvider);
    try {
      final response = await ref
          .read(chatRepositoryProvider)
          .reply(
            prompt,
            personalized: p.getBool('AI personalization') ?? false,
          );
      state = [...state, ChatMessage(response)];
    } catch (_) {
      state = [
        ...state,
        const ChatMessage('Could not load a response. Please try again.'),
      ];
    }
    await p.setString(
      'chat',
      jsonEncode(state.map((m) => m.toJson()).toList()),
    );
  }
}

class Article {
  final String title, category, art, body;
  const Article(this.title, this.category, this.art, this.body);
}

abstract final class DemoContent {
  static const goals = [
    'Understand my cycle',
    'Feel better day-to-day',
    'Understand my body',
    'Self-care & beauty',
    'Manage stress',
    'Sexual health',
    'Trying for pregnancy',
    'Pregnancy',
    'Motherhood',
  ];
  static const goalArt = [
    'cycle',
    'wellbeing',
    'journey',
    'self-care',
    'mood',
    'privacy',
    'journey',
    'journey',
    'wellbeing',
  ];
  static const trackers = [
    'Period',
    'Symptoms',
    'Mood',
    'Sleep',
    'Energy',
    'Water',
    'Weight',
    'Exercise',
    'Nutrition',
    'Medication',
    'Skin',
    'Journal',
  ];
  static const symptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Mood changes',
    'Acne',
    'Fatigue',
    'Breast tenderness',
    'Cravings',
    'Back pain',
  ];
  static const articles = [
    Article(
      'Getting to know your cycle',
      'Cycle',
      'cycle',
      'Your cycle is a personal pattern, and it can change. Recording dates and observations can help you describe your experience.\n\nTry noting the first day of bleeding, how you feel, and anything you want to discuss with a clinician. Estimates in Herly are illustrative and are not suitable for contraception.\n\nReflection: what would you like to understand about your own pattern?',
    ),
    Article(
      'A softer landing at bedtime',
      'Mental wellbeing',
      'sleep',
      'An evening ritual can be as simple as a few quiet minutes. Choose something that feels comfortable and repeatable.\n\nWrite down tomorrow’s priorities, put your phone aside, and make space to rest. This is illustrative wellness content, not clinical advice.',
    ),
    Article(
      'Make room for yourself',
      'Lifestyle',
      'self-care',
      'Self-care does not need a perfect routine. Pick one small action that feels kind today.\n\nA short walk, a favourite song, or a moment with your journal can be your starting point.',
    ),
    Article(
      'Food, culture, and everyday care',
      'Nutrition',
      'wellbeing',
      'Use this demo journal to notice meals you enjoy and questions you have about nutrition.\n\nFor personalized dietary guidance, speak with a qualified professional. Herly’s learning library is sample content.',
    ),
    Article(
      'Consent and boundaries',
      'Relationships',
      'privacy',
      'Your boundaries matter. You can change your mind, ask for time, and choose what feels comfortable.\n\nHealthy conversations leave room for mutual respect and a clear, freely given choice.',
    ),
  ];
}

String trackingInsight(List<TrackingEntry> entries) {
  final moods = entries.where((e) => e.category == 'Mood').length;
  return moods == 0
      ? 'Your story starts with a check-in. A few moments today can help you notice your own patterns.'
      : 'You have recorded $moods mood check-in${moods == 1 ? '' : 's'}. These observations describe your logs; they do not establish a medical cause.';
}
