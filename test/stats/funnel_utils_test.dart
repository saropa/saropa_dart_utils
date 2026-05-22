import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/funnel_utils.dart';

void main() {
  group('FunnelUtils', () {
    test('exposes name and count', () {
      const FunnelUtils step = FunnelUtils('Signup', 1000);
      expect(step.name, 'Signup');
      expect(step.count, 1000);
    });

    test('toString includes name and count', () {
      const FunnelUtils step = FunnelUtils('Checkout', 50);
      expect(step.toString(), 'FunnelUtils(name: Checkout, count: 50)');
    });
  });

  group('funnelConversionRates', () {
    test('rate between consecutive steps', () {
      // 1000 -> 500 -> 250: each step retains half.
      final List<double> rates = funnelConversionRates(<FunnelUtils>[
        const FunnelUtils('a', 1000),
        const FunnelUtils('b', 500),
        const FunnelUtils('c', 250),
      ]);
      expect(rates, <double>[0.5, 0.5]);
    });

    test('growth between steps gives rate above 1', () {
      final List<double> rates = funnelConversionRates(<FunnelUtils>[
        const FunnelUtils('a', 100),
        const FunnelUtils('b', 150),
      ]);
      expect(rates, <double>[1.5]);
    });

    test('zero count step yields 0 rate (no division by zero)', () {
      final List<double> rates = funnelConversionRates(<FunnelUtils>[
        const FunnelUtils('a', 0),
        const FunnelUtils('b', 10),
      ]);
      expect(rates, <double>[0.0]);
    });

    test('single step returns empty', () {
      expect(funnelConversionRates(<FunnelUtils>[const FunnelUtils('a', 5)]), isEmpty);
    });

    test('empty input returns empty', () {
      expect(funnelConversionRates(<FunnelUtils>[]), isEmpty);
    });
  });
}
