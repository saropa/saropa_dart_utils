/// ISBN-10/13 validation. Roadmap #149.
bool isValidIsbn10(String isbn) {
  final String s = isbn.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  if (s.length != 10) return false;
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    final int? d = int.tryParse(s[i]);
    if (d == null) return false;
    sum += d * (10 - i);
  }
  if (s[9] == 'X') {
    sum += 10;
  } else {
    final int? d = int.tryParse(s[9]);
    if (d == null) return false;
    sum += d;
  }
  return sum % 11 == 0;
}

/// Returns `true` if [isbn] is a valid ISBN-13.
///
/// Strips spaces and hyphens, then verifies the input is exactly 13 digits and
/// satisfies the ISBN-13 mod-10 checksum (weights alternating 1 and 3). Returns
/// `false` for any other length or non-digit character.
///
/// Example:
/// ```dart
/// isValidIsbn13('978-0-306-40615-7'); // true
/// isValidIsbn13('978-0-306-40615-0'); // false
/// ```
bool isValidIsbn13(String isbn) {
  final String s = isbn.replaceAll(RegExp(r'[\s-]'), '');
  if (s.length != 13) return false;
  int sum = 0;
  for (int i = 0; i < 13; i++) {
    final int? d = int.tryParse(s[i]);
    if (d == null) return false;
    sum += d * (i.isOdd ? 3 : 1);
  }
  return sum % 10 == 0;
}
