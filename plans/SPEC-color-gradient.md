# SPEC: StopRange (gradient stop ranges) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/double/gradient_stop_range.dart
**Portability:** Pure Dart. The single proposed member (`StopRange`) is a plain
enum returning `List<double>` — no Flutter, no `dart:ui`, no external packages.
The rest of the source file is Flutter-only and Saropa-specific (see Excluded).

## Purpose — what it does + why it is general-purpose (not proprietary)

`StopRange` is a small enum that maps four named easing categories
(`easeIn`, `easeOut`, `easeInOut`, `linear`) to a two-element `List<double>`
of normalized gradient stops in the 0..1 range:

| Variant | `stops` |
|---|---|
| `easeIn` | `[0, 0.5]` |
| `easeOut` | `[0.5, 1]` |
| `easeInOut` | `[0.25, 0.75]` |
| `linear` | `[0, 1]` |

This is general-purpose: any gradient API that accepts a `List<double>` of stops
(Flutter `Gradient.stops`, a CSS-string builder, an SVG `<stop>` generator, a
custom shader) can consume these values. The enum carries no app, brand, or
contact-domain knowledge — it is pure numeric data keyed by a readable name,
which is exactly the kind of bulletproof, fully-tested constant the library
exists to hold.

### Excluded members (NOT proposed — app-specific / Flutter-coupled)

| Member | Why excluded |
|---|---|
| `GradientCache` (abstract final class) | Caches a Saropa brand `RadialGradient`; depends on `BuildContext`, holds top-level mutable state, proprietary. |
| `GradientCache.saropaRadialGradient(context)` | Returns the Saropa-branded radial gradient — proprietary brand colors and Flutter `BuildContext`. |
| `GradientCache._createRadialGradient(...)` | Private; builds a Flutter `RadialGradient` from `ThemeCommonColor.BrandSaropaLighter` / `BrandSaropa` (Saropa brand palette). Flutter-coupled and proprietary. |
| `debugException(...)` calls + `debug.dart` import | Saropa Crashlytics/debug reporting — stripped per inclusion rules. |
| `package:flutter/material.dart` import | Only needed by the excluded `GradientCache`; `StopRange` is pure Dart. |
| `package:saropa/theme/theme_common_color.dart` import | Proprietary brand palette; only used by the excluded members. |

Note: `StopRange` is currently consumed only by the excluded `_createRadialGradient`
(via `stopRange.stops`), but the enum itself has no dependency on it and stands
alone as a reusable constant set.

## Source (from Saropa Contacts) — general-purpose member, verbatim (debug logging stripped)

```dart
/// Named easing categories mapped to normalized gradient stop pairs (0..1).
///
/// Each variant returns a two-element [List] of `double` stops suitable for any
/// gradient API that accepts a `stops` list. Values are fixed constants:
///
/// - [StopRange.easeIn]    => [0, 0.5]   (front-loaded transition)
/// - [StopRange.easeOut]   => [0.5, 1]   (back-loaded transition)
/// - [StopRange.easeInOut] => [0.25, 0.75] (centered transition)
/// - [StopRange.linear]    => [0, 1]     (full-range, even transition)
enum StopRange {
  easeIn,
  easeOut,
  easeInOut,
  linear;

  List<double> get stops => switch (this) {
    StopRange.easeIn => <double>[0, 0.5],
    StopRange.easeOut => <double>[0.5, 1],
    StopRange.easeInOut => <double>[0.25, 0.75],
    StopRange.linear => <double>[0, 1],
  };
}
```

## Test cases — none exist in Saropa Contacts; proposed cases below

No `*_test.dart` covers `StopRange` or `GradientCache` in the Saropa Contacts
repo (the two gradient-named test files there cover unrelated border widgets).
Proposed tests:

```dart
import 'package:flutter_test/flutter_test.dart';
// import 'package:saropa_dart_utils/double/gradient_stop_range.dart';

void main() {
  group('StopRange.stops', () {
    test('easeIn returns [0, 0.5]', () {
      expect(StopRange.easeIn.stops, equals(<double>[0, 0.5]));
    });

    test('easeOut returns [0.5, 1]', () {
      expect(StopRange.easeOut.stops, equals(<double>[0.5, 1]));
    });

    test('easeInOut returns [0.25, 0.75]', () {
      expect(StopRange.easeInOut.stops, equals(<double>[0.25, 0.75]));
    });

    test('linear returns [0, 1]', () {
      expect(StopRange.linear.stops, equals(<double>[0, 1]));
    });

    test('every variant returns exactly two stops', () {
      for (final StopRange range in StopRange.values) {
        expect(range.stops, hasLength(2));
      }
    });

    test('every variant is ordered ascending (start <= end)', () {
      for (final StopRange range in StopRange.values) {
        final List<double> s = range.stops;
        expect(s.first, lessThanOrEqualTo(s.last));
      }
    });

    test('every stop is within the normalized 0..1 range', () {
      for (final StopRange range in StopRange.values) {
        for (final double stop in range.stops) {
          expect(stop, inInclusiveRange(0.0, 1.0));
        }
      }
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

`StopRange` has no inputs (it is a constant-returning enum), so the edge cases
are structural / invariant guarantees rather than value-domain extremes:

- **Exhaustiveness** — assert `StopRange.values` has exactly 4 entries, so a
  newly-added variant forces an explicit test update (catches a future variant
  silently shipping with no `stops` coverage).
- **Stable identity / no mutation leak** — each `stops` getter returns a fresh
  literal; verify that mutating a returned list (e.g. `..add(2)`) does NOT
  affect a subsequent `.stops` call on the same variant (guards against a future
  refactor that caches and returns a shared mutable list).
- **Boundary stops** — `easeIn` starts at exactly `0.0`, `easeOut` ends at
  exactly `1.0`; assert these endpoints land on the boundary, not just inside it.
- **Strictly-increasing where intended** — for all variants assert
  `first < last` (none is degenerate / zero-width); a zero-width stop pair would
  produce a hard color edge in any consumer.
- **`name` / `index` round-trip** — `StopRange.values[i].index == i` and
  `StopRange.values.byName('easeInOut') == StopRange.easeInOut` (protects
  serialization consumers if the enum is ever persisted by name).
- **No NaN / infinity** — assert every stop `isFinite` (defends against a future
  computed-stops refactor introducing `double.infinity` / `double.nan`).
- **Documentation parity** — a meta-test (or doc comment) asserting the four
  documented pairs match the runtime values, so the dartdoc table can't drift
  from the `switch`.

## Library overlap

The installed `saropa_dart_utils-1.4.1` has **no `color`/`colour` directory** and
no gradient/stop helper (categories present: async, base64, bool, caching,
collections, datetime, double, enum, gesture, graph, hex, html, int, iterable,
json, list, map, niche, num, object, parsing, random, regex, stats, string,
testing, url, uuid, validation). No overlapping symbol — this is net-new.
`lib/double/` is the closest fit since `stops` is a `List<double>` constant.
