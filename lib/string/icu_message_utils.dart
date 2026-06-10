/// ICU-style message formatting lite: pluralization and `select` (gender) —
/// roadmap #414.
///
/// A pragmatic subset of ICU MessageFormat that covers the two cases apps
/// actually reach for — choosing a plural form and choosing a gendered/category
/// form — without a parser or the `intl` dependency. The existing
/// `String.pluralize` only appends an `s`; this picks among caller-supplied
/// forms and is locale-routable.
library;

String _pluralForm(int count, {required String other, String? one, String? zero}) {
  // English-style cardinal rules: an explicit zero form wins at 0, the one form
  // wins at 1, everything else (and any absent form) falls through to other.
  if (count == 0 && zero != null) return zero;
  if (count == 1 && one != null) return one;
  return other;
}

/// Selects a plural form for [count] and replaces every `#` in the chosen form
/// with the count.
///
/// [zero] is used only when provided and `count == 0`; [one] when `count == 1`;
/// otherwise [other]. Languages with richer plural categories can route through
/// [other] or pass the exact forms that matter.
///
/// Example:
/// ```dart
/// icuPlural(0, zero: 'No files', one: '# file', other: '# files'); // No files
/// icuPlural(1, one: '# file', other: '# files');                   // 1 file
/// icuPlural(5, one: '# file', other: '# files');                   // 5 files
/// ```
String icuPlural(int count, {required String other, String? one, String? zero}) =>
    _pluralForm(count, zero: zero, one: one, other: other).replaceAll('#', '$count');

/// ICU `select` lite: returns the [cases] entry whose key equals [value],
/// falling back to [other] for any missing or unknown key.
///
/// The common use is gender — `icuSelect(g, {'male': '…', 'female': '…'},
/// other: '…')` — but it works for any finite category set (status, role, etc.).
///
/// Example:
/// ```dart
/// icuSelect('female', <String, String>{'male': 'He', 'female': 'She'}, other: 'They');
/// // 'She'
/// ```
String icuSelect(String value, Map<String, String> cases, {required String other}) =>
    cases[value] ?? other;
