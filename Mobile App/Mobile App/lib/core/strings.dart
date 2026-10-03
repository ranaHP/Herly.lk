import 'catalog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HerlyStrings {
  final String language;
  const HerlyStrings(this.language);
  static HerlyStrings of(BuildContext context) =>
      Localizations.of<HerlyStrings>(context, HerlyStrings)!;
  static const delegate = _StringsDelegate();
  static final missing = <String>{};
  String t(String key) {
    if (language == 'en') return key;
    final words = catalog[language]!;
    if (words.containsKey(key)) return words[key]!;
    final insensitive = words.entries.where(
      (e) => e.key.toLowerCase() == key.toLowerCase(),
    );
    if (insensitive.isNotEmpty) return insensitive.first.value;
    final entries = templates[language]!.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      final escaped = RegExp.escape(entry.key)
          .replaceAll(RegExp(r'\\\{[a-z]+\\\}'), r'(.+?)');
      final pattern = '^$escaped\$';
      final match = RegExp(pattern).firstMatch(key);
      if (match != null) {
        var value = entry.value;
        final names = RegExp(r'\{[a-z]+\}').allMatches(entry.key).toList();
        for (var i = 0; i < names.length; i++) {
          value = value.replaceAll(names[i].group(0)!, t(match.group(i + 1)!));
        }
        return value;
      }
    }
    if (key.contains(' · ')) return key.split(' · ').map(t).join(' · ');
    if (key.contains('\n')) return key.split('\n').map(t).join('\n');
    if (!RegExp(r'[\u0B80-\u0BFF\u0D80-\u0DFF]').hasMatch(key) &&
        RegExp(r'[A-Za-z]{2}').hasMatch(key) &&
        ![
          'Herly',
          'Herly AI',
          'Herly+',
          'Google',
          'Apple',
          'English',
          'SI',
          'TA',
          'සිංහල',
          'தமிழ்',
          'Samara',
        ].contains(key)) {
      missing.add(key);
    }
    return key;
  }
}

class _StringsDelegate extends LocalizationsDelegate<HerlyStrings> {
  const _StringsDelegate();
  @override
  bool isSupported(Locale locale) =>
      ['en', 'si', 'ta'].contains(locale.languageCode);
  @override
  Future<HerlyStrings> load(Locale locale) =>
      SynchronousFuture(HerlyStrings(locale.languageCode));
  @override
  bool shouldReload(_StringsDelegate old) => false;
}

extension Translate on BuildContext {
  String tr(String key) => HerlyStrings.of(this).t(key);
}

/// App-owned text; user-authored content uses ordinary Text.
class LText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  const LText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });
  @override
  Widget build(BuildContext context) => Text(
    context.tr(data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
  );
}

extension LocalizedDecoration on InputDecoration {
  InputDecoration localized(BuildContext context) => copyWith(
    labelText: labelText == null ? null : context.tr(labelText!),
    hintText: hintText == null ? null : context.tr(hintText!),
    helperText: helperText == null ? null : context.tr(helperText!),
    errorText: errorText == null ? null : context.tr(errorText!),
  );
}
