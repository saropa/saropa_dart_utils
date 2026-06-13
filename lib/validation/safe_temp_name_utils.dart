/// Safe temp-file naming (randomized, collision-resistant) — roadmap #694.
library;

import 'dart:math' show Random;

// The secure RNG draws from the platform CSPRNG, so generated names cannot be
// predicted. A plain non-secure Random is seedable and its sequence repeats,
// which would make temp names guessable and enable temp-file race/hijack
// attacks (an attacker pre-creates the name). Unguessable names are the point.
final Random _random = Random.secure();

/// Returns a short, unpredictable alphanumeric string suitable for temp file
/// names. Backed by [Random.secure] so names cannot be guessed.
///
/// Throws [ArgumentError] if [length] is not positive — a zero/negative length
/// cannot be collision-resistant.
/// Audited: 2026-06-12 11:26 EDT
String safeTempName({int length = 12}) {
  if (length <= 0) {
    throw ArgumentError.value(length, 'length', 'must be > 0');
  }
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
}
