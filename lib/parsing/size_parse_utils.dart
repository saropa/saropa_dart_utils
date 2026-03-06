/// Parse size string ("1.5 MB", "512K") to bytes; format bytes to human. Roadmap #144–145.
final RegExp _sizeRegex = RegExp(
  r'^\s*([+-]?\d+(?:\.\d+)?)\s*([KMGTPE]?B?)\s*$',
  caseSensitive: false,
);

const String _kUnitB = 'B';

int? parseSizeToBytes(String input) {
  final RegExpMatch? m = _sizeRegex.firstMatch(input.trim());
  if (m == null) return null;
  final String? g1 = m.group(1);
  if (g1 == null) return null;
  final double? value = double.tryParse(g1);
  if (value == null || value < 0) return null;
  final String unit = (m.group(2) ?? '').toUpperCase().replaceAll(_kUnitB, '');
  const Map<String, int> factors = <String, int>{
    '': 1,
    'K': 1024,
    'M': 1048576,
    'G': 1073741824,
    'T': 1099511627776,
    'P': 1125899906842624,
    'E': 1152921504606846976,
  };
  final int? factor = factors[unit];
  if (factor == null) return null;
  return (value * factor).round();
}

const List<String> _sizeSuffixes = <String>['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];

const String _kSizeZeroB = '0 B';

String formatBytesToHuman(int bytes, {int decimals = 1}) {
  if (bytes < 0) return '-${formatBytesToHuman(-bytes, decimals: decimals)}';
  if (bytes == 0) return _kSizeZeroB;
  int i = 0;
  double v = bytes.toDouble();
  while (v >= 1024 && i < _sizeSuffixes.length - 1) {
    v /= 1024;
    i++;
  }
  final String formatted = v >= 10 || v == v.truncateToDouble()
      ? v.truncate().toString()
      : v.toStringAsFixed(decimals).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return '$formatted ${_sizeSuffixes[i]}';
}
