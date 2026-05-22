import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/hash_utils.dart';

void main() {
  group('simpleHash', () {
    test('null hashes to 0', () {
      expect(simpleHash(null), 0);
    });

    test('scalar returns the value hashCode', () {
      expect(simpleHash('x'), 'x'.hashCode);
      expect(simpleHash(5), 5.hashCode);
      expect(simpleHash(true), true.hashCode);
    });

    test('equal lists hash equally', () {
      expect(simpleHash(<int>[1, 2, 3]), simpleHash(<int>[1, 2, 3]));
    });

    test('list order changes the hash', () {
      expect(simpleHash(<int>[1, 2, 3]), isNot(simpleHash(<int>[3, 2, 1])));
    });

    test('empty list hashes to its seed (1)', () {
      // Folds over nothing, leaving the initial accumulator of 1.
      expect(simpleHash(<Object?>[]), 1);
    });

    test('equal maps hash equally', () {
      expect(
        simpleHash(<String, int>{'a': 1, 'b': 2}),
        simpleHash(<String, int>{'a': 1, 'b': 2}),
      );
    });

    test('empty map hashes to its seed (1)', () {
      expect(simpleHash(<Object?, Object?>{}), 1);
    });

    test('nested lists are recursed', () {
      expect(
        simpleHash(<Object?>[
          <int>[1, 2],
          3,
        ]),
        simpleHash(<Object?>[
          <int>[1, 2],
          3,
        ]),
      );
    });
  });
}
