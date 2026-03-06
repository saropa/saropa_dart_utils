/// Version compare (semver or dotted). Roadmap #250.
int compareVersions(String a, String b) {
  final List<int> partsA = a.split('.').map((String s) => int.tryParse(s) ?? 0).toList();
  final List<int> partsB = b.split('.').map((String s) => int.tryParse(s) ?? 0).toList();
  for (int i = 0; i < partsA.length || i < partsB.length; i++) {
    final int segmentA = i < partsA.length ? partsA[i] : 0;
    final int segmentB = i < partsB.length ? partsB[i] : 0;
    if (segmentA != segmentB) return segmentA.compareTo(segmentB);
  }
  return 0;
}
