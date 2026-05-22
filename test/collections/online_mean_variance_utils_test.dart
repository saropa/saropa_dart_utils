import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/online_mean_variance_utils.dart';

void main() {
  group('OnlineMeanVarianceUtils', () {
    test('should report zero stats before any sample', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils();
      expect(stats.count, 0);
      expect(stats.mean, 0.0);
      expect(stats.variance, 0.0);
      expect(stats.standardDeviation, 0.0);
    });

    test('should track count', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()
        ..add(1)
        ..add(2)
        ..add(3);
      expect(stats.count, 3);
    });

    test('should compute the running mean', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()
        ..add(2)
        ..add(4)
        ..add(6);
      expect(stats.mean, 4.0);
    });

    test('should return the value itself as mean for one sample', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()..add(5);
      expect(stats.mean, 5.0);
      // Variance is 0 with fewer than two samples (Bessel correction undefined).
      expect(stats.variance, 0.0);
    });

    test('should compute Bessel-corrected sample variance', () {
      // Samples 1,2,3: mean 2, sample variance = ((1)+(0)+(1))/(3-1) = 1.
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()
        ..add(1)
        ..add(2)
        ..add(3);
      expect(stats.variance, closeTo(1.0, 1e-12));
    });

    test('should compute standard deviation as sqrt of variance', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()
        ..add(2)
        ..add(4)
        ..add(4)
        ..add(4)
        ..add(5)
        ..add(5)
        ..add(7)
        ..add(9);
      // Mean 5; sample variance = 32/7; sd = sqrt(32/7).
      expect(stats.mean, closeTo(5.0, 1e-12));
      expect(stats.variance, closeTo(32 / 7, 1e-9));
      expect(stats.standardDeviation, closeTo(2.13809, 1e-4));
    });

    test('should accept doubles', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()
        ..add(1.5)
        ..add(2.5);
      expect(stats.mean, 2.0);
    });

    test('should include count, mean, variance in toString', () {
      final OnlineMeanVarianceUtils stats = OnlineMeanVarianceUtils()..add(5);
      expect(stats.toString(), startsWith('OnlineMeanVarianceUtils(count: 1'));
    });
  });
}
