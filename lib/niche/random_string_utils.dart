import 'dart:math';

/// Generate random string (alphanumeric, length). Roadmap #227.
/// Audited: 2026-06-12 11:26 EDT
final Random _rnd = Random();

/// Returns a random alphanumeric string of [length] characters.
///
/// Draws from lowercase letters and digits by default; set [isUppercase] to
/// use uppercase letters instead. A [length] of zero returns an empty string.
/// Not cryptographically secure.
///
/// Example:
/// ```dart
/// randomAlphanumeric(8); // e.g. 'a3f9k2qd'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String randomAlphanumeric(int length, {bool isUppercase = false}) {
  // A non-positive length yields the empty string; without this guard a
  // negative length makes the list generator throw instead of degrading.
  if (length <= 0) return '';
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final String pool = isUppercase ? chars.toUpperCase() : chars;
  return List<String>.generate(length, (_) => pool[_rnd.nextInt(pool.length)]).join();
}
