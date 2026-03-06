/// Phone number normalize (digits only or E.164-ish). Roadmap #147.
String normalizePhoneDigits(String input) {
  return input.replaceAll(RegExp(r'\D'), '');
}

/// E.164-ish: digits only, optional leading + preserved as prefix for result.
String normalizePhoneE164(String input) {
  final String digits = normalizePhoneDigits(input);
  final bool hasLeadingPlus = input.trim().startsWith('+');
  return hasLeadingPlus ? '+$digits' : digits;
}
