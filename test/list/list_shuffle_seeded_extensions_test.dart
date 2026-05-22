// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_shuffle_seeded_extensions.dart';

void main() {
  group('ListShuffleSeededExtensions.shuffleWithSeed', () {
    test('same seed produces the same order', () {
      final List<int> source = <int>[1, 2, 3, 4, 5, 6, 7, 8];
      expect(source.shuffleWithSeed(42), source.shuffleWithSeed(42));
    });

    test('different seeds usually differ for a larger list', () {
      final List<int> source = List<int>.generate(20, (int i) => i);
      expect(source.shuffleWithSeed(1), isNot(source.shuffleWithSeed(999)));
    });

    test('preserves all original elements (same multiset)', () {
      final List<int> source = <int>[1, 2, 3, 4, 5];
      final List<int> shuffled = source.shuffleWithSeed(7);
      expect(shuffled..sort(), <int>[1, 2, 3, 4, 5]);
    });

    test('does not mutate the original list', () {
      final List<int> source = <int>[1, 2, 3, 4, 5];
      final List<int> shuffled = source.shuffleWithSeed(7);
      expect(source, <int>[1, 2, 3, 4, 5]);
      expect(shuffled, hasLength(5));
    });

    test('empty list shuffles to empty', () {
      expect(<int>[].shuffleWithSeed(1), <int>[]);
    });

    test('single element list is unchanged', () {
      expect(<int>[42].shuffleWithSeed(1), <int>[42]);
    });
  });
}
