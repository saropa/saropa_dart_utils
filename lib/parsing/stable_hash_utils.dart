/// Order-stable structural checksum with no crypto dependency — roadmap #649.
///
/// Produces a deterministic canonical text for JSON-like data and an FNV-1a
/// 64-bit hash of it. Map key insertion order does NOT affect the result (keys
/// are sorted), but list order DOES (lists preserve order). Useful for cache
/// keys, change detection, and deduplication where a stable, repeatable digest
/// is needed without pulling in a cryptographic hash.
///
/// Platform note (important): the digest is stable per platform but NOT across
/// the VM/web boundary. The FNV-1a multiply relies on the VM's 64-bit
/// two's-complement wrap; on the web (dart2js) `int` is a 53-bit double and
/// bitwise ops truncate to 32 bits, so the same input produces a DIFFERENT
/// digest on web than on the VM. Do not use it as a shared key between a VM
/// client and a web client. See
/// https://dart.dev/resources/language/number-representation.
library;

/// FNV-1a 64-bit offset basis.
const int _fnvOffset = 0xcbf29ce484222325;

/// FNV-1a 64-bit prime.
const int _fnvPrime = 0x100000001b3;

/// Builds a deterministic canonical string for [value].
///
/// Maps emit their keys sorted by `toString()`; lists keep their order; strings
/// are quoted; `null`, [num], and [bool] are normalized to plain text. Recurses
/// to the value's nesting depth, so it is not intended for untrusted,
/// arbitrarily-deep input (deep nesting can exhaust the stack).
///
/// Example:
/// ```dart
/// canonicalString(<String, Object?>{'b': 1, 'a': 2}); // {"a":2,"b":1}
/// ```
/// Audited: 2026-06-12 11:26 EDT
String canonicalString(Object? value) {
  if (value == null) {
    return 'null';
  }
  // Quote strings so they can never be confused with literals like null/true.
  if (value is String) {
    return '"$value"';
  }
  if (value is bool || value is num) {
    return value.toString();
  }
  if (value is List<Object?>) {
    return _canonicalList(value);
  }
  if (value is Map<Object?, Object?>) {
    return _canonicalMap(value);
  }
  // Fallback for any other type: its own string form, quoted for safety.
  return '"$value"';
}

/// Canonicalizes a list, preserving element order so order is significant.
/// Audited: 2026-06-12 11:26 EDT
String _canonicalList(List<Object?> list) {
  final List<String> parts = <String>[
    for (final Object? element in list) canonicalString(element),
  ];
  return '[${parts.join(',')}]';
}

/// Canonicalizes a map with keys sorted by `toString()` so insertion order is
/// irrelevant to the output.
/// Audited: 2026-06-12 11:26 EDT
String _canonicalMap(Map<Object?, Object?> map) {
  final List<Object?> keys = map.keys.toList()
    ..sort((Object? a, Object? b) => a.toString().compareTo(b.toString()));
  final List<String> parts = <String>[
    // Keys render via their toString(); a null key becomes the literal "null",
    // which is fine here — the canonical form just needs to be deterministic.
    for (final Object? key in keys) '"${key.toString()}":${canonicalString(map[key])}',
  ];
  return '{${parts.join(',')}}';
}

/// Returns the FNV-1a 64-bit hash of [canonicalString] of [value] as a
/// lowercase hex string.
///
/// Determinism: on a given platform, equal inputs always yield equal hashes
/// within a run and across runs. (Across the VM/web boundary the digests differ
/// — see the library-level platform note.) Map key order does NOT change the
/// hash (keys are sorted first); list order DOES. `null` and the string
/// `"null"` differ because strings are quoted in the canonical form.
///
/// Example:
/// ```dart
/// stableHash(<String, int>{'a': 1, 'b': 2}) ==
///     stableHash(<String, int>{'b': 2, 'a': 1}); // true
/// ```
/// Audited: 2026-06-12 11:26 EDT
String stableHash(Object? value) {
  final String text = canonicalString(value);
  // FNV-1a over UTF-16 code units. Dart VM ints are 64-bit two's-complement and
  // wrap on overflow, so the multiply naturally stays in 64 bits.
  int hash = _fnvOffset;
  for (final int unit in text.codeUnits) {
    hash = (hash ^ unit) * _fnvPrime;
  }
  // The 64-bit value is often negative as a signed int, and toRadixString would
  // emit a leading '-'. toUnsigned(64) is a no-op on a VM int (the 1<<64 mask
  // wraps to -1), so render the two 32-bit halves separately: `>> 32` then mask
  // gives a positive high word, the low mask a positive low word — a stable,
  // sign-free 16-digit lowercase hex (per platform; see the platform note).
  final int high = (hash >> 32) & 0xFFFFFFFF;
  final int low = hash & 0xFFFFFFFF;
  return high.toRadixString(16).padLeft(8, '0') + low.toRadixString(16).padLeft(8, '0');
}
