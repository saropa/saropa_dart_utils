/// Email validation (reasonable regex, not RFC-perfect). Roadmap #146.
final RegExp _emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

/// Returns `true` if [email] looks like a valid address.
///
/// Trims surrounding whitespace before checking, then validates against a
/// pragmatic (not RFC-perfect) pattern. Returns `false` for an empty string,
/// addresses longer than 254 characters, or any malformed input.
///
/// Example:
/// ```dart
/// isValidEmail('user@example.com'); // true
/// isValidEmail('not-an-email'); // false
/// ```
bool isValidEmail(String email) {
  final String s = email.trim();
  if (s.isEmpty || s.length > 254) return false;
  return _emailRegex.hasMatch(s);
}
