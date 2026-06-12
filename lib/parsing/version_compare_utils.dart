/// Version compare (dotted numeric). Roadmap #250.
///
/// WARNING: this compares ONLY the dotted numeric components. A non-numeric
/// segment degrades to `0`, so a pre-release like `1.0.0-rc` compares EQUAL to
/// `1.0.0` (the `0-rc` segment becomes `0`). For real semver precedence
/// (pre-release ranks below release, numeric-vs-alphanumeric identifiers), use
/// `SemverUtils.parse(...)` + `SemverUtils.compareTo`.
/// Audited: 2026-06-12 11:26 EDT
int compareVersions(String a, String b) {
  // Compare dotted numeric versions segment by segment. Non-numeric segments
  // degrade to 0 rather than throwing.
  final List<int> partsA = a.split('.').map((String s) => int.tryParse(s) ?? 0).toList();
  final List<int> partsB = b.split('.').map((String s) => int.tryParse(s) ?? 0).toList();
  // Iterate to the longer length, treating missing trailing segments as 0 so
  // "1.2" and "1.2.0" compare equal. First differing segment decides the order.
  for (int i = 0; i < partsA.length || i < partsB.length; i++) {
    final int segmentA = i < partsA.length ? partsA[i] : 0;
    final int segmentB = i < partsB.length ? partsB[i] : 0;
    if (segmentA != segmentB) return segmentA.compareTo(segmentB);
  }
  return 0;
}
