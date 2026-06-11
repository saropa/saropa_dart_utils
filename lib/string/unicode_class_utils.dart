import 'package:saropa_dart_utils/string/unicode_class_blocks.dart';
import 'package:saropa_dart_utils/string/unicode_class_type.dart';

// Re-export the block descriptor and range table so direct importers of this
// file (and the barrel) keep seeing the unchanged public API after the data
// table was moved to unicode_class_blocks.dart to satisfy the 200-line file
// limit. UnicodeClass and unicodeClassRanges remain reachable from here.
export 'package:saropa_dart_utils/string/unicode_class_blocks.dart'
    show UnicodeClass, unicodeClassRanges;

/// Returns the Unicode named block ([UnicodeClassType]) that the string's first
/// qualifying rune belongs to, or `null` when the trimmed string is empty or no
/// block matches.
///
/// Scanning rules:
/// - [ignoreBasicLatin]: skip the [UnicodeClassType.BasicLatin] block so a
///   Latin-prefixed string (e.g. `"ignore <arabic>"`) reports the non-Latin
///   script that follows instead of Latin.
/// - [firstCharOnly] (default `true`): classify only the first qualifying rune.
///   Set `false` to keep scanning runes until one matches a non-ignored block.
/// - [ignoreWhitespace] (default `true`): skip whitespace runes while scanning.
///
/// Edge cases:
/// - Calls [String.trim] first. Dart's `trim` strips most but not all Unicode
///   whitespace (e.g. the narrow no-break space survives `trim`); the
///   [ignoreWhitespace] path — not `trim` — is what skips those.
/// - BMP-only: a rune above U+FFFF (most emoji, decoded from a surrogate pair)
///   matches no block and yields `null`.
/// - Unassigned gaps between blocks (e.g. U+0750..U+077F) also yield `null`.
/// - Never throws: any unexpected failure is swallowed and reported as `null`,
///   because callers use this for best-effort script detection, not validation.
///
/// Example:
/// ```dart
/// findUnicodeClassType('a');                 // UnicodeClassType.BasicLatin
/// findUnicodeClassType('相浦');               // UnicodeClassType.CJKUnifiedIdeographs
/// findUnicodeClassType('ignore اختبار',
///     ignoreBasicLatin: true, firstCharOnly: false); // UnicodeClassType.Arabic
/// ```
UnicodeClassType? findUnicodeClassType(
  String value, {
  bool ignoreBasicLatin = false,
  bool firstCharOnly = true,
  bool ignoreWhitespace = true,
}) {
  // Best-effort by contract: callers treat this as script detection, so a
  // surprising rune must never crash the scan — fall back to null on any error.
  try {
    // Only trim when whitespace is being ignored. Dart's trim() strips Unicode
    // space separators (NBSP U+00A0, en-space U+2002, ideographic space U+3000,
    // ogham space U+1680, etc.), so trimming unconditionally would discard the
    // very runes a caller asking ignoreWhitespace:false wants classified into
    // their block. Local copy keeps the caller's original input intact.
    final String scanned = ignoreWhitespace ? value.trim() : value;

    // Guard early: nothing to classify once the scanned form is empty.
    if (scanned.isEmpty) {
      return null;
    }

    for (final int rune in scanned.runes) {
      // Pure-Dart whitespace check replaces the original quiver.isWhitespace
      // dependency. Skipping whitespace lets leading spaces or tabs pass so the
      // first real script wins under firstCharOnly.
      if (ignoreWhitespace && isUnicodeWhitespace(rune)) {
        continue;
      }

      // Block lookup is extracted to keep this loop shallow; the helper returns
      // the first matching (lowest) block or null when the rune sits in a gap.
      final UnicodeClassType? matched = _blockForRune(rune, ignoreBasicLatin: ignoreBasicLatin);
      if (matched != null) {
        return matched;
      }

      // Default: the first non-whitespace rune decides, even when it matched no
      // block (falls through to null) or was the ignored Latin block. Set
      // firstCharOnly:false to keep scanning to the next rune instead.
      if (firstCharOnly) {
        break;
      }
    }

    return null;
  }
  // Intentionally silent: this helper's public contract is "best-effort script
  // detection, never throws". The scan is pure arithmetic over runes against a
  // const table, so a throw here would signal an unexpected platform fault on a
  // pathological string; the documented fallback for every failure mode is the
  // same null an empty/unmatched string returns. No security or data-integrity
  // path runs through here, so there is nothing to log or rethrow.
  // ignore: avoid_swallowing_exceptions, require_catch_logging -- documented no-throw contract; null is the universal fallback
  on Object catch (_) {
    return null;
  }
}

/// Returns the first named block containing [rune], or null when [rune] falls in
/// an unassigned gap between blocks.
///
/// Extracted from [findUnicodeClassType] so the caller's rune loop stays shallow
/// (one nesting level instead of two). Honors [ignoreBasicLatin] so a Latin rune
/// reports as unmatched (null) when the caller is scanning for a non-Latin script.
UnicodeClassType? _blockForRune(int rune, {required bool ignoreBasicLatin}) {
  // First match wins: ranges are sorted ascending and non-overlapping, so the
  // first containing block is the correct (lowest) one for this rune.
  for (final UnicodeClass uni in unicodeClassRanges) {
    if (ignoreBasicLatin && uni.type == UnicodeClassType.BasicLatin) {
      continue;
    }
    if (uni.start <= rune && rune <= uni.end) {
      return uni.type;
    }
  }
  return null;
}

/// Set of code points treated as whitespace by [findUnicodeClassType].
///
/// This is the pure-Dart replacement for the removed `quiver.isWhitespace`
/// dependency. It covers the ASCII whitespace controls plus the Unicode space
/// separators that `String.trim` does not always remove, so the
/// [ignoreWhitespace] scan behaves consistently across every flavor of space.
///
/// Edge cases:
/// - Returns `false` for every non-whitespace rune, including BMP letters and
///   astral code points, so it is safe to call on any rune.
///
/// Example:
/// ```dart
/// isUnicodeWhitespace(0x20);   // true  (space)
/// isUnicodeWhitespace(0x202F); // true  (narrow no-break space)
/// isUnicodeWhitespace(0x41);   // false ('A')
/// ```
bool isUnicodeWhitespace(int rune) => _whitespaceRunes.contains(rune);

/// The whitespace code points recognized by [isUnicodeWhitespace].
///
/// A `Set` literal gives O(1) membership and keeps the list auditable against
/// the Unicode `White_Space` property used by the original predicate.
const Set<int> _whitespaceRunes = <int>{
  0x09, // tab
  0x0A, // line feed
  0x0B, // vertical tab
  0x0C, // form feed
  0x0D, // carriage return
  0x20, // space
  0x85, // next line (NEL)
  0xA0, // no-break space
  0x1680, // ogham space mark
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, // en/em quad family
  0x2005, 0x2006, 0x2007, 0x2008, 0x2009, 0x200A, // remaining U+2000..U+200A
  0x2028, // line separator
  0x2029, // paragraph separator
  0x202F, // narrow no-break space
  0x205F, // medium mathematical space
  0x3000, // ideographic space
};
