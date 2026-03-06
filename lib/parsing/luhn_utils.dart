/// Luhn check (credit card / ID validation). Roadmap #148.
bool luhnCheck(String digits) {
  const int minLength = 2;
  const int modBase = 10;
  const int doubleDigitThreshold = 9;
  const int doubleDigitAdjust = 9;

  final String digitsOnly = digits.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < minLength) return false;
  int sum = 0;
  bool isAlternate = false;
  for (int i = digitsOnly.length - 1; i >= 0; i--) {
    final int? digit = int.tryParse(digitsOnly[i]);
    if (digit == null) return false;
    int value = digit;
    if (isAlternate) {
      value *= 2;
      if (value > doubleDigitThreshold) value -= doubleDigitAdjust;
    }
    sum += value;
    isAlternate = !isAlternate;
  }
  return sum % modBase == 0;
}
