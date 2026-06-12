/// Pad number with leading zeros. Format file size. Roadmap #220–221.
const String _kPadCharZero = '0';
const String _kSizeZeroB = '0 B';
const List<String> _kFileSizeUnits = <String>['B', 'KB', 'MB', 'GB', 'TB'];

/// Returns [value] as a string left-padded with zeros to at least [length] chars.
///
/// Values already at or beyond [length] digits are returned unchanged. A
/// negative [value] keeps its `-` sign, which counts toward [length].
///
/// Example:
/// ```dart
/// padWithZeros(7, 3); // '007'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String padWithZeros(int value, int length) => value.toString().padLeft(length, _kPadCharZero);

/// Formats [bytes] as a human-readable size using binary (1024) units up to TB.
///
/// [decimals] controls the maximum fraction digits; trailing zeros are
/// trimmed. Whole values and sizes of 10 or more drop the fraction. Negative
/// inputs are prefixed with `-`.
///
/// Example:
/// ```dart
/// formatFileSize(1536); // '1.5 KB'
/// formatFileSize(0); // '0 B'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String formatFileSize(int bytes, {int decimals = 1}) {
  if (bytes < 0) return '-${formatFileSize(-bytes, decimals: decimals)}';
  if (bytes == 0) return _kSizeZeroB;
  const List<String> units = _kFileSizeUnits;
  int i = 0;
  double v = bytes.toDouble();
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  final String fmt = v >= 10 || v == v.truncateToDouble()
      ? v.truncate().toString()
      : v.toStringAsFixed(decimals).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return '$fmt ${units[i]}';
}
