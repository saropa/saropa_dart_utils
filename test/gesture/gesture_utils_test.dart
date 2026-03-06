import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/gesture/gesture_utils.dart';
import 'package:saropa_dart_utils/gesture/swipe_properties.dart';

void main() {
  group('GestureUtils.getSwipeSpeed', () {
    test('1. Zero returns minimal', () => expect(GestureUtils.getSwipeSpeed(0), SwipeSpeed.minimal));
    test('2. Negative returns minimal', () => expect(GestureUtils.getSwipeSpeed(-100), SwipeSpeed.minimal));
    test('3. Just below minimal threshold (0.5)', () => expect(GestureUtils.getSwipeSpeed(0.5), SwipeSpeed.minimal));
    test('4. At minimal/slow boundary (1)', () => expect(GestureUtils.getSwipeSpeed(1), SwipeSpeed.slow));
    test('5. Mid slow range', () => expect(GestureUtils.getSwipeSpeed(250), SwipeSpeed.slow));
    test('6. Just below slow/normal boundary (499)', () => expect(GestureUtils.getSwipeSpeed(499), SwipeSpeed.slow));
    test('7. At slow/normal boundary (500)', () => expect(GestureUtils.getSwipeSpeed(500), SwipeSpeed.normal));
    test('8. Mid normal range', () => expect(GestureUtils.getSwipeSpeed(750), SwipeSpeed.normal));
    test('9. Just below normal/fast boundary (999)', () => expect(GestureUtils.getSwipeSpeed(999), SwipeSpeed.normal));
    test('10. At normal/fast boundary (1000)', () => expect(GestureUtils.getSwipeSpeed(1000), SwipeSpeed.fast));
    test('11. Above fast threshold', () => expect(GestureUtils.getSwipeSpeed(2000), SwipeSpeed.fast));
    test('12. Large value', () => expect(GestureUtils.getSwipeSpeed(10000), SwipeSpeed.fast));
    test('13. Double.NaN falls through to fast (comparisons are false)', () {
      expect(GestureUtils.getSwipeSpeed(double.nan), SwipeSpeed.fast);
    });
    test('14. Infinity returns fast', () => expect(GestureUtils.getSwipeSpeed(double.infinity), SwipeSpeed.fast));
    test('15. Negative infinity returns minimal', () {
      expect(GestureUtils.getSwipeSpeed(double.negativeInfinity), SwipeSpeed.minimal);
    });
  });

  group('GestureUtils.swipeMagnitudeThresholds', () {
    test('1. Constant has all magnitudes', () {
      final Map<SwipeMagnitude, double> t = GestureUtils.swipeMagnitudeThresholds;
      expect(t, hasLength(5));
      expect(t[SwipeMagnitude.minimal], 200.0);
      expect(t[SwipeMagnitude.small], 500.0);
      expect(t[SwipeMagnitude.medium], 1000.0);
      expect(t[SwipeMagnitude.large], 1500.0);
      expect(t[SwipeMagnitude.massive], 2000.0);
    });
  });
}
