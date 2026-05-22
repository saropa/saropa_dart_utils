import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/moving_average_utils.dart';

void main() {
  group('simpleMovingAverage', () {
    test('window of 3 over five values', () {
      // windows: (1+2+3)/3, (2+3+4)/3, (3+4+5)/3.
      expect(simpleMovingAverage(<num>[1, 2, 3, 4, 5], 3), <double>[2.0, 3.0, 4.0]);
    });

    test('window equal to length gives one value', () {
      expect(simpleMovingAverage(<num>[2, 4, 6], 3), <double>[4.0]);
    });

    test('window larger than length returns empty', () {
      expect(simpleMovingAverage(<num>[1, 2], 3), isEmpty);
    });

    test('window size below 1 returns empty', () {
      expect(simpleMovingAverage(<num>[1, 2, 3], 0), isEmpty);
    });

    test('window of 1 echoes the input', () {
      expect(simpleMovingAverage(<num>[5, 10, 15], 1), <double>[5.0, 10.0, 15.0]);
    });
  });

  group('exponentialMovingAverage', () {
    test('alpha 0.5 smoothing', () {
      // out0=1; out1=0.5*2+0.5*1=1.5; out2=0.5*3+0.5*1.5=2.25.
      final List<double> result = exponentialMovingAverage(<num>[1, 2, 3], 0.5);
      expect(result[0], closeTo(1.0, 1e-12));
      expect(result[1], closeTo(1.5, 1e-12));
      expect(result[2], closeTo(2.25, 1e-12));
    });

    test('alpha 1 tracks the input exactly', () {
      expect(exponentialMovingAverage(<num>[3, 7, 2], 1), <double>[3.0, 7.0, 2.0]);
    });

    test('alpha out of range echoes the input', () {
      // alpha <= 0 or > 1 short-circuits to the raw doubles.
      expect(exponentialMovingAverage(<num>[3, 7, 2], 0), <double>[3.0, 7.0, 2.0]);
      expect(exponentialMovingAverage(<num>[3, 7, 2], 1.5), <double>[3.0, 7.0, 2.0]);
    });

    test('empty returns empty', () {
      expect(exponentialMovingAverage(<num>[], 0.5), isEmpty);
    });

    test('single element returns that element', () {
      expect(exponentialMovingAverage(<num>[42], 0.3), <double>[42.0]);
    });
  });
}
