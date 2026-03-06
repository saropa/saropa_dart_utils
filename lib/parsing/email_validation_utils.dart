/// Email validation (reasonable regex, not RFC-perfect). Roadmap #146.
final RegExp _emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

bool isValidEmail(String email) {
  final String s = email.trim();
  if (s.isEmpty || s.length > 254) return false;
  return _emailRegex.hasMatch(s);
}
