import 'package:saropa_dart_utils/datetime/date_constants.dart';

/// Utility class for handling time-related emojis, specifically for day/night representation.
class TimeEmojiUtils {
  /// Emoji representing the sun (☀️).
  static const String sunEmoji = '☀️';

  /// Emoji representing the moon (🌙).
  static const String moonEmoji = '🌙';

  /// Returns [sunEmoji] if the given hour is between 8am (exclusive of 7am) and 5pm (exclusive of 6pm),
  /// otherwise returns [moonEmoji].
  ///
  /// Returns `null` if `tzHour` is null or in case of any error during processing, logging the error.
  ///
  /// Example:
  /// ```dart
  /// TimeEmojiUtils.getEmojiDayOrNight(10); // Returns '☀️' (for 10am)
  /// TimeEmojiUtils.getEmojiDayOrNight(20); // Returns '🌙' (for 8pm)
  /// TimeEmojiUtils.getEmojiDayOrNight(null); // Returns null
  /// ```
  static String? getEmojiDayOrNight(int? tzHour) {
    if (tzHour == null) {
      return null;
    }

    return tzHour > dayStartHour && tzHour < dayEndHour
        // sun emoji for hours between 8am and 5pm (exclusive of 7am and 6pm)
        ? sunEmoji
        // moon emoji for hours outside the 8am-5pm range
        : moonEmoji;
  }
}

/// Extension on [DateTime] to easily access day/night emoji representation.
extension EmojiDateTimeExtensions on DateTime {
  /// Returns [TimeEmojiUtils.sunEmoji] if the [DateTime]'s hour is between 8am (exclusive of 7am) and 5pm (exclusive of 6pm),
  /// otherwise returns [TimeEmojiUtils.moonEmoji].
  ///
  /// This is a convenient way to get the day/night emoji based on a [DateTime] instance.
  ///
  /// Example:
  /// ```dart
  /// DateTime now = DateTime.now();
  /// String? emoji = now.emojiDayOrNight; // Returns '☀️' or '🌙' based on the current hour.
  /// ```
  String? get emojiDayOrNight => TimeEmojiUtils.getEmojiDayOrNight(hour);
}
