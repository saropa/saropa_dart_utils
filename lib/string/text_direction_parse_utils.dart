/// Pure-Dart parser for the CSS/HTML/Unicode `ltr` / `rtl` direction tokens.
///
/// The package is Flutter-free by design, so this ships the pure-Dart enum
/// variant rather than returning Flutter's `dart:ui` `TextDirection` — pulling
/// Flutter in for a one-line wrapper would be a portability regression for
/// every consumer. Callers map [TextWritingDirection] to the framework type at
/// the UI boundary if they need it.
library;

/// Writing direction parsed from a short token, with no Flutter dependency.
///
/// Mirrors the CSS/HTML/Unicode `ltr` / `rtl` direction tokens used in config,
/// JSON, and locale data. The caller maps to Flutter's `TextDirection` at the
/// UI boundary if needed, keeping this package free of any framework import.
///
/// Example:
/// ```dart
/// TextDirectionParseUtils.tryParse('rtl'); // TextWritingDirection.rtl
/// ```
enum TextWritingDirection {
  /// Left-to-right writing direction (e.g. Latin, CJK), token `'ltr'`.
  ltr,

  /// Right-to-left writing direction (e.g. Arabic, Hebrew), token `'rtl'`.
  rtl,
}

/// Parses a short text-direction token into a typed [TextWritingDirection].
///
/// A "parse a short enum token from config / JSON / locale data" helper for the
/// universal `'ltr'` / `'rtl'` direction strings. Nothing app-specific: these
/// are the CSS/HTML/Unicode direction tokens, so the parser is general-purpose
/// for turning a persisted or transmitted direction string back into a value.
abstract final class TextDirectionParseUtils {
  /// Parses `'ltr'` / `'rtl'` (case-insensitive, whitespace-trimmed) into a
  /// [TextWritingDirection]; returns null for anything else — never throws.
  ///
  /// Matching rules, pinned so config/JSON round-trips stay stable:
  /// - Case-insensitive: `'LTR'`, `'Ltr'`, `'rTl'` all resolve.
  /// - Only LEADING/TRAILING whitespace is stripped (via `String.trim()`), so
  ///   inner-space tokens like `'l t r'` are rejected — there is no substring
  ///   or partial matching (`'ltrx'`, `'xrtl'`, `'ltr;'` → null).
  /// - `String.trim()` strips Unicode whitespace too (U+00A0 NBSP, thin space,
  ///   ideographic space), so `' ltr '` parses; but it does NOT strip
  ///   zero-width chars (U+200B, U+FEFF BOM), so those leading a token → null.
  /// - The Unicode direction MARKS themselves (LRM U+200E, RLM U+200F) are not
  ///   the literal tokens and so → null.
  /// - No normalization or case-folding beyond ASCII lowercasing: full-width
  ///   `'ｌｔｒ'`, accented `'ĺtr'`, and emoji never match.
  /// - Lowercasing is invariant/ASCII-only here (`L`/`T`/`R`), so the result is
  ///   independent of the active locale — no Turkish-I dotless-i pitfall.
  ///
  /// Total function: returns null (never throws) for null, empty,
  /// whitespace-only, numeric strings, control characters, and arbitrarily long
  /// junk — safe to call on any untrusted input.
  ///
  /// Example:
  /// ```dart
  /// TextDirectionParseUtils.tryParse('  LTR ');  // TextWritingDirection.ltr
  /// TextDirectionParseUtils.tryParse('auto');    // null
  /// TextDirectionParseUtils.tryParse(null);      // null
  /// ```
  static TextWritingDirection? tryParse(String? value) =>
      // Null-safe chain: `?.` short-circuits a null input to the `_ => null`
      // arm, and switch's exhaustive default makes every unmatched token null,
      // so no path can throw regardless of the string's content.
      switch (value == null ? null : _trim(value).toLowerCase()) {
        'rtl' => TextWritingDirection.rtl,
        'ltr' => TextWritingDirection.ltr,
        _ => null,
      };

  // Dart's `String.trim()` strips U+FEFF (BOM / zero-width no-break space) as
  // whitespace, but the spec pins BOM as NOT whitespace so a BOM-prefixed token
  // must stay unrecognized. Re-stick any BOM that trim removed at the edges so
  // `'﻿ltr'` keeps its BOM and falls through to null, while real Unicode
  // whitespace (NBSP, thin/ideographic space) is still trimmed as before.
  static String _trim(String value) {
    final trimmed = value.trim();
    if (!value.contains('﻿')) {
      return trimmed;
    }
    // Restore a leading/trailing BOM so the token no longer equals 'ltr'/'rtl'.
    final hasLeadingBom = value.startsWith('﻿') && !trimmed.startsWith('﻿');
    final hasTrailingBom = value.endsWith('﻿') && !trimmed.endsWith('﻿');
    return '${hasLeadingBom ? '﻿' : ''}$trimmed${hasTrailingBom ? '﻿' : ''}';
  }
}
