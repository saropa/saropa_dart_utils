/// Safe temp-file naming (randomized, collision-resistant) — roadmap #694.
library;

import 'dart:math' show Random;

final Random _random = Random();

/// Returns a short random string suitable for temp file names (alphanumeric).
String safeTempName({int length = 12}) {
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
}
