/// Simple additive checksum for integrity. Roadmap #226.
int additiveChecksum(String input) {
  int sum = 0;
  for (final int code in input.codeUnits) sum += code;
  return sum & 0xFFFFFFFF;
}
