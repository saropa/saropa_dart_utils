import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_none_extensions.dart';

void main() {
  group('none', () {
    test('returns true when no element matches', () {
      expect(<int>[1, 3, 5].none((int n) => n.isEven), isTrue);
    });

    test('returns false when an element matches', () {
      expect(<int>[1, 2, 3].none((int n) => n.isEven), isFalse);
    });

    test('returns true for an empty iterable (vacuous truth)', () {
      expect(<int>[].none((int n) => n.isEven), isTrue);
    });

    test('returns false when every element matches', () {
      expect(<int>[2, 4, 6].none((int n) => n.isEven), isFalse);
    });

    test('is the complement of any', () {
      final List<int> data = <int>[1, 2, 3];
      bool predicate(int n) => n > 2;
      expect(data.none(predicate), !data.any(predicate));
    });

    test('works on a lazy iterable', () {
      expect(Iterable<int>.generate(5, (int i) => i).none((int n) => n > 10), isTrue);
    });
  });
}
