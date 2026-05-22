/// Semver parse and compare. Roadmap #150.
class SemverUtils {
  /// Creates a semantic version from its [major], [minor], and [patch] numbers,
  /// with optional [pre]-release and [build] metadata strings.
  SemverUtils(int major, int minor, int patch, [String pre = '', String build = ''])
    : _major = major,
      _minor = minor,
      _patch = patch,
      _pre = pre,
      _build = build;
  final int _major;

  /// The major version number (breaking changes).
  int get major => _major;
  final int _minor;

  /// The minor version number (backward-compatible features).
  int get minor => _minor;
  final int _patch;

  /// The patch version number (backward-compatible fixes).
  int get patch => _patch;
  final String _pre;

  /// The pre-release identifier (e.g. `rc.1`), or an empty string if none.
  String get pre => _pre;
  final String _build;

  /// The build metadata (e.g. `001`), or an empty string if none.
  String get build => _build;

  /// Parses [s] into a [SemverUtils], or returns `null` if it is not valid.
  ///
  /// Accepts an optional leading `v`, three dot-separated numeric components,
  /// and optional `-prerelease` and `+build` suffixes. Surrounding whitespace is
  /// trimmed. Returns `null` for any input that does not match this shape.
  ///
  /// Example:
  /// ```dart
  /// SemverUtils.parse('v1.2.3-rc.1+build')?.major; // 1
  /// SemverUtils.parse('1.2'); // null
  /// ```
  static SemverUtils? parse(String s) {
    final RegExp re = RegExp(
      r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+([0-9A-Za-z.-]+))?$',
    );
    final RegExpMatch? m = re.firstMatch(s.trim());
    if (m == null) return null;
    final majorGroup = m.group(1);
    final minorGroup = m.group(2);
    final patchGroup = m.group(3);
    if (majorGroup == null || minorGroup == null || patchGroup == null) return null;
    final int? majorVal = int.tryParse(majorGroup);
    final int? minorVal = int.tryParse(minorGroup);
    final int? patchVal = int.tryParse(patchGroup);
    if (majorVal == null || minorVal == null || patchVal == null) return null;
    return SemverUtils(majorVal, minorVal, patchVal, m.group(4) ?? '', m.group(5) ?? '');
  }

  /// Compares this version against [other] following semver precedence rules.
  ///
  /// Returns a negative value if this version is lower, zero if equal in
  /// precedence, or a positive value if higher. Major, minor, then patch are
  /// compared numerically; a version with a pre-release ranks below one without.
  /// Build metadata is ignored, matching the semver spec.
  ///
  /// Example:
  /// ```dart
  /// SemverUtils(1, 0, 0).compareTo(SemverUtils(1, 0, 0, 'rc.1')); // > 0
  /// ```
  int compareTo(SemverUtils other) {
    if (_major != other._major) return _major.compareTo(other._major);
    if (_minor != other._minor) return _minor.compareTo(other._minor);
    if (_patch != other._patch) return _patch.compareTo(other._patch);
    // Semver §11: a pre-release version has LOWER precedence than the otherwise
    // equal normal version (1.0.0-rc < 1.0.0), so the side lacking a pre-release
    // ranks higher. Only when both have one do we compare them lexically.
    if (_pre.isEmpty && other._pre.isNotEmpty) return 1;
    if (_pre.isNotEmpty && other._pre.isEmpty) return -1;
    return _pre.compareTo(other._pre);
  }

  @override
  String toString() =>
      'SemverUtils($_major.$_minor.$_patch${_pre.isEmpty ? '' : '-$_pre'}${_build.isEmpty ? '' : '+$_build'})';
}
