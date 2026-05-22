import 'package:meta/meta.dart';

/// Sort strings naturally (human: a2 before a10). Roadmap #230.
int naturalCompare(String a, String b) {
  final List<Object> tokensA = _tokenize(a);
  final List<Object> tokensB = _tokenize(b);
  for (int i = 0; i < tokensA.length && i < tokensB.length; i++) {
    final Object tokenA = tokensA[i];
    final Object tokenB = tokensB[i];
    if (tokenA is int && tokenB is int) {
      final int c = tokenA.compareTo(tokenB);
      if (c != 0) return c;
    } else {
      final int c = tokenA.toString().compareTo(tokenB.toString());
      if (c != 0) return c;
    }
  }
  return tokensA.length.compareTo(tokensB.length);
}

List<Object> _tokenize(String s) {
  final List<Object> out = <Object>[];
  final RegExp re = RegExp(r'\d+|\D+');
  for (final RegExpMatch m in re.allMatches(s)) {
    final String? t = m.group(0);
    if (t == null) continue;
    final int? n = int.tryParse(t);
    out.add(n ?? t);
  }
  return out;
}

/// Adds natural (human-friendly) sorting to a `List<String>`.
extension NaturalSortExtension on List<String> {
  /// Returns a new list sorted naturally so `a2` comes before `a10`.
  ///
  /// Uses [naturalCompare] to order embedded numbers by value rather than by
  /// character. The original list is not modified.
  ///
  /// Example:
  /// ```dart
  /// ['a10', 'a2', 'a1'].sortedNatural(); // ['a1', 'a2', 'a10']
  /// ```
  @useResult
  List<String> sortedNatural() => List<String>.of(this)..sort(naturalCompare);
}
