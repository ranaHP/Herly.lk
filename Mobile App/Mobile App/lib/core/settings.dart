import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Bootstrap preferences first'),
);

class Settings {
  final ThemeMode mode;
  final Color accent;
  final String language;
  final double fontScale;
  const Settings({
    this.mode = ThemeMode.system,
    this.accent = HerlyTokens.rose,
    this.language = 'en',
    this.fontScale = 1,
  });
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);

class SettingsController extends Notifier<Settings> {
  @override
  Settings build() {
    final p = ref.read(preferencesProvider);
    return Settings(
      mode: ThemeMode.values[p.getInt('theme') ?? 0],
      accent: Color(p.getInt('accent') ?? HerlyTokens.rose.toARGB32()),
      language: p.getString('language') ?? 'en',
      fontScale: (p.getDouble('fontScale') ?? 1).clamp(.85, 1.5),
    );
  }

  Future<void> update({
    ThemeMode? mode,
    Color? accent,
    String? language,
    double? fontScale,
  }) async {
    final next = Settings(
      mode: mode ?? state.mode,
      accent: accent ?? state.accent,
      language: language ?? state.language,
      fontScale: (fontScale ?? state.fontScale).clamp(.85, 1.5),
    );
    state = next;
    final p = ref.read(preferencesProvider);
    await p.setDouble('fontScale', next.fontScale);
    await p.setInt('theme', next.mode.index);
    await p.setInt('accent', next.accent.toARGB32());
    await p.setString('language', next.language);
  }
}

final profileProvider = Provider<Map<String, String>>((ref) {
  final p = ref.watch(preferencesProvider);
  return {
    'name': p.getString('name') ?? 'Samara',
    'email': p.getString('email') ?? 'samara@example.com',
  };
});

/// Multiply the device's scaler rather than replacing accessibility preferences.
class AppTextScaler extends TextScaler {
  final TextScaler system;
  final double factor;
  const AppTextScaler(this.system, this.factor);
  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;
  @override
  double get textScaleFactor => scale(14) / 14;
}
