import 'package:meta/meta.dart';

/// Timezone offset string (e.g. +01:00, -05:30) from [DateTime].
extension DateTimeTimezoneOffsetExtensions on DateTime {
  /// Offset string for the local timezone (e.g. +01:00). Uses [timeZoneOffset].
  @useResult
  String get timeZoneOffsetString {
    final Duration offset = timeZoneOffset;
    final int totalMinutes = offset.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = (totalMinutes.abs() % 60);
    final String sign = totalMinutes >= 0 ? '+' : '-';
    return '$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
