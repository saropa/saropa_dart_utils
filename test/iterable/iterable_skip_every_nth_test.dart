import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

void main() {
  group('skipEveryNth', () {
    test('drops every n-th element (0-based indices 0, n, 2n, ...)', () {
      // indices kept are those where i % 2 != 0 -> 1, 3.
      expect(<int>[1, 2, 3, 4, 5].skipEveryNth(2), <int>[2, 4]);
    });

    test('n of 3 drops indices 0, 3', () {
      expect(<int>[1, 2, 3, 4, 5, 6].skipEveryNth(3), <int>[2, 3, 5, 6]);
    });

    test('throws for non-positive n', () {
      expect(() => <int>[1, 2].skipEveryNth(0).toList(), throwsArgumentError);
    });

    test('empty iterable yields empty', () {
      expect(<int>[].skipEveryNth(2), isEmpty);
    });
  });
}
