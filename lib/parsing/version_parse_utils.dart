/// Parse version string (major.minor.patch). Roadmap #151.
(int major, int minor, int patch)? parseVersion(String input) {
  final List<String> parts = input.trim().split(RegExp(r'[.\s]'));
  if (parts.length < 3) return null;
  final int? major = int.tryParse(parts[0]);
  final int? minor = int.tryParse(parts[1]);
  final int? patch = int.tryParse(parts[2]);
  if (major == null || minor == null || patch == null) return null;
  return (major, minor, patch);
}
