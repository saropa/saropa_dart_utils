/// Factorial with overflow guard. Roadmap #128.
int? factorial(int n) {
  if (n < 0) return null;
  if (n == 0 || n == 1) return 1;
  const int maxSafe = 20; // 21! overflows int
  if (n > maxSafe) return null;
  int r = 1;
  for (int i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}
