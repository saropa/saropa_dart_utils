import 'dart:math';

/// Generate random string (alphanumeric, length). Roadmap #227.
final Random _rnd = Random();

String randomAlphanumeric(int length, {bool isUppercase = false}) {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final String pool = isUppercase ? chars.toUpperCase() : chars;
  return List<String>.generate(length, (_) => pool[_rnd.nextInt(pool.length)]).join();
}
