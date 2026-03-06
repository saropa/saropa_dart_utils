const String _kDay = 'day';
const String _kDays = 'days';
const String _kHour = 'hour';
const String _kHours = 'hours';
const String _kMinute = 'minute';
const String _kMinutes = 'minutes';
const String _kSecond = 'second';
const String _kSeconds = 'seconds';
const String _kMs = 'ms';
const String _kZeroS = '0s';
const String _kZeroSeconds = '0 seconds';

String? _formatUnit(
  int value,
  bool isShort,
  String shortSuffix,
  String singular,
  String plural,
) {
  if (value == 0) return null;
  return isShort ? '${value}$shortSuffix' : '$value ${value == 1 ? singular : plural}';
}

String? _secondsPart(
  Duration d,
  int seconds,
  List<String> parts,
  bool isIncludeSeconds,
  bool isShort,
) {
  if (!isIncludeSeconds) return null;
  if (seconds > 0)
    return isShort ? '${seconds}s' : '$seconds ${seconds == 1 ? _kSecond : _kSeconds}';
  if (parts.isEmpty && d.inSeconds == 0) return isShort ? _kZeroS : _kZeroSeconds;
  return null;
}

String? _millisPart(int millis, bool isIncludeMilliseconds, bool isShort) {
  if (!isIncludeMilliseconds || millis == 0) return null;
  return isShort ? '${millis}$_kMs' : '$millis $_kMs';
}

/// Formats [Duration] as a short string (e.g. "2h 30m" or "1d 2h").
///
/// [isIncludeSeconds] and [isIncludeMilliseconds] add smaller units when non-zero.
String formatDuration(
  Duration d, {
  bool isShort = true,
  bool isIncludeSeconds = true,
  bool isIncludeMilliseconds = false,
}) {
  final List<String> parts = <String>[];
  final int days = d.inDays;
  final int hours = d.inHours % 24;
  final int minutes = d.inMinutes % 60;
  final int seconds = d.inSeconds % 60;
  final int millis = d.inMilliseconds % 1000;
  final String? dPart = _formatUnit(days, isShort, 'd', _kDay, _kDays);
  if (dPart != null) parts.add(dPart);
  final String? hPart = _formatUnit(hours, isShort, 'h', _kHour, _kHours);
  if (hPart != null) parts.add(hPart);
  final String? mPart = _formatUnit(minutes, isShort, 'm', _kMinute, _kMinutes);
  if (mPart != null) parts.add(mPart);
  final String? sPart = _secondsPart(d, seconds, parts, isIncludeSeconds, isShort);
  if (sPart != null) parts.add(sPart);
  final String? msPart = _millisPart(millis, isIncludeMilliseconds, isShort);
  if (msPart != null) parts.add(msPart);
  return parts.isEmpty ? (isShort ? _kZeroS : _kZeroSeconds) : parts.join(' ');
}
