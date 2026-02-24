import 'package:saropa_dart_utils/gesture/swipe_properties.dart';

/// This is a utility class that contains static methods related to gesture
/// processing.
abstract final class GestureUtils {
  /// Method to get the swipe speed based on the thresholds defined in
  /// [_swipeSpeedThresholds].
  ///
  /// This method is private and can only be accessed within this class.
  static SwipeSpeed getSwipeSpeed(double speed) {
    if (speed < (_swipeSpeedThresholds[SwipeSpeed.minimal] ?? 0)) {
      return SwipeSpeed.minimal;
    }

    if (speed < (_swipeSpeedThresholds[SwipeSpeed.slow] ?? 0)) {
      return SwipeSpeed.slow;
    }

    if (speed < (_swipeSpeedThresholds[SwipeSpeed.normal] ?? 0)) {
      return SwipeSpeed.normal;
    }

    return SwipeSpeed.fast;
  }

  /// Map for swipe magnitude thresholds.
  ///
  /// This map associates each [SwipeMagnitude] with its corresponding
  /// threshold. The thresholds are measured in logical pixels per second.
  /// These thresholds are used in the [SwipeProperties.swipeMagnitude] method
  /// to determine the magnitude of a swipe.
  static const Map<SwipeMagnitude, double> swipeMagnitudeThresholds = <SwipeMagnitude, double>{
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
  static const Map<SwipeSpeed, double> _swipeSpeedThresholds = <SwipeSpeed, double>{
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
