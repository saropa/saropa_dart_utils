/// GCD, LCM, and related integer math.
///
/// Tree-shakeable: import only this file if you need these functions.
library;

/// Greatest common divisor of [a] and [b]. Uses Euclidean algorithm.
int gcd(int a, int b) {
  int x = a.abs();
  int y = b.abs();
  while (y != 0) {
    final int t = y;
    y = x % y;
    x = t;
  }
  return x;
}

/// Least common multiple. Returns 0 if either argument is 0.
int lcm(int a, int b) {
  if (a == 0 || b == 0) return 0;
  return (a.abs() * b.abs()) ~/ gcd(a, b);
}
