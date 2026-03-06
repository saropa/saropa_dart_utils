const String _kErrModulusPositive = 'modulus must be positive';
const String _kParamModulus = 'modulus';

/// Modulo that handles negative (e.g. -1 % 7 → 6). Roadmap #129.
int modulo(int value, int modulus) {
  if (modulus <= 0) throw ArgumentError(_kErrModulusPositive, _kParamModulus);
  final int r = value % modulus;
  return r < 0 ? r + modulus : r;
}
