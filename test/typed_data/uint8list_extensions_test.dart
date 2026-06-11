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

    // Boundary set: the full unsigned-byte edges round-trip without loss.
    test('preserves the full unsigned-byte boundary set', () {
      final Uint8List bytes = Uint8List.fromList(<int>[0, 1, 127, 128, 254, 255]);

      expect(bytes.toIntList(), equals(<int>[0, 1, 127, 128, 254, 255]));
    });

    // Aliasing in the reverse direction: mutating the result must not touch
    // the source buffer.
    test('mutating the result list does not affect the source buffer', () {
      final Uint8List bytes = Uint8List.fromList(<int>[5, 6]);
      final List<int> result = bytes.toIntList();

      result[0] = 200;

      expect(bytes, equals(Uint8List.fromList(<int>[5, 6])));
    });

    // Growability contract: the result must accept .add (a Uint8List would not).
    test('returned list is growable', () {
      final List<int> result = Uint8List.fromList(<int>[1]).toIntList();

      expect(() => result.add(0), returnsNormally);
    });

    // Large-buffer guard against accidental quadratic behavior if the body
    // ever changes away from map(...).toList().
    test('handles a 1,000,000-element buffer with correct length and spots', () {
      final Uint8List bytes = Uint8List(1000000);
      bytes[0] = 1;
      bytes[500000] = 42;
      bytes[999999] = 255;

      final List<int> result = bytes.toIntList();

      expect(result.length, equals(1000000));
      expect(result[0], equals(1));
      expect(result[500000], equals(42));
      expect(result[999999], equals(255));
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

    // The single most surprising behavior: every out-of-range / negative input
    // narrows to its low 8 bits. Locked so a future validation change is
    // conscious, not silent.
    test('truncates a broad out-of-range / negative set to low 8 bits', () {
      final Uint8List result = <int>[256, 257, -1, -256, 512, 0x1FF].toUint8List();

      // 256&0xFF=0, 257&0xFF=1, -1&0xFF=255, -256&0xFF=0, 512&0xFF=0, 0x1FF&0xFF=255.
      expect(result, equals(Uint8List.fromList(<int>[0, 1, 255, 0, 0, 255])));
    });

    // Integer extremes must reduce to their low byte and not throw.
    test('reduces max int to its low byte without throwing', () {
      const int maxInt = 0x7FFFFFFFFFFFFFFF;

      final Uint8List result = <int>[maxInt].toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[maxInt & 0xFF])));
      expect(result.single, equals(255));
    });

    test('reduces min int to its low byte without throwing', () {
      const int minInt = -0x8000000000000000;

      final Uint8List result = <int>[minInt].toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[minInt & 0xFF])));
      expect(result.single, equals(0));
    });

    // Aliasing: Uint8List.fromList copies, so the result is independent of the
    // source list in both directions.
    test('result is independent of the source list', () {
      final List<int> source = <int>[10, 20];
      final Uint8List result = source.toUint8List();

      source[0] = 99;

      expect(result, equals(Uint8List.fromList(<int>[10, 20])));
    });

    test('mutating the result does not affect the source list', () {
      final List<int> source = <int>[10, 20];
      final Uint8List result = source.toUint8List();

      result[0] = 200;

      expect(source, equals(<int>[10, 20]));
    });

    // Growability contract: a Uint8List is fixed-length; .add must throw.
    test('returned Uint8List is fixed-length', () {
      final Uint8List result = <int>[1, 2].toUint8List();

      expect(() => result.add(0), throwsUnsupportedError);
    });

    // Typed-data inputs are also List<int>; the modulo-256 narrowing must still
    // hold for them, not just plain literals.
    test('narrows when the source is itself a Uint8List', () {
      final Uint8List typedSource = Uint8List.fromList(<int>[0, 128, 255]);

      final Uint8List result = typedSource.toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[0, 128, 255])));
    });

    test('narrows an Int8List source cast to List<int>', () {
      // -1 in an Int8List narrows to 255; 127 stays; -128 -> 128.
      final List<int> typedSource = Int8List.fromList(<int>[127, -1, -128]);

      final Uint8List result = typedSource.toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[127, 255, 128])));
    });

    test('narrows an Int16List source cast to List<int>', () {
      // 256 -> 0, 511 -> 255, -1 -> 255.
      final List<int> typedSource = Int16List.fromList(<int>[256, 511, -1]);

      final Uint8List result = typedSource.toUint8List();

      expect(result, equals(Uint8List.fromList(<int>[0, 255, 255])));
    });
  });

  group('round-trip', () {
    test('Uint8List -> List<int> -> Uint8List preserves bytes', () {
      final Uint8List original = Uint8List.fromList(<int>[0, 42, 128, 200, 255]);

      final Uint8List roundTripped = original.toIntList().toUint8List();

      expect(roundTripped, equals(original));
    });

    test('empty values round-trip to empty in both directions', () {
      expect(Uint8List(0).toIntList().toUint8List(), isEmpty);
      expect(<int>[].toUint8List().toIntList(), isEmpty);
    });
  });
}
