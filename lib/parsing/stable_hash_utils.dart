/// Order-stable structural checksum with no crypto dependency — roadmap #649.
///
/// Produces a deterministic canonical text for JSON-like data and an FNV-1a
/// 64-bit hash of it. Map key insertion order does NOT affect the result (keys
/// are sorted), but list order DOES (lists preserve order). Useful for cache
/// keys, change detection, and deduplication where a stable, repeatable digest
/// is needed without pulling in a cryptographic hash.
///
/// The digest is identical on every platform, including the web. The 64-bit
/// FNV-1a is computed with 32-bit limbs (see [_mulMod64]) because a native
/// `int * prime` relies on the VM's 64-bit two's-complement wrap, which the
/// web's 53-bit-double `int` model lacks; the limb form reproduces the exact
/// mod-2^64 arithmetic everywhere. The result also matches the value the older
/// native implementation produced on the VM, so previously persisted digests
/// stay valid. See https://dart.dev/resources/language/number-representation.
library;

// FNV-1a 64-bit offset basis 0xcbf29ce484222325, split into 32-bit halves so
// the constant itself is exact on the web (the full literal exceeds 2^53 and
// would round). Hi = bits 32-63, Lo = bits 0-31.
const int _fnvOffsetHi = 0xcbf29ce4;
const int _fnvOffsetLo = 0x84222325;

// FNV-1a 64-bit prime 0x100000001b3, split the same way.
const int _fnvPrimeHi = 0x00000100;
const int _fnvPrimeLo = 0x000001b3;

/// Mask for one 32-bit limb.
const int _mask32 = 0xFFFFFFFF;

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
  // FNV-1a over UTF-16 code units, held as two 32-bit limbs (hi:lo) so the
  // mod-2^64 multiply is computed identically on the VM and the web. XOR the
  // datum into the low limb (FNV-1a), then multiply the full 64-bit value by the
  // prime via _mulMod64. This reproduces the exact result the native
  // `(hash ^ unit) * prime` produced on the VM.
  int hi = _fnvOffsetHi;
  int lo = _fnvOffsetLo;
  for (final int unit in text.codeUnits) {
    final int xored = (lo ^ unit) & _mask32;
    final (int nextHi, int nextLo) = _mulMod64(hi, xored, _fnvPrimeHi, _fnvPrimeLo);
    hi = nextHi;
    lo = nextLo;
  }
  // Both limbs are already unsigned 32-bit, so each renders as a sign-free
  // 8-digit hex word; concatenated they are the stable 16-digit digest.
  return hi.toRadixString(16).padLeft(8, '0') + lo.toRadixString(16).padLeft(8, '0');
}

/// 64-bit product `(aHi:aLo) * (bHi:bLo)` reduced mod 2^64, returned as
/// `(hi, lo)` 32-bit limbs.
///
/// `a*b mod 2^64 = (aLo*bLo) + ((aLo*bHi + aHi*bLo) mod 2^32) << 32`. The high
/// cross terms above bit 63 are discarded by the modulus, so only the low 32
/// bits of each cross product matter. Every intermediate is kept below 2^53 via
/// [_mul3232] so the arithmetic is exact under the web's double-backed `int`.
(int, int) _mulMod64(int aHi, int aLo, int bHi, int bLo) {
  final (int llHi, int llLo) = _mul3232(aLo, bLo);
  final int cross = (_mul3232(aLo, bHi).$2 + _mul3232(aHi, bLo).$2) & _mask32;
  return ((llHi + cross) & _mask32, llLo);
}

/// 64-bit product of two 32-bit values, returned as `(hi, lo)` 32-bit limbs.
///
/// Splits each operand into 16-bit halves so no partial product exceeds 2^32 and
/// no running sum exceeds ~2^33 — all well under 2^53, hence exact on the web.
(int, int) _mul3232(int a, int b) {
  final int aLo = a & 0xFFFF;
  final int aHi = (a >>> 16) & 0xFFFF;
  final int bLo = b & 0xFFFF;
  final int bHi = (b >>> 16) & 0xFFFF;
  final int ll = aLo * bLo;
  final int lh = aLo * bHi;
  final int hl = aHi * bLo;
  final int hh = aHi * bHi;
  // Accumulate the 16-bit columns with carries: bits 0-15 from ll, bits 16-31
  // from ll's high half plus the low halves of the cross terms, the rest into hi.
  final int carry = (ll >>> 16) + (lh & 0xFFFF) + (hl & 0xFFFF);
  final int lo = ((ll & 0xFFFF) | ((carry & 0xFFFF) << 16)) & _mask32;
  final int hi = (hh + (lh >>> 16) + (hl >>> 16) + (carry >>> 16)) & _mask32;
  return (hi, lo);
}
