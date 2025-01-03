import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/gesture/swipe_properties.dart';

void main() {
  group('Swipe - Object', () {
    test('should create Swipe with correct direction and speed', () {
      const swipe = Swipe(
        SwipeDirection.left,
        SwipeSpeed.fast,
        SwipeMagnitude.large,
        SwipeAngle.horizontal,
      );

      expect(swipe.direction, SwipeDirection.left);
      expect(swipe.speed, SwipeSpeed.fast);
      expect(swipe.magnitude, SwipeMagnitude.large);
      expect(swipe.angle, SwipeAngle.horizontal);
    });
  });

  group('Swipe - Properties', () {
    test('should detect swipe right', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(2000, 0)),
      );

      expect(details.swipeDirection, SwipeDirection.right);
      expect(details.swipeSpeed, SwipeSpeed.fast);
      expect(details.swipeMagnitude, SwipeMagnitude.massive);
      expect(details.swipeAngle, SwipeAngle.horizontal);
    });

    test('should detect swipe left', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(-2000, 0)),
      );

      expect(details.swipeDirection, SwipeDirection.left);
      expect(details.swipeSpeed, SwipeSpeed.fast);
      expect(details.swipeMagnitude, SwipeMagnitude.massive);
      expect(details.swipeAngle, SwipeAngle.horizontal);
    });

    test('should detect swipe up', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, -2000)),
      );

      expect(details.swipeDirection, SwipeDirection.up);
      expect(details.swipeSpeed, SwipeSpeed.fast);
      expect(details.swipeMagnitude, SwipeMagnitude.massive);
      expect(details.swipeAngle, SwipeAngle.vertical);
    });

    test('should detect swipe down', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, 2000)),
      );

      expect(details.swipeDirection, SwipeDirection.down);
      expect(details.swipeSpeed, SwipeSpeed.fast);
      expect(details.swipeMagnitude, SwipeMagnitude.massive);
      expect(details.swipeAngle, SwipeAngle.vertical);
    });

    test('should detect diagonal swipe', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(2000, 2000)),
      );

      expect(
        details.swipeDirection,
        SwipeDirection.right,
      ); // The direction is determined by the larger component of the velocity.
      expect(details.swipeSpeed, SwipeSpeed.fast);
      expect(
        details.swipeMagnitude,
        SwipeMagnitude.massive,
      ); // The magnitude is the Euclidean distance of the velocity.
      expect(details.swipeAngle, SwipeAngle.diagonal);
    });
  });

  group('Swipe - Extra', () {
    test(
        'should create Swipe with correct direction, speed, magnitude, and '
        'angle', () {
      const swipe = Swipe(
        SwipeDirection.left,
        SwipeSpeed.fast,
        SwipeMagnitude.large,
        SwipeAngle.horizontal,
      );

      expect(swipe.direction, SwipeDirection.left);
      expect(swipe.speed, SwipeSpeed.fast);
      expect(swipe.magnitude, SwipeMagnitude.large);
      expect(swipe.angle, SwipeAngle.horizontal);
    });
  });

  group('Swipe', () {
    test(
        'should create Swipe with correct direction, speed, magnitude, '
        'and angle', () {
      const swipe = Swipe(
        SwipeDirection.left,
        SwipeSpeed.fast,
        SwipeMagnitude.large,
        SwipeAngle.horizontal,
      );

      expect(swipe.direction, equals(SwipeDirection.left));
      expect(swipe.speed, equals(SwipeSpeed.fast));
      expect(swipe.magnitude, equals(SwipeMagnitude.large));
      expect(swipe.angle, equals(SwipeAngle.horizontal));
    });
  });

  group('DragEndDetailsProperties', () {
    test('should detect swipe right', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(2000, 0)),
      );

      expect(details.swipeDirection, equals(SwipeDirection.right));
      expect(details.swipeSpeed, equals(SwipeSpeed.fast));
      expect(details.swipeMagnitude, equals(SwipeMagnitude.massive));
      expect(details.swipeAngle, equals(SwipeAngle.horizontal));
    });

    test('should detect swipe left', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(-2000, 0)),
      );

      expect(details.swipeDirection, equals(SwipeDirection.left));
      expect(details.swipeSpeed, equals(SwipeSpeed.fast));
      expect(details.swipeMagnitude, equals(SwipeMagnitude.massive));
      expect(details.swipeAngle, equals(SwipeAngle.horizontal));
    });

    test('should detect swipe up', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, -2000)),
      );

      expect(details.swipeDirection, equals(SwipeDirection.up));
      expect(details.swipeSpeed, equals(SwipeSpeed.fast));
      expect(details.swipeMagnitude, equals(SwipeMagnitude.massive));
      expect(details.swipeAngle, equals(SwipeAngle.vertical));
    });

    test('should detect swipe down', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(0, 2000)),
      );

      expect(details.swipeDirection, equals(SwipeDirection.down));
      expect(details.swipeSpeed, equals(SwipeSpeed.fast));
      expect(details.swipeMagnitude, equals(SwipeMagnitude.massive));
      expect(details.swipeAngle, equals(SwipeAngle.vertical));
    });

    test('should detect diagonal swipe', () {
      final details = DragEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(2000, 2000)),
      );

      expect(
        details.swipeDirection,
        equals(
          SwipeDirection.right,
        ),
      ); // The direction is determined by the larger component of the velocity.
      expect(details.swipeSpeed, equals(SwipeSpeed.fast));
      expect(
        details.swipeMagnitude,
        equals(
          SwipeMagnitude.massive,
        ),
      ); // The magnitude is the Euclidean distance of the velocity.
      expect(details.swipeAngle, equals(SwipeAngle.diagonal));
    });
  });
}
