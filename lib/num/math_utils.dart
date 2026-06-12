/// GCD, LCM, and related integer math.
///
/// Tree-shakeable: import only this file if you need these functions.
library;

/// Greatest common divisor of [a] and [b]. Uses Euclidean algorithm.
/// Audited: 2026-06-12 11:26 EDT
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
/// Audited: 2026-06-12 11:26 EDT
int lcm(int a, int b) {
  if (a == 0 || b == 0) return 0;
  // Divide before multiplying: `a * b` can overflow 64-bit for large operands,
  // whereas `(a / gcd) * b` keeps the intermediate small for the same result.
  return (a.abs() ~/ gcd(a, b)) * b.abs();
}
