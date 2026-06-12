/// Phone number normalize (digits only or E.164-ish). Roadmap #147.
/// Audited: 2026-06-12 11:26 EDT
String normalizePhoneDigits(String input) => input.replaceAll(RegExp(r'\D'), '');

/// E.164-ish: digits only, optional leading + preserved as prefix for result.
/// Audited: 2026-06-12 11:26 EDT
String normalizePhoneE164(String input) {
  final String digits = normalizePhoneDigits(input);
  final bool hasLeadingPlus = input.trim().startsWith('+');
  return hasLeadingPlus ? '+$digits' : digits;
}
