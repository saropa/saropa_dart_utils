import 'package:flutter/material.dart';

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
class Swipe {
  /// Creates a new [Swipe] record.
  ///
  /// The [direction] parameter specifies the direction of the swipe.
  /// The [speed] parameter specifies the speed of the swipe.
  /// The [magnitude] parameter specifies the magnitude of the swipe.
  /// The [angle] parameter specifies the angle of the swipe.
  ///
  /// Example:
  /// ```dart
  /// var swipe = Swipe(SwipeDirection.left, SwipeSpeed.fast,
  ///   SwipeMagnitude.large, SwipeAngle.horizontal);
  /// ```
  const Swipe(
    this.direction,
    this.speed,
    this.magnitude,
    this.angle,
  );

  /// The direction of the swipe.
  ///
  /// This can be one of the values defined in the [SwipeDirection] enum:
  /// [SwipeDirection.left], [SwipeDirection.right], [SwipeDirection.up],
  /// or [SwipeDirection.down].
  final SwipeDirection direction;

  /// The speed of the swipe.
  ///
  /// This can be one of the values defined in the [SwipeSpeed] enum:
  /// [SwipeSpeed.minimal], [SwipeSpeed.slow], [SwipeSpeed.normal],
  /// or [SwipeSpeed.fast].
  final SwipeSpeed speed;

  /// The magnitude of the swipe.
  ///
  /// This can be one of the values defined in the [SwipeMagnitude] enum:
  /// [SwipeMagnitude.minimal], [SwipeMagnitude.small], [SwipeMagnitude.medium],
  /// [SwipeMagnitude.large], or [SwipeMagnitude.massive].
  final SwipeMagnitude magnitude;

  /// The angle of the swipe.
  ///
  /// This can be one of the values defined in the [SwipeAngle] enum:
  /// [SwipeAngle.horizontal], [SwipeAngle.diagonal], or [SwipeAngle.vertical].
  final SwipeAngle angle;
}

/// The DragEndDetailsProperties extension adds additional properties to
/// [DragEndDetails] instances, allowing you to easily determine the direction
/// and speed of a swipe gesture.
extension SwipeProperties on DragEndDetails {
  /// Method to get the swipe direction.
  ///
  /// This method returns the direction of the swipe based on the velocity.
  SwipeDirection get swipeDirection {
    // Ref: https://stackoverflow.com/questions/61901468/how-to-detect-left-and-right-swipes-in-flutter
    if (velocity.pixelsPerSecond.dx.abs() >=
        velocity.pixelsPerSecond.dy.abs()) {
      // Horizontal swipe
      return velocity.pixelsPerSecond.dx > 0
          ? SwipeDirection.right
          : SwipeDirection.left;
    }

    // Vertical swipe
    return velocity.pixelsPerSecond.dy > 0
        ? SwipeDirection.down
        : SwipeDirection.up;
  }

  /// Method to get the swipe speed.
  ///
  /// This method returns the speed of the swipe based on the velocity and
  /// the thresholds defined in swipeThresholds.
  SwipeSpeed get swipeSpeed {
    final speed = velocity.pixelsPerSecond.distance;
    return GestureUtils._getSwipeSpeed(speed);
  }

  /// Method to get the swipe magnitude.
  ///
  /// This method returns the magnitude of the swipe based on the velocity.
  SwipeMagnitude get swipeMagnitude {
    final magnitude = velocity.pixelsPerSecond.distance;
    // Add logic here to convert the magnitude to a SwipeMagnitude enum.
    if (magnitude <
        (GestureUtils._swipeMagnitudeThresholds[SwipeMagnitude.minimal] ?? 0)) {
      return SwipeMagnitude.minimal;
    } else if (magnitude <
        (GestureUtils._swipeMagnitudeThresholds[SwipeMagnitude.small] ?? 0)) {
      return SwipeMagnitude.small;
    } else if (magnitude <
        (GestureUtils._swipeMagnitudeThresholds[SwipeMagnitude.medium] ?? 0)) {
      return SwipeMagnitude.medium;
    } else if (magnitude <
        (GestureUtils._swipeMagnitudeThresholds[SwipeMagnitude.large] ?? 0)) {
      return SwipeMagnitude.large;
    } else {
      return SwipeMagnitude.massive;
    }
  }

  /// Method to get the swipe angle.
  ///
  /// This method returns the angle of the swipe based on the velocity.
  SwipeAngle get swipeAngle {
    final dx = velocity.pixelsPerSecond.dx;
    final dy = velocity.pixelsPerSecond.dy;
    // Add logic here to convert the angle to a SwipeAngle enum.
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      return SwipeAngle.horizontal;
    } else if (dy.abs() > dx.abs()) {
      // Vertical swipe
      return SwipeAngle.vertical;
    } else {
      // Diagonal swipe
      return SwipeAngle.diagonal;
    }
  }

  /// Method to get a Swipe record for the swipe gesture.
  ///
  /// This method returns a [Swipe] record that contains the direction
  /// and speed of the swipe.
  Swipe get swipe {
    return Swipe(
      swipeDirection,
      swipeSpeed,
      swipeMagnitude,
      swipeAngle,
    );
  }
}

/// This is a utility class that contains static methods related to gesture
/// processing.
class GestureUtils {
  /// Method to get the swipe speed based on the thresholds defined in
  /// [_swipeSpeedThresholds].
  ///
  /// This method is private and can only be accessed within this class.
  static SwipeSpeed _getSwipeSpeed(double speed) {
    if (speed < (_swipeSpeedThresholds[SwipeSpeed.minimal] ?? 0)) {
      return SwipeSpeed.minimal;
    } else if (speed < (_swipeSpeedThresholds[SwipeSpeed.slow] ?? 0)) {
      return SwipeSpeed.slow;
    } else if (speed < (_swipeSpeedThresholds[SwipeSpeed.normal] ?? 0)) {
      return SwipeSpeed.normal;
    } else {
      return SwipeSpeed.fast;
    }
  }

  /// Map for swipe magnitude thresholds.
  ///
  /// This map associates each [SwipeMagnitude] with its corresponding
  /// threshold. The thresholds are measured in logical pixels per second.
  /// These thresholds are used in the [SwipeProperties.swipeMagnitude] method
  /// to determine the magnitude of a swipe.
  static const Map<SwipeMagnitude, double> _swipeMagnitudeThresholds = {
    SwipeMagnitude.minimal: 200.0,

    /// Threshold for very small swipes.
    SwipeMagnitude.small: 500.0,

    /// Threshold for small swipes.
    SwipeMagnitude.medium: 1000.0,

    /// Threshold for medium swipes.
    SwipeMagnitude.large: 1500.0,

    /// Threshold for large swipes.
    SwipeMagnitude.massive: 2000.0,

    /// Threshold for very large swipes.
  };

  /// Map for swipe speed thresholds.
  ///
  /// This map associates each [SwipeSpeed] with its corresponding threshold.
  /// The thresholds are measured in logical pixels per second.
  /// These thresholds are used in the [SwipeProperties.swipeSpeed]
  /// method to determine the speed of a swipe.
  static const Map<SwipeSpeed, double> _swipeSpeedThresholds = {
    /// Threshold for very slow swipes.
    SwipeSpeed.minimal: 1,

    /// Threshold for slow swipes.
    SwipeSpeed.slow: 500,

    /// Threshold for regular speed swipes.
    SwipeSpeed.normal: 1000,

    /// Threshold for fast swipes.
    SwipeSpeed.fast: 2000,
  };
}
