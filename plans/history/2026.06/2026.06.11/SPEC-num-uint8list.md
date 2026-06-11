# SPEC: Uint8ListExtension.toIntList / IntListExtension.toUint8List — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/typed_data/uint8list_extensions.dart
**Portability:** Pure Dart (`dart:typed_data` only). No Flutter, no external packages.

## Purpose — what it does + why it is general-purpose (not proprietary)

Two reciprocal extensions that bridge between `Uint8List` (fixed-width byte
buffer) and `List<int>` (general integer list):

- `Uint8List.toIntList()` returns a `List<int>` containing the same elements.
- `List<int>.toUint8List()` returns a `Uint8List` built from the elements.

This is generic byte/integer plumbing — used anywhere code receives a
`Uint8List` from a binary API (file bytes, crypto output, network frames, image
decoders) and needs a growable/mutable `List<int>`, or vice-versa. It carries no
contact-domain, Saropa-specific, or app-specific behavior, so it is a clean
fit for a general-purpose utility library.

There is no overlap with the installed `saropa_dart_utils-1.4.1`: a search of
its `lib/` found `Uint8List` used only internally inside `base64_utils.dart`,
`jwt_structure_utils.dart`, and `uuid_v4_utils.dart` — there is no `toIntList`
or `toUint8List` conversion extension. This util is **net-new**.

### Excluded members + why

None. The source file contains only the two general-purpose extensions; there is
no proprietary, app-specific, l10n, icon, debug/Crashlytics, or search-query
code to strip.

## Source (from Saropa Contacts) — verbatim (debug logging stripped; none present)

```dart
import 'dart:typed_data';

/// Extension on [Uint8List] to convert it to a [List<int>].
extension Uint8ListExtension on Uint8List {
  /// Converts the [Uint8List] to a `List<int>`.
  ///
  /// Iterates over each element in the [Uint8List] and copies it into a new
  /// growable `List<int>`. Returns a `List<int>` containing the same elements
  /// as the original [Uint8List].
  List<int> toIntList() => map((int e) => e).toList();
}

/// Extension on `List<int>` to convert it to a [Uint8List].
extension IntListExtension on List<int> {
  /// Converts the `List<int>` to a [Uint8List].
  ///
  /// Creates a new [Uint8List] from the elements of this list. Returns a
  /// [Uint8List] containing the same elements as the original `List<int>`.
  ///
  /// Note: each element is stored modulo 256 (low 8 bits), matching the
  /// semantics of [Uint8List.fromList].
  Uint8List toUint8List() => Uint8List.fromList(this);
}
```

## Test cases — none exist in Saropa Contacts; proposed cases below

No `*_test.dart` under `d:/src/contacts/test` references `toIntList`,
`toUint8List`, `Uint8ListExtension`, or `IntListExtension`. Proposed initial
tests:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/typed_data/uint8list_extensions.dart';

void main() {
  group('Uint8ListExtension.toIntList', () {
    test('converts a populated Uint8List to an equal List<int>', () {
      final Uint8List bytes = Uint8List.fromList(<int>[0, 1, 127, 128, 255]);

      final List<int> result = bytes.toIntList();

      expect(result, equals(<int>[0, 1, 127, 128, 255]));
    });

    test('returns an empty list for an empty Uint8List', () {
      expect(Uint8List(0).toIntList(), isEmpty);
    });

    test('returns a growable list (round-trip is mutable)', () {
      final List<int> result = Uint8List.fromList(<int>[1, 2]).toIntList();

      // Uint8List is fixed-length; the converted list must be growable.
      result.add(3);

      expect(result, equals(<int>[1, 2, 3]));
    });

    test('result is independent of the source buffer', () {
      final Uint8List bytes = Uint8List.fromList(<int>[10, 20]);
      final List<int> result = bytes.toIntList();

      bytes[0] = 99;

      expect(result, equals(<int>[10, 20]));
    });
  });

  group('IntListExtension.toUint8List', () {
    test('converts a List<int> to an equal Uint8List', () {
      final Uint8List result = <int>[0, 1, 127, 128, 255].toUint8List();

      expect(result, isA<Uint8List>());
      expect(result, equals(Uint8List.fromList(<int>[0, 1, 127, 128, 255])));
    });

    test('returns an empty Uint8List for an empty list', () {
      expect(<int>[].toUint8List(), isEmpty);
    });

    test('values outside 0..255 wrap modulo 256', () {
      // 256 -> 0, 257 -> 1, -1 -> 255, matching Uint8List.fromList semantics.
      final Uint8List result = <int>[256, 257, -1].toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[0, 1, 255])));
    });
  });

  group('round-trip', () {
    test('Uint8List -> List<int> -> Uint8List preserves bytes', () {
      final Uint8List original =
          Uint8List.fromList(<int>[0, 42, 128, 200, 255]);

      final Uint8List roundTripped = original.toIntList().toUint8List();

      expect(roundTripped, equals(original));
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Empty:** empty `Uint8List(0)` and empty `<int>[]` both round-trip to empty
  (covered above; keep).
- **Zero / boundary bytes:** elements `0`, `1`, `127`, `128`, `255` — the full
  unsigned-byte boundary set (covered; keep explicit).
- **Out-of-range / negative inputs to `toUint8List`:** values `256`, `257`,
  `-1`, `-256`, `512`, and a large value like `0x1FF` — assert each truncates to
  its low 8 bits (`value & 0xFF`). This is the single most surprising behavior
  and must be locked by tests so a future "validate input" change is a conscious
  decision, not a silent break.
- **Extremes:** `toUint8List` with `[0x7FFFFFFFFFFFFFFF]` (max int) and
  `[-0x8000000000000000]` (min int) — confirm they reduce to their low byte and
  do not throw.
- **Large buffers:** a 1,000,000-element `Uint8List` → `toIntList` → length and
  spot-checked values, to guard against accidental quadratic behavior if the
  `map(...).toList()` body is ever changed.
- **Identity / aliasing:** `toIntList` must return a NEW list (mutating the
  source `Uint8List` after conversion does not affect the result, and vice
  versa); `toUint8List` likewise produces an independent buffer
  (`Uint8List.fromList` copies). Add an explicit "mutate source after convert"
  assertion in both directions.
- **Growability contract:** assert `toIntList()` returns a growable list
  (`.add` succeeds) and `toUint8List()` returns a fixed-length view
  (`expect(() => result.add(0), throwsUnsupportedError)`), so the structural
  guarantee is part of the spec.
- **TypedData-list input to `toUint8List`:** call `toUint8List` on an
  already-`Uint8List` (which IS a `List<int>`) and on an `Int8List`/`Int16List`
  cast to `List<int>` — confirm the modulo-256 narrowing still holds for typed
  inputs, not just plain `List<int>` literals.
- **N/A for this util:** unicode/emoji, infinity/NaN (no doubles), leap years,
  DST, and locale do not apply — these are integer-byte conversions with no
  string, floating-point, date, or locale surface.
