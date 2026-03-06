/// Lerp, inverse lerp, map value from one range to another. Roadmap #130–132.
double lerp(double a, double b, double t) => a + (b - a) * t;

double inverseLerp(double a, double b, double value) {
  if (a == b) return 0;
  return ((value - a) / (b - a)).clamp(0.0, 1.0);
}

double mapRange(double value, double fromMin, double fromMax, double toMin, double toMax) {
  final double t = inverseLerp(fromMin, fromMax, value);
  return lerp(toMin, toMax, t);
}
