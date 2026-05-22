import 'dart:math';

/// Generate random string (alphanumeric, length). Roadmap #227.
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
String randomAlphanumeric(int length, {bool isUppercase = false}) {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final String pool = isUppercase ? chars.toUpperCase() : chars;
  return List<String>.generate(length, (_) => pool[_rnd.nextInt(pool.length)]).join();
}
