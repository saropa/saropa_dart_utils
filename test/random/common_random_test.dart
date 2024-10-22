import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/random/common_random.dart';

void main() {
  group('CommonRandom', () {
    test('unique instances with default seed', () async {
      final Random random1 = CommonRandom();

      // Add a small delay
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final Random random2 = CommonRandom();

      // Ensure two instances are producing different values
      expect(random1.nextInt(100) != random2.nextInt(100), isTrue);
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
