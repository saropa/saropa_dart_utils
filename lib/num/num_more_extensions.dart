import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Number More: clamp non-negative, isInteger, round half up, truncate decimals, percentage, degrees/radians, etc. Roadmap #311-325.
extension NumMoreExtensions on num {
  @useResult
  int clampNonNegative() => this < 0 ? 0 : round();

  @useResult
  bool get isInteger => this is int || (this is double && this == roundToDouble());

  @useResult
  double truncateToDecimals(int places) {
    final double f = math.pow(10, places).toDouble();
    return (this * f).truncate() / f;
  }

  @useResult
  double percentageChangeFrom(num from) => from == 0 ? 0 : (this - from) / from;

  @useResult
  double percentageOf(num total) => total == 0 ? 0 : this / total;
}

double degreesToRadians(double deg) => deg * math.pi / 180;
double radiansToDegrees(double rad) => rad * 180 / math.pi;

double normalizeAngle360(double degrees) {
  double d = degrees % 360;
  if (d < 0) d += 360;
  return d;
}

double normalizeAngle180(double degrees) {
  double d = degrees % 360;
  if (d > 180) d -= 360;
  if (d < -180) d += 360;
  return d;
}

int digitSum(int n) {
  int remaining = n.abs();
  int s = 0;
  while (remaining > 0) {
    s += remaining % 10;
    remaining ~/= 10;
  }
  return s;
}

bool isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

int nextPowerOfTwo(int n) {
  if (n <= 0) return 1;
  int v = n - 1;
  v |= v >> 1;
  v |= v >> 2;
  v |= v >> 4;
  v |= v >> 8;
  v |= v >> 16;
  return v + 1;
}

int isqrt(int n) {
  if (n <= 0) return 0;
  int x = n;
  int y = (x + 1) >> 1;
  while (y < x) {
    x = y;
    y = (x + n ~/ x) >> 1;
  }
  return x;
}
