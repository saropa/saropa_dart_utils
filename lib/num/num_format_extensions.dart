import 'dart:math' as math;
import 'package:meta/meta.dart';

const String _kErrSignificantDigitsPositive = 'significantDigits must be positive';
const String _kParamSignificantDigits = 'significantDigits';

/// Format numbers: significant digits, compact (1.2K).
extension NumFormatExtensions on num {
  /// Rounds to [significantDigits] significant digits.
  ///
  /// [significantDigits] must be positive.
  @useResult
  double roundToSignificantDigits(int significantDigits) {
    if (significantDigits < 1) {
      throw ArgumentError(_kErrSignificantDigitsPositive, _kParamSignificantDigits);
    }
    final double x = toDouble();
    if (x == 0) return 0;
    final double magnitude = x.abs();
    final int e = magnitude >= 1
        ? math.log(magnitude) ~/ math.ln10
        : -(math.log(magnitude) / math.ln10).ceil();
    final double scale = math.pow(10.0, significantDigits - 1 - e).toDouble();
    final double scaled = (x * scale).round() / scale;
    return scaled;
  }

  /// Formats as compact string (e.g. 1200 → "1.2K", 1500000 → "1.5M").
  ///
  /// [decimals] is the max decimal places for the fractional part.
  @useResult
  String toCompactString({int decimals = 1}) {
    final double n = toDouble().abs();
    const List<String> suffixes = <String>['', 'K', 'M', 'B', 'T'];
    int i = 0;
    double v = n;
    while (v >= 1000 && i < suffixes.length - 1) {
      v /= 1000;
      i++;
    }
    final String formatted = v >= 10 || v == v.truncateToDouble()
        ? v.truncate().toString()
        : v.toStringAsFixed(decimals).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final String sign = this < 0 ? '-' : '';
    return '$sign$formatted${suffixes[i]}';
  }
}
