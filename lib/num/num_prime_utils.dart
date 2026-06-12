/// Is prime (small numbers), prime factors. Roadmap #126–127.
/// Audited: 2026-06-12 11:26 EDT
bool isPrime(int n) {
  // Primes are >= 2; handle 2 (the only even prime) and reject other evens so
  // the trial-division loop can step by 2 over odd candidates only.
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  // A composite n has a factor <= sqrt(n), so testing odd divisors up to the
  // integer square root is sufficient (and far cheaper than testing to n).
  final int limit = _isqrt(n);
  // ignore: saropa_lints/prefer_correct_for_loop_increment -- steps by 2 to skip even candidates
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
/// Audited: 2026-06-12 11:26 EDT
List<int> primeFactors(int n) {
  if (n <= 1) return <int>[];
  final List<int> out = <int>[];
  int x = n.abs();
  // Trial division: divide out each factor fully (the inner while) before moving
  // on, so factors are emitted with multiplicity and in ascending order. Once a
  // factor exceeds the running square root, any remainder above 1 is itself a
  // prime (it can have no smaller factor left) and is appended below.
  for (int d = 2; d <= _isqrt(x); d++) {
    while (x % d == 0) {
      out.add(d);
      x ~/= d;
    }
  }
  if (x > 1) out.add(x);
  return out;
}
