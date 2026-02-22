/// ASCII code for uppercase 'A' (65).
const int _asciiUpperA = 65;

/// ASCII code for uppercase 'Z' (90).
const int _asciiUpperZ = 90;

final RegExp _containsDigitsRegex = RegExp(r'.*\d+.*');

/// Search match type for string matching operations.
enum SearchMatchType {
  /// Match if the string contains the search term.
  contains,

  /// Match if the string starts with the search term.
  startsWith,

  /// Match if the string exactly equals the search term.
  exact,
}

/// Extension methods for string searching and matching.
extension StringSearchExtensions on String {
  /// Returns `true` if this string equals any item in [list].
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isEqualsAny(List<String>? list, {bool isCaseSensitive = true}) {
    if (isEmpty || list == null || list.isEmpty) return false;
    if (isCaseSensitive) return list.any((String item) => item == this);
    final String find = toLowerCase();
    return list.any((String item) => item.toLowerCase() == find);
  }

  /// Returns true if this string contains any digits.
  bool isContainsDigits() => _containsDigitsRegex.hasMatch(this);

  /// Returns `true` if this string contains any item from [list].
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isContainsAnyInList(List<String>? list, {bool isCaseSensitive = true}) {
    if (isEmpty || list == null || list.isEmpty) return false;
    if (isCaseSensitive) return list.any((String item) => contains(item));
    final String source = toLowerCase();
    return list.any((String item) => source.contains(item.toLowerCase()));
  }

  /// Returns `true` if this string is contained in any item from [list].
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isContainedInAny(List<String>? list, {bool isCaseSensitive = true}) {
    if (isEmpty || list == null || list.isEmpty) return false;
    if (isCaseSensitive) return list.any((String item) => item.contains(this));
    final String find = toLowerCase();
    return list.any((String item) => item.toLowerCase().contains(find));
  }

  /// Returns `true` if this string contains [find] (case-insensitive).
  bool isContainsCaseInsensitive(String? find) {
    if (isEmpty || find == null || find.isEmpty) return false;
    return toLowerCase().contains(find.toLowerCase());
  }

  /// Returns `true` if this string contains [find], handling `null` safely.
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isContainsNullable(String? find, {bool isCaseSensitive = true}) {
    if (isEmpty || find == null || find.isEmpty) return false;
    if (isCaseSensitive) return contains(find);
    return toLowerCase().contains(find.toLowerCase());
  }

  /// Returns `true` if this string matches any item in [list] using the
  /// specified [matchType].
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isMatchAny(
    List<String>? list, {
    bool isCaseSensitive = true,
    SearchMatchType matchType = SearchMatchType.contains,
  }) {
    if (isEmpty || list == null || list.isEmpty) return false;
    return switch (matchType) {
      SearchMatchType.startsWith => isStartsWithAny(list, isCaseSensitive: isCaseSensitive),
      SearchMatchType.exact => isEqualsAny(list, isCaseSensitive: isCaseSensitive),
      SearchMatchType.contains => isContainsAnyInList(list, isCaseSensitive: isCaseSensitive),
    };
  }

  /// Returns `true` if this string starts with any item in [list].
  ///
  /// When [isCaseSensitive] is `false`, comparison is case-insensitive.
  bool isStartsWithAny(List<String>? list, {bool isCaseSensitive = true}) {
    if (isEmpty || list == null || list.isEmpty) return false;
    final String find = isCaseSensitive ? this : toLowerCase();
    return list.any(
      (String item) =>
          isCaseSensitive ? find.startsWith(item) : find.startsWith(item.toLowerCase()),
    );
  }

  /// Returns the first character uppercased for use as a repeatable index.
  ///
  /// If the first character is a Latin letter (A-Z), returns it uppercased;
  /// otherwise returns the first character as-is.
  String getRepeatableLetter() {
    if (isEmpty) return '';
    final String trimmed = trim();
    if (trimmed.isEmpty) return '';
    final String first = String.fromCharCode(trimmed.runes.first);
    final String upper = first.toUpperCase();
    final int code = upper.codeUnitAt(0);
    if (code >= _asciiUpperA && code <= _asciiUpperZ) return upper;
    return first;
  }

  /// Returns true if this string does NOT contain [find].
  bool isNotContains(String? find) {
    if (isEmpty || find == null || find.isEmpty) return false;
    return !contains(find);
  }

  /// Conditional contains check.
  ///
  /// Returns true if [condition] is true and the string contains [find],
  /// or if [condition] is false and the string does NOT contain [find].
  bool isContainsConditional(String? find, {required bool condition}) {
    if (isEmpty || find == null || find.isEmpty) return false;
    return condition ? contains(find) : !contains(find);
  }

  /// Returns `true` if this string contains any whole word from
  /// [searchItems].
  ///
  /// When [isCaseSensitive] is `false` (default), comparison is
  /// case-insensitive.
  bool isContainsAnyWord(List<String>? searchItems, {bool isCaseSensitive = false}) {
    if (isEmpty || searchItems == null || searchItems.isEmpty) return false;
    for (String item in searchItems) {
      if (isContainsWord(item, isCaseSensitive: isCaseSensitive)) return true;
    }
    return false;
  }

  /// Returns `true` if this string contains [find] as a whole word.
  ///
  /// When [isCaseSensitive] is `false` (default), comparison is
  /// case-insensitive.
  bool isContainsWord(String? find, {bool isCaseSensitive = false}) {
    if (isEmpty || find == null || find.isEmpty) return false;
    final String escapedFind = find.replaceAllMapped(
      RegExp('[.*+?^\${}()|[\\]\\\\]'),
      (Match m) => '\\${m.group(0) ?? ''}',
    );
    final String pattern = '\\b$escapedFind\\b';
    final RegExp regex = RegExp(pattern, caseSensitive: isCaseSensitive);
    return regex.hasMatch(this);
  }

  /// Returns true if this string does NOT start with [find].
  bool isNotStartsWith(String? find) {
    if (isEmpty || find == null || find.isEmpty) return false;
    return !startsWith(find);
  }

  /// Conditional startsWith check.
  ///
  /// Returns true if [isPositiveSearch] is true and the string starts with [find],
  /// or if [isPositiveSearch] is false and the string does NOT start with [find].
  bool isStartsWithConditional(String? find, {required bool isPositiveSearch}) {
    if (isEmpty || find == null || find.isEmpty) return false;
    return isPositiveSearch ? startsWith(find) : isNotStartsWith(find);
  }
}
