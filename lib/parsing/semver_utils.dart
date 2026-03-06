/// Semver parse and compare. Roadmap #150.
class SemVer {
  SemVer(int major, int minor, int patch, [String pre = '', String build = ''])
    : _major = major,
      _minor = minor,
      _patch = patch,
      _pre = pre,
      _build = build;
  final int _major;

  int get major => _major;
  final int _minor;

  int get minor => _minor;
  final int _patch;

  int get patch => _patch;
  final String _pre;

  String get pre => _pre;
  final String _build;

  String get build => _build;

  static SemVer? parse(String s) {
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
    return SemVer(majorVal, minorVal, patchVal, m.group(4) ?? '', m.group(5) ?? '');
  }

  int compareTo(SemVer other) {
    if (_major != other._major) return _major.compareTo(other._major);
    if (_minor != other._minor) return _minor.compareTo(other._minor);
    if (_patch != other._patch) return _patch.compareTo(other._patch);
    if (_pre.isEmpty && other._pre.isNotEmpty) return 1;
    if (_pre.isNotEmpty && other._pre.isEmpty) return -1;
    return _pre.compareTo(other._pre);
  }

  @override
  String toString() =>
      'SemVer($_major.$_minor.$_patch${_pre.isEmpty ? '' : '-$_pre'}${_build.isEmpty ? '' : '+$_build'})';
}
