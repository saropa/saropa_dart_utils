import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/random/common_random.dart';

void main() {
  group('CommonRandom', () {
    test('unique instances with default seed', () async {
      final Random random1 = CommonRandom();

      // Delay past a millisecond boundary so the two time-based default seeds
      // differ (CommonRandom seeds from millisecondsSinceEpoch).
      await Future<void>.delayed(const Duration(milliseconds: 2));

      final Random random2 = CommonRandom();

      // Compare a SEQUENCE, not a single draw. Two differently-seeded RNGs still
      // collide on any single nextInt(100) ~1% of the time, which made the old
      // single-sample assertion flaky (~1% spurious CI failures). The chance that
      // ten consecutive draws all match is 100^-10 — effectively zero.
      final List<int> seq1 = List<int>.generate(10, (_) => random1.nextInt(100));
      final List<int> seq2 = List<int>.generate(10, (_) => random2.nextInt(100));
      expect(seq1, isNot(equals(seq2)));
    });

    test('consistent values with custom seed', () {
      final Random random1 = CommonRandom(123);
      final Random random2 = CommonRandom(123);

      // Ensure two instances with the same seed produce the same values
      expect(random1.nextInt(100), equals(random2.nextInt(100)));
    });

    test('different values with different seeds', () {
      final Random random1 = CommonRandom(123);
      final Random random2 = CommonRandom(456);

      // Ensure two instances with different seeds produce different values
      expect(random1.nextInt(100) != random2.nextInt(100), isTrue);
    });

    // test('handles zero seed correctly', () {
    //   final Random random = CommonRandom(0);

    //   // Ensure instance is created and produces values
    //   expect(random.nextInt(100), isTrue);
    // });
  });
}
