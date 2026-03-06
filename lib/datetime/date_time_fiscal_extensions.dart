import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';

/// Fiscal year start/end (configurable start month).
extension DateTimeFiscalExtensions on DateTime {
  /// Fiscal year when year starts in [startMonth] (1–12). E.g. startMonth 4 → FY runs Apr–Mar.
  @useResult
  int fiscalYear({int startMonth = 1}) {
    if (startMonth < 1 || startMonth > DateConstants.maxMonth) return year;
    if (month >= startMonth) return year;
    return year - 1;
  }

  /// Start of fiscal year (first day of [startMonth] at 00:00:00).
  @useResult
  DateTime startOfFiscalYear({int startMonth = 1}) {
    if (startMonth < 1 || startMonth > DateConstants.maxMonth) return DateTime(year);
    final int fy = fiscalYear(startMonth: startMonth);
    return DateTime(fy, startMonth);
  }

  /// End of fiscal year (last day of (startMonth-1) at 23:59:59.999999).
  @useResult
  DateTime endOfFiscalYear({int startMonth = 1}) {
    if (startMonth < 1 || startMonth > DateConstants.maxMonth) {
      return DateTime(year, DateTime.december, DateConstants.decemberLastDay, 23, 59, 59, 999, 999);
    }
    final int fy = fiscalYear(startMonth: startMonth);
    final int endMonth = startMonth == 1 ? DateTime.december : startMonth - 1;
    final int endYear = startMonth == 1 ? fy : fy + 1;
    final int lastDay = DateTimeUtils.monthDayCount(year: endYear, month: endMonth);
    return DateTime(endYear, endMonth, lastDay, 23, 59, 59, 999, 999);
  }
}
