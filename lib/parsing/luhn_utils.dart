/// Luhn check (credit card / ID validation). Roadmap #148.
bool luhnCheck(String digits) {
  const int minLength = 2;
  final String digitsOnly = digits.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < minLength) return false;
  bool isAlternate = false;
  int sum = 0;
  // Luhn scans right-to-left, doubling every second digit starting one left of
  // the check digit; iterating in reverse makes that "every other" alignment
  // independent of the overall length.
  for (int i = digitsOnly.length - 1; i >= 0; i--) {
    final int? digit = int.tryParse(digitsOnly[i]);
    if (digit == null) return false;
    int value = digit;
    if (isAlternate) {
      const int doubleDigitThreshold = 9;
      const int doubleDigitAdjust = 9;
      value *= 2;
      // A doubled digit > 9 (e.g. 8*2=16) must be reduced to its digit sum
      // (1+6=7); subtracting 9 is the arithmetic shortcut for that.
      if (value > doubleDigitThreshold) value -= doubleDigitAdjust;
    }
    sum += value;
    isAlternate = !isAlternate;
  }
  // The number is valid iff the total is a multiple of 10.
  const int modBase = 10;
  return sum % modBase == 0;
}
