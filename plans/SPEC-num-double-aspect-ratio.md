# SPEC: double.toAspectRatio — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/double/double_extensions.dart (new method on existing `DoubleExtensions`)
**Portability:** Pure Dart. No Flutter, no external packages. Depends only on
two symbols already shipped in this library:
- `DoubleExtensions.hasDecimals` (already in `lib/double/double_extensions.dart`)
- `IntUtils.findGreatestCommonDenominator` (already in `lib/int/int_utils.dart`)

## Purpose — what it does + why it is general-purpose (not proprietary)

`toAspectRatio()` converts a decimal ratio (e.g. an image's `width / height`
value) into a GCD-simplified integer pair `(int, int)`. For example `1.5`
(3:2) should yield `(3, 2)`; `1.7777...` (16:9) should yield `(16, 9)`.

It is a generic numeric helper: it takes a `double`, quantizes the fractional
part to three decimal places (`× 1000`), and reduces `numerator / 1000` by
their greatest common denominator. There is no contact-domain logic, no
Saropa-specific format, no UI, no l10n, no logging. The only library
dependency is the GCD utility this package already exposes — so it is a natural
extension of the existing `DoubleExtensions`.

### Overlap check (saropa_dart_utils 1.4.1)

- `lib/double/double_extensions.dart` — has `hasDecimals`, `toPercentage`,
  `formatDouble`, `clamp`-style helpers, `toPrecision`. **No `toAspectRatio`.**
- `lib/int/int_utils.dart` — has `findGreatestCommonDenominator(int a, int b)`
  which this method calls. Already present; not duplicated here.
- `lib/num/*` — clamp / lerp / modulo / prime / round-multiple / range / stats
  utilities. **No aspect-ratio reducer.**

Conclusion: the GCD dependency and `hasDecimals` are already in the library;
`toAspectRatio` itself is **net-new**. This spec adds only the new method onto
the existing extension.

## Source (from Saropa Contacts) — verbatim general-purpose member

Excluded from the source file (not proposed here):
- `formatLatLong()` — thin wrapper over the already-migrated library
  `formatDouble(6, ...)`; app-leaning lat/long formatting, out of scope.
- All commented-out members (`toPercentage`, `formatDouble`, `forceBetween`,
  `toPrecision`, `formatPrecision`) — already migrated into the library.

The candidate has no `debug()` / `DebugType` logging to strip (it returns
`null` on failure rather than reporting). Verbatim:

```dart
extension DoubleExtensions on double {
  /// Converts this decimal ratio into a GCD-simplified integer aspect-ratio
  /// pair `(width, height)`.
  ///
  /// The fractional part is quantized to three decimal places (`× 1000`) and
  /// the resulting `numerator / 1000` fraction is reduced by its greatest
  /// common denominator.
  ///
  /// Returns `null` when the GCD cannot be computed.
  (int, int)? toAspectRatio() {
    if (!hasDecimals) {
      return (1, toInt());
    }

    // Convert the ratio to a fraction at three decimal places of precision.
    final int numerator = (this * 1000).toInt();
    const int denominator = 1000;

    // Simplify the ratio by dividing both numerator and denominator by their GCD.
    final int? commonDivisor =
        IntUtils.findGreatestCommonDenominator(numerator, denominator);
    if (commonDivisor == null) {
      return null;
    }

    final int simplifiedNumerator = numerator ~/ commonDivisor;
    final int simplifiedDenominator = denominator ~/ commonDivisor;

    return (simplifiedDenominator, simplifiedNumerator);
  }
}
```

### Behavior notes / pre-existing quirks the library version MUST decide on

These are flagged so the library implementation is intentional, not a blind
copy. They are real semantics of the harvested code, not hypotheticals:

1. **Tuple order looks swapped.** The method computes
   `simplifiedNumerator` / `simplifiedDenominator` but returns
   `(simplifiedDenominator, simplifiedNumerator)`. So `1.5` (`numerator=1500`,
   `denominator=1000`, GCD=500) returns `(2, 3)`, not `(3, 2)`. Decide and
   document whether the library API returns `(width, height)` or
   `(height, width)`, then lock it with tests. (Recommendation: name the
   record fields — `({int width, int height})` — so order is self-documenting
   rather than positional.)

2. **Whole-number branch returns `(1, toInt())`.** For `3.0` it returns
   `(1, 3)`, i.e. `1:3`, NOT `3:1`. This is consistent with the swapped order
   above but is surprising for a "value is already an integer" path. Decide the
   intended pair for integral inputs and test it explicitly.

3. **3-decimal quantization is lossy.** `16/9 = 1.7777...` becomes
   `1777/1000` → reduced `1777/1000` (GCD 1), NOT `16/9`. The method does NOT
   recover canonical small ratios; it reduces the truncated 3-dp fraction.
   Document this limit, or add an optional tolerance/precision parameter.

4. **`null` is effectively unreachable here.** `findGreatestCommonDenominator`
   returns null only when both args are 0 (or recursion depth exceeded).
   `denominator` is the constant `1000`, so the only way to reach the null
   branch is the depth guard. Keep the nullable return for API honesty but note
   it almost never fires from this call site.

## Test cases — existing tests

The Saropa Contacts test file
`test/utils/primitive/number/double_extensions_test.dart` covers ONLY
`formatDouble` (a library-migrated method). **There are no existing tests for
`toAspectRatio`.** Proposed cases below (encode the chosen tuple order once the
library decides — written here against the source's current
`(simplifiedDenominator, simplifiedNumerator)` order):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_extensions.dart';

void main() {
  group('DoubleExtensions.toAspectRatio', () {
    test('simplifies a 3:2 decimal (1.5)', () {
      // 1500/1000 reduced by GCD 500 -> (2, 3) in source order
      expect(1.5.toAspectRatio(), (2, 3));
    });

    test('simplifies a quarter step (1.25)', () {
      // 1250/1000 reduced by GCD 250 -> (4, 5) in source order
      expect(1.25.toAspectRatio(), (4, 5));
    });

    test('whole number returns (1, value)', () {
      expect(3.0.toAspectRatio(), (1, 3));
    });

    test('one returns (1, 1)', () {
      expect(1.0.toAspectRatio(), (1, 1));
    });

    test('non-canonical 16:9 reduces the truncated 3-dp fraction', () {
      // 1.7777... -> 1777/1000, GCD 1 -> (1000, 1777) in source order
      expect((16 / 9).toAspectRatio(), (1000, 1777));
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Zero:** `0.0.toAspectRatio()` → `hasDecimals` is false →
  `(1, 0)`. Assert and decide if `0` is a valid height/width.
- **Negative whole:** `(-2.0).toAspectRatio()` → `(1, -2)`. Decide whether
  negatives should be normalized (abs) or rejected (null).
- **Negative fractional:** `(-1.5).toAspectRatio()` → `numerator = -1500`;
  `findGreatestCommonDenominator(-1500, 1000)` returns **null** (it rejects
  negative args), so the method returns **null**. Test this — it is the one
  realistic null path. Decide if negative fractional input should be supported.
- **NaN:** `double.nan.toAspectRatio()` → `hasDecimals` returns false for NaN
  (library guard) → `NaN.toInt()` **throws `UnsupportedError`**. Add a NaN
  guard returning `null` and test it.
- **Infinity:** `double.infinity.toAspectRatio()` → `hasDecimals` false →
  `infinity.toInt()` **throws `UnsupportedError`**. Same for
  `negativeInfinity`. Add an infinity guard returning `null` and test both.
- **Sub-millis precision (rounds to whole):** `1.0004.toAspectRatio()` →
  `numerator = (1.0004 * 1000).toInt() = 1000` → `(1, 1)`. Confirms 3-dp
  truncation; test it as the documented precision floor.
- **Truncation vs rounding:** `1.9999.toAspectRatio()` → `1999/1000` →
  `(1000, 1999)`. `(this * 1000).toInt()` truncates toward zero; verify
  `1.0009` → `1000` (not `1001`), pinning truncation semantics.
- **Floating-point representation:** values like `0.1`, `0.3` whose binary
  form is inexact — `0.3 * 1000` is `299.99999...`, `.toInt()` → `299`, so
  `0.3.toAspectRatio()` → `299/1000` → `(1000, 299)`. Test to lock the
  representation-dependent result.
- **Large magnitude:** `1.0e9.toAspectRatio()` → `hasDecimals` false →
  `(1, 1000000000)`; and a huge fractional like `1.0e9 + 0.5` where
  `× 1000` overflows precision — assert behavior or document the safe range.
- **Smallest fractional:** `0.001.toAspectRatio()` → `1/1000` GCD 1 →
  `(1000, 1)`. Boundary of representable precision.
- **GCD recursion depth:** craft an input whose `numerator` forces deep
  Euclid recursion to confirm the `maxDepth` null path is unreachable from a
  fixed `1000` denominator (or document the bound).
- **Tuple-order regression test:** once the library fixes/confirms order, add
  one explicit `width`/`height` named-field assertion so a future refactor
  can't silently swap them.

(Locale, leap-year, DST, unicode/emoji edge cases are N/A — this is a pure
numeric reducer with no string, date, or locale surface.)
