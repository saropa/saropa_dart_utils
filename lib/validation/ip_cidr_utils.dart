/// IP/CIDR utilities (subnet contains, range checks) — roadmap #686.
library;

const int _ipv4OctetCount = 4;
const int _ipv4OctetMin = 0;
const int _ipv4OctetMax = 255;
const int _bitsPerOctet = 8;
const int _ipv4PrefixMin = 0;
const int _ipv4PrefixMax = 32;
const int _ipv4MaskFull = 0xFFFFFFFF;

/// Parses IPv4 "a.b.c.d" into int (big-endian). Returns null if invalid.
int? parseIpv4(String s) {
  // A valid dotted-quad has exactly four octets; anything else is malformed.
  final List<String> parts = s.split('.');
  if (parts.length != _ipv4OctetCount) return null;
  int address = 0;
  // Pack the octets big-endian: each octet shifts the accumulator left 8 bits
  // before OR-ing the next in, so "1.2.3.4" becomes 0x01020304. Reject any octet
  // that is non-numeric or outside 0..255 (which would corrupt the packing).
  for (final String p in parts) {
    final int? n = int.tryParse(p);
    if (n == null || n < _ipv4OctetMin || n > _ipv4OctetMax) return null;
    address = (address << _bitsPerOctet) | n;
  }
  return address;
}

/// Checks if [ip] (as int) is in CIDR [network]/[prefixLen]. [network] is base address as int.
bool ipInCidr({required int ip, required int network, required int prefixLen}) {
  if (prefixLen < _ipv4PrefixMin || prefixLen > _ipv4PrefixMax) return false;
  final int shift = _ipv4PrefixMax - prefixLen;
  final int mask = prefixLen == _ipv4PrefixMin ? 0 : (_ipv4MaskFull << shift) & _ipv4MaskFull;
  return (ip & mask) == (network & mask);
}
