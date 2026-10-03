import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';

/// Values from the supplied design, shown only until a matching entry is logged.
abstract final class HomeDemo {
  static final date = DateTime(2026, 10, 25);
  static const water = 6.0;
  static const steps = 3250;
  static const sleep = 7.5;
  static const articles = [
    ('Understanding your menstrual cycle', 'article-cycle', 5, 0),
    ('Iron-rich foods for better periods', 'article-food', 4, 3),
    ('Managing stress during PMS', 'article-mindful', 6, 2),
    ('Better sleep for your cycle', 'article-sleep', 4, 1),
  ];
  static const quickActions = [
    ('Log Period', 'period', 'Period', 0xFFFDE2EE),
    ('Symptoms', 'symptoms', 'Symptoms', 0xFFF7E4FB),
    ('Mood', 'mood', 'Mood', 0xFFFFEFDF),
    ('Sleep', 'sleep', 'Sleep', 0xFFF0E8FF),
    ('Water', 'water', 'Water', 0xFFE5EEFF),
    ('Exercise', 'exercise', 'Exercise', 0xFFE5F7EC),
    ('Nutrition', 'nutrition', 'Nutrition', 0xFFF1F5E1),
    ('Weight', 'weight', 'Weight', 0xFFF3E4F6),
    ('Self-Care', 'self-care', '/more/self-care', 0xFFFCE4EE),
    ('More', 'more', '/more/health', 0xFFF5E6F8),
  ];
}

final homeGoalsProvider = NotifierProvider<HomeGoalsController, List<bool>>(
  HomeGoalsController.new,
);

class HomeGoalsController extends Notifier<List<bool>> {
  String get key => 'home-goals-${dateOnly(DateTime.now()).toIso8601String()}';
  @override
  List<bool> build() {
    final saved = ref.read(preferencesProvider).getStringList(key);
    return saved?.map((v) => v == 'true').toList() ??
        [true, true, false, false];
  }

  Future<void> toggle(int index) async {
    final next = [...state];
    next[index] = !next[index];
    await ref
        .read(preferencesProvider)
        .setStringList(key, next.map((v) => '$v').toList());
    state = next;
  }
}
