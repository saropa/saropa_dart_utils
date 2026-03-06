import 'package:meta/meta.dart';

const String _kErrMultiplePositive = 'multiple must be positive';
const String _kParamMultiple = 'multiple';

/// Round/floor/ceil to multiple. Roadmap #133–134.
extension NumRoundMultipleExtensions on num {
  /// Rounds to nearest multiple of [multiple]. [multiple] must be positive.
  @useResult
  double roundToMultiple(num multiple) {
    if (multiple <= 0) throw ArgumentError(_kErrMultiplePositive, _kParamMultiple);
    return (this / multiple).round() * multiple.toDouble();
  }

  /// Floors to multiple of [multiple].
  @useResult
  double floorToMultiple(num multiple) {
    if (multiple <= 0) throw ArgumentError(_kErrMultiplePositive, _kParamMultiple);
    return (this / multiple).floor() * multiple.toDouble();
  }

  /// Ceils to multiple of [multiple].
  @useResult
  double ceilToMultiple(num multiple) {
    if (multiple <= 0) throw ArgumentError(_kErrMultiplePositive, _kParamMultiple);
    return (this / multiple).ceil() * multiple.toDouble();
  }
}
