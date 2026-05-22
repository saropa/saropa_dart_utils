import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_cartesian_extensions.dart';

void main() {
  group('cartesian', () {
    test('produces all ordered pairs', () {
      expect(<int>[1, 2].cartesian(<String>['a', 'b']).toList(), <(int, String)>[
        (1, 'a'),
        (1, 'b'),
        (2, 'a'),
        (2, 'b'),
      ]);
    });

    test('empty left iterable yields no pairs', () {
      expect(<int>[].cartesian(<String>['a']).toList(), <(int, String)>[]);
    });

    test('empty right iterable yields no pairs', () {
      expect(<int>[1, 2].cartesian(<String>[]).toList(), <(int, String)>[]);
    });

    test('single element on each side yields one pair', () {
      expect(<int>[7].cartesian(<int>[9]).toList(), <(int, int)>[(7, 9)]);
    });

    test('size is product of lengths', () {
      expect(<int>[1, 2, 3].cartesian(<int>[1, 2]).toList(), hasLength(6));
    });

    test('preserves duplicates from both sides', () {
      expect(<int>[1, 1].cartesian(<int>[2]).toList(), <(int, int)>[(1, 2), (1, 2)]);
    });
  });
}
