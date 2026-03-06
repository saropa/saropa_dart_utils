import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/gesture/gesture_utils.dart';

/// Enum for swipe speed.
///
/// These values represent different speeds of a swipe gesture.
/// They are used in conjunction with the [GestureUtils._swipeSpeedThresholds]
/// map to determine the speed of a swipe.
enum SwipeSpeed {
  /// For very slow swipes.
  minimal,

  /// For slow swipes.
  slow,

  /// For regular speed swipes.
  normal,

  /// For fast swipes.
  fast,
}

/// Enum for swipe direction.
///
/// These values represent the direction of a swipe gesture.
enum SwipeDirection {
  /// For swipes to the left.
  left,

  /// For swipes to the right.
  right,

  /// For swipes up.
  up,

  /// For swipes down.
  down,
}

/// Enum for swipe magnitude.
///
/// These values represent different magnitudes of a swipe gesture.
enum SwipeMagnitude {
  /// For very small swipes.
  minimal,

  /// For small swipes.
  small,

  /// For medium swipes.
  medium,

  /// For large swipes.
  large,

  /// For very large swipes.
  massive,
}

/// Enum for swipe angle.
///
/// These values represent different angles of a swipe gesture.
enum SwipeAngle {
  /// For horizontal swipes.
  horizontal,

  /// For diagonal swipes.
  diagonal,

  /// For vertical swipes.
  vertical,
}

/// Record for a swipe gesture.
///
/// This record contains the direction and speed of a swipe gesture.
/// It is used to encapsulate the details of a swipe gesture in a single object.
/// This makes it easier to pass around the details of a swipe gesture and use
/// them in different parts of your code.
class SwipeProperties {
  /// Creates a new [SwipeProperties] record.
  ///
  /// The [direction] parameter specifies the direction of the swipe.
  /// The [speed] parameter specifies the speed of the swipe.
  /// The [magnitude] parameter specifies the magnitude of the swipe.
  /// The [angle] parameter specifies the angle of the swipe.
  ///
  /// Example:
  /// ```dart
  /// var swipe = SwipeProperties(SwipeDirection.left, SwipeSpeed.fast,
  ///   SwipeMagnitude.large, SwipeAngle.horizontal);
  /// ```
  const SwipeProperties({
    required this.direction,
    required this.speed,
    required this.magnitude,
    required this.angle,
  });

  /// The direction of the swipe.
  final SwipeDirection direction;

  /// The speed of the swipe.
  final SwipeSpeed speed;

  /// The magnitude of the swipe.
  final SwipeMagnitude magnitude;

  /// The angle of the swipe.
  final SwipeAngle angle;

  /// Meaningful string for debugging and logging (avoids default "Instance of 'Swipe'").
  @override
  String toString() =>
      'SwipeProperties(direction: $direction, speed: $speed, magnitude: $magnitude, angle: $angle)';
}

/// The DragEndDetailsProperties extension adds additional properties to
/// [DragEndDetails] instances, allowing you to easily determine the direction
/// and speed of a swipe gesture.
extension SwipePropsExt on DragEndDetails {
  /// Method to get the swipe direction.
  ///
  /// This method returns the direction of the swipe based on the velocity.
  @useResult
  SwipeDirection get swipeDirection {
    // Ref: https://stackoverflow.com/questions/61901468/how-to-detect-left-and-right-swipes-in-flutter
    if (velocity.pixelsPerSecond.dx.abs() >= velocity.pixelsPerSecond.dy.abs()) {
      // Horizontal swipe
      return velocity.pixelsPerSecond.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }

    // Vertical swipe
    return velocity.pixelsPerSecond.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
  }

  /// Method to get the swipe speed.
  ///
  /// This method returns the speed of the swipe based on the velocity and
  /// the thresholds defined in swipeThresholds.
  @useResult
  SwipeSpeed get swipeSpeed {
    final double speed = velocity.pixelsPerSecond.distance;

    return GestureUtils.getSwipeSpeed(speed);
  }

  /// Method to get the swipe magnitude.
  ///
  /// This method returns the magnitude of the swipe based on the velocity.
  @useResult
  SwipeMagnitude get swipeMagnitude {
    final double magnitude = velocity.pixelsPerSecond.distance;
    // Add logic here to convert the magnitude to a SwipeMagnitude enum.
    if (magnitude < (GestureUtils.swipeMagnitudeThresholds[SwipeMagnitude.minimal] ?? 0)) {
      return SwipeMagnitude.minimal;
    }

    if (magnitude < (GestureUtils.swipeMagnitudeThresholds[SwipeMagnitude.small] ?? 0)) {
      return SwipeMagnitude.small;
    }

    if (magnitude < (GestureUtils.swipeMagnitudeThresholds[SwipeMagnitude.medium] ?? 0)) {
      return SwipeMagnitude.medium;
    }

    if (magnitude < (GestureUtils.swipeMagnitudeThresholds[SwipeMagnitude.large] ?? 0)) {
      return SwipeMagnitude.large;
    }

    return SwipeMagnitude.massive;
  }

  /// Method to get the swipe angle.
  ///
  /// This method returns the angle of the swipe based on the velocity.
  @useResult
  SwipeAngle get swipeAngle {
    final double velocityX = velocity.pixelsPerSecond.dx;
    final double velocityY = velocity.pixelsPerSecond.dy;

    if (velocityX.abs() > velocityY.abs()) {
      return SwipeAngle.horizontal;
    }

    if (velocityY.abs() > velocityX.abs()) {
      return SwipeAngle.vertical;
    }

    return SwipeAngle.diagonal;
  }

  /// Method to get a Swipe record for the swipe gesture.
  ///
  /// This method returns a [SwipeProperties] record that contains the direction
  /// and speed of the swipe.
  @useResult
  SwipeProperties get swipe => SwipeProperties(
    direction: swipeDirection,
    speed: swipeSpeed,
    magnitude: swipeMagnitude,
    angle: swipeAngle,
  );
}
