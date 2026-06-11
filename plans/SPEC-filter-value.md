# SPEC: FilterValue&lt;T&gt; — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/copy_with/filter_value.dart
**Portability:** Pure Dart. No Flutter, no external packages. A single immutable
generic value class with two const constructors and one resolver method.

## Purpose — what it does + why it is general-purpose (not proprietary)

`FilterValue<T>` is an optional-write wrapper for `copyWith` parameters that need
to distinguish three intents instead of two:

1. **unset** — "keep the current value" (no override given)
2. **set to a value** — "override with this non-null value"
3. **set to null** — "explicitly clear the field back to null"

The default `copyWith` idiom (`field: newField ?? this.field`) collapses intents
1 and 3: passing `null` always reads as "no override given", so a nullable field
can never be reset to null through the idiomatic pattern. The common workaround
is a companion `bool fieldForceNull = false` parameter per nullable field, which
doubles the parameter surface and forces a non-idiomatic convention on both call
sites and readers.

`FilterValue<T>` replaces that workaround. `FilterValue.unset()` (the default)
carries `isSet: false` and resolves to the current value; any explicit
`FilterValue(v)` — including `FilterValue(null)` — carries `isSet: true` and
overrides. `resolve(current)` performs the keep-vs-override decision in one call.

This is a pure data/value pattern with zero domain coupling: it is the Dart
analogue of an `Optional`/`Patch`/sentinel "field present vs absent" wrapper used
in any partial-update or tri-state-filter context. Nothing about it references
contacts, filters specific to the app, or any Saropa format — the source class is
already free of `debug()` / l10n / Crashlytics / icon / search-syntax code, so no
stripping was required.

### Excluded members

None. The source file contains only the general-purpose `FilterValue<T>` class
(two constructors, two fields, one method) and its dartdoc. There is no
proprietary, app-specific, or logging code to exclude.

## Source (from Saropa Contacts) — verbatim general-purpose members

```dart
/// Optional-write wrapper for `copyWith` parameters that need to distinguish
/// "keep the current value" from "explicitly clear to null".
///
/// Default `copyWith` parameters of type `T?` collapse the two intents: passing
/// `null` always reads as "no override given". For filter classes that store
/// nullable fields (tri-state booleans like `hasFoo: true / false / null`),
/// callers cannot reset a previously-set field back to null through the
/// idiomatic `?? this.field` pattern.
///
/// Pass `FilterValue<T>` as the parameter type instead. The default
/// `FilterValue.unset()` carries `isSet: false` (keep current); any explicit
/// `FilterValue(v)` (including `FilterValue(null)`) carries `isSet: true` and
/// overrides the current value with `v`.
class FilterValue<T> {
  const FilterValue(this.value) : isSet = true;

  const FilterValue.unset() : value = null, isSet = false;

  final T? value;

  final bool isSet;

  /// Resolves to `value` if this wrapper was explicitly set (including to
  /// null); otherwise returns `current` — the keep-existing path.
  T? resolve(T? current) => isSet ? value : current;
}
```

## Test cases — existing tests verbatim

Existing tests from
`d:/src/contacts/test/lib/utils/primitive/filter_value_test.dart`
(import path will change to the library package on adoption):

```dart
// Tests for FilterValue<T> — pins the three intents the wrapper distinguishes
// (unset / set-to-value / set-to-null) so a future refactor cannot collapse
// the explicit-clear-to-null path back into the implicit "no override" path.

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa/utils/primitive/filter_value.dart';

void main() {
  group('FilterValue<T>', () {
    group('unset', () {
      test('isSet is false and value is null', () {
        const FilterValue<bool> unset = FilterValue<bool>.unset();

        expect(unset.isSet, isFalse);
        expect(unset.value, isNull);
      });

      test('resolve returns the supplied current value (keep-existing path)', () {
        const FilterValue<bool> unset = FilterValue<bool>.unset();

        expect(unset.resolve(true), isTrue);
        expect(unset.resolve(false), isFalse);
        expect(unset.resolve(null), isNull);
      });
    });

    group('set to a non-null value', () {
      test('isSet is true and value is the supplied value', () {
        const FilterValue<bool> setTrue = FilterValue<bool>(true);

        expect(setTrue.isSet, isTrue);
        expect(setTrue.value, isTrue);
      });

      test('resolve overrides the current value', () {
        const FilterValue<bool> setTrue = FilterValue<bool>(true);

        // Override applies even when the current value differs.
        expect(setTrue.resolve(false), isTrue);
        expect(setTrue.resolve(null), isTrue);
      });
    });

    group('set explicitly to null', () {
      // This is the case the prior `*ForceNull` companion-parameter pattern
      // existed to express. The wrapper must keep it distinguishable from the
      // unset case — otherwise filter reset is impossible through copyWith.
      test('isSet is true and value is null', () {
        const FilterValue<bool> clearedToNull = FilterValue<bool>(null);

        expect(clearedToNull.isSet, isTrue);
        expect(clearedToNull.value, isNull);
      });

      test('resolve returns null regardless of the current value', () {
        const FilterValue<bool> clearedToNull = FilterValue<bool>(null);

        expect(clearedToNull.resolve(true), isNull);
        expect(clearedToNull.resolve(false), isNull);
        expect(clearedToNull.resolve(null), isNull);
      });
    });

    test('works for non-bool generic types', () {
      const FilterValue<String> unset = FilterValue<String>.unset();
      const FilterValue<String> setValue = FilterValue<String>('hello');
      const FilterValue<String> setNull = FilterValue<String>(null);

      expect(unset.resolve('current'), equals('current'));
      expect(setValue.resolve('current'), equals('hello'));
      expect(setNull.resolve('current'), isNull);
    });
  });
}
```

Note: on adoption into a pure-Dart package, swap `package:flutter_test` /
`package:saropa/...` for `package:test/test.dart` and the library import — none
of the assertions depend on Flutter.

## Library overlap

No overlapping symbol exists in `saropa_dart_utils-1.4.1`. A scan of `lib/` for
`FilterValue` / `Optional` / `Sentinel` / `Patch` / `FieldUpdate` / `CopyWith`
class declarations returned no matches; the existing `copy_with`-adjacent and
`map`/`json` patch utilities (`map_diff_utils`, `json_diff_patch_utils`) operate
on maps, not a typed `copyWith` parameter wrapper. This is **net-new**.

## Bulletproofing gaps — concrete edge cases to add for massive coverage

The existing tests cover the three core intents for `bool` and `String`. For the
library's bulletproof bar, add:

### Type coverage (generic `T`)
- `FilterValue<int>` with zero: `FilterValue<int>(0)` — `isSet` true, `value` 0,
  `resolve(5)` returns 0 (guards against any `0`/falsy collapse).
- `FilterValue<int>` with negative: `FilterValue<int>(-1)`.
- `FilterValue<double>` with `0.0`, `-0.0`, `double.infinity`,
  `double.negativeInfinity`, `double.nan` — `resolve` must return the exact value
  including NaN (assert with `isNaN`, since `NaN != NaN`).
- `FilterValue<num>`, `FilterValue<Object>` (top type) — generic erasure sanity.
- `FilterValue<List<int>>` / `FilterValue<Map<String, int>>` — wrapper holds the
  reference identically; assert `identical(resolve(other), supplied)`.
- Empty collection: `FilterValue<List<int>>(<int>[])` is set (not unset) and
  resolves to the empty list, distinct from `unset()`.

### String / Unicode (general value-class robustness)
- Empty string `FilterValue<String>('')` is set, resolves to `''`, distinct from
  `unset()` resolving to a current value.
- Unicode / smart quotes: `FilterValue<String>('café')`,
  `FilterValue<String>('‘q’')` (U+2018/U+2019 curly quotes),
  `FilterValue<String>('a…b')` (ellipsis) — value preserved byte-for-byte.
- Emoji incl. surrogate pairs / ZWJ sequence:
  `FilterValue<String>('\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}')` (family
  emoji) — `resolve` returns the exact string, length unchanged.
- Non-breaking space only: `FilterValue<String>(' ')` is set, not treated as
  empty/unset.

### Resolve semantics
- `resolve` round-trips: `unset().resolve(x) == x` for x in {null, value,
  another `FilterValue`}.
- Set-to-null vs unset divergence at every current value
  (`true`/`false`/`null`/value) — already partly covered; extend across types.
- `resolve` is pure: calling twice returns the same result and does not mutate.

### Equality / const / immutability
- Const identity: two `const FilterValue<bool>(true)` are canonicalized to the
  same instance (`identical`), confirming const-constructor correctness.
- Document that `FilterValue` defines no `operator ==`/`hashCode` override — if
  value equality is desired in the library, add it and test
  `FilterValue(1) == FilterValue(1)`, `unset() == unset()`,
  `FilterValue(null) != unset()` (the load-bearing distinction).
- Fields are `final`; the class is immutable — no setter path to test, but assert
  the wrapper does not deep-copy held references (holds by reference).

### Boundary / extreme
- `FilterValue<int>` with `0x7FFFFFFFFFFFFFFF` and `-0x8000000000000000` (int
  min/max) — value preserved exactly.
- Deeply nested generic `FilterValue<FilterValue<int>>` — wrapper composes.
