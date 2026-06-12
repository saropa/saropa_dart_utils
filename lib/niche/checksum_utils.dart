/// Simple additive checksum for integrity. Roadmap #226.
/// Audited: 2026-06-12 11:26 EDT
int additiveChecksum(String input) {
  int sum = 0;
  for (final int code in input.codeUnits) {
    sum += code;
  }
  return sum & 0xFFFFFFFF;
}
