import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/pad_format_utils.dart';

void main() {
  group('padWithZeros', () {
    test('left-pads to the requested width', () {
      expect(padWithZeros(5, 3), '005');
      expect(padWithZeros(7, 3), '007');
    });

    test('value already at width is unchanged', () {
      expect(padWithZeros(123, 3), '123');
    });

    test('value longer than width is returned as-is', () {
      expect(padWithZeros(12345, 3), '12345');
    });

    test('zero pads', () {
      expect(padWithZeros(0, 2), '00');
    });

    test('negative value: padLeft prepends zeros before the sign', () {
      // padLeft does not special-case the '-', so '-5' (len 2) -> '00-5'.
      expect(padWithZeros(-5, 4), '00-5');
    });
  });

  group('formatFileSize', () {
    test('exact KB', () {
      expect(formatFileSize(1024), '1 KB');
    });

    test('fractional KB keeps one decimal', () {
      expect(formatFileSize(1536), '1.5 KB');
    });

    test('bytes below 1024 stay in B', () {
      expect(formatFileSize(500), '500 B');
    });

    test('zero is 0 B', () {
      expect(formatFileSize(0), '0 B');
    });

    test('MB scale', () {
      expect(formatFileSize(1048576), '1 MB');
    });

    test('negative input gets a leading minus', () {
      expect(formatFileSize(-1024), '-1 KB');
    });

    test('values >= 10 drop the fraction', () {
      // 12288 / 1024 = 12 -> '12 KB'.
      expect(formatFileSize(12288), '12 KB');
    });

    test('custom decimals', () {
      // 1024 + 256 = 1280 -> 1.25 KB at 2 decimals.
      expect(formatFileSize(1280, decimals: 2), '1.25 KB');
    });

    test('decimals: 0 that rounds up keeps integer-part zeros (regression)', () {
      // 9728 / 1024 = 9.5 -> toStringAsFixed(0) "10"; the old trailing-zero strip
      // turned it into "1 KB".
      expect(formatFileSize(9728, decimals: 0), '10 KB');
    });
  });
}
