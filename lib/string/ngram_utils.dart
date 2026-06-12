/// N-gram generator for strings — character and word n-grams (roadmap #405).
library;

import 'string_extensions.dart';

/// Returns character n-grams of [s] with length [n].
/// Overlapping windows; empty string or n < 1 returns empty list.
/// Audited: 2026-06-12 11:26 EDT
List<String> characterNgrams(String s, int n) {
  if (n < 1 || s.length < n) return <String>[];
  final int count = s.length - n + 1;
  return List.generate(count, (int i) {
    final int end = (i + n).clamp(0, s.length);
    return s.substringSafe(i, end);
  });
}

/// Returns word n-grams of [s] with [n] words per gram.
/// Words are split on whitespace; empty or n < 1 returns empty list.
/// Audited: 2026-06-12 11:26 EDT
List<List<String>> wordNgrams(String s, int n) {
  if (n < 1) return <List<String>>[];
  final List<String> words = s.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.length < n) return <List<String>>[];
  final int count = words.length - n + 1;
  return List.generate(count, (int i) => words.sublist(i, i + n));
}
