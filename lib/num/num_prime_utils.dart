/// Is prime (small numbers), prime factors. Roadmap #126–127.
bool isPrime(int n) {
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  final int limit = _isqrt(n);
  for (int d = 3; d <= limit; d += 2) {
    if (n % d == 0) return false;
  }
  return true;
}

int _isqrt(int n) {
  if (n <= 0) return 0;
  int x = n;
  int y = (x + 1) >> 1;
  while (y < x) {
    x = y;
    y = (x + n ~/ x) >> 1;
  }
  return x;
}

/// Prime factors (small numbers). Returns list of prime factors with multiplicity.
List<int> primeFactors(int n) {
  if (n <= 1) return <int>[];
  final List<int> out = <int>[];
  int x = n.abs();
  for (int d = 2; d <= _isqrt(x); d++) {
    while (x % d == 0) {
      out.add(d);
      x ~/= d;
    }
  }
  if (x > 1) out.add(x);
  return out;
}
