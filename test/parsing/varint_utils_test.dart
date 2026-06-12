import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/varint_utils.dart';

void main() {
  group('encodeVarint', () {
    test('zero', () => expect(encodeVarint(0), <int>[0]));
    test('one', () => expect(encodeVarint(1), <int>[1]));
    test('127 single byte', () => expect(encodeVarint(127), <int>[127]));
    test('128 two bytes', () => expect(encodeVarint(128), <int>[0x80, 0x01]));
    test('150 two bytes', () => expect(encodeVarint(150), <int>[0x96, 0x01]));
    test('300 two bytes', () => expect(encodeVarint(300), <int>[0xAC, 0x02]));
  });

  group('decodeVarint', () {
    test('single byte value and next index', () {
      expect(decodeVarint(<int>[5], 0), (5, 1));
    });
    test('two-byte 150', () {
      expect(decodeVarint(<int>[0x96, 0x01], 0), (150, 2));
    });
    test('two-byte 300', () {
      expect(decodeVarint(<int>[0xAC, 0x02], 0), (300, 2));
    });
    test('decode honoring start offset', () {
      expect(decodeVarint(<int>[0xFF, 0x96, 0x01], 1), (150, 3));
    });
    test('zero byte decodes to zero', () {
      expect(decodeVarint(<int>[0], 0), (0, 1));
    });
  });

  group('encode/decode round trip', () {
    test('various values round trip', () {
      for (final int n in <int>[0, 1, 127, 128, 255, 300, 16384, 2097151]) {
        final List<int> encoded = encodeVarint(n);
        expect(decodeVarint(encoded, 0).$1, n, reason: 'round trip $n');
        expect(decodeVarint(encoded, 0).$2, encoded.length, reason: 'next index $n');
      }
    });

    test('large (>2^35) and negative values round trip', () {
      // The old 5-byte decode cap truncated >2^35; the old encode emitted a
      // single wrong byte for negatives. Both must round-trip now.
      for (final int n in <int>[1 << 40, 1 << 50, -1, -2, -1000000]) {
        final List<int> encoded = encodeVarint(n);
        expect(decodeVarint(encoded, 0).$1, n, reason: 'round trip $n');
        expect(decodeVarint(encoded, 0).$2, encoded.length, reason: 'next index $n');
      }
    });

    test('negative one encodes to the full 10-byte form', () {
      final List<int> encoded = encodeVarint(-1);
      expect(encoded.length, 10);
    });
  });
}
