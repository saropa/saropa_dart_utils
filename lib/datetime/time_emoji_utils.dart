import 'package:saropa_dart_utils/datetime/date_constants.dart';

/// Utility class for handling time-related emojis, specifically for day/night representation.
class TimeEmojiUtils {
  /// Emoji representing the sun (☀️).
  static const String sunEmoji = '☀️';

  /// Emoji representing the moon (🌙).
  static const String moonEmoji = '🌙';

  /// Returns [sunEmoji] if the given hour is during daytime (7am inclusive to 6pm exclusive),
  /// otherwise returns [moonEmoji].
  ///
  /// Daytime range: hour >= [dayStartHour] (7) and hour < [dayEndHour] (18).
  /// At exactly 7am, sun is shown. At exactly 6pm (18:00), moon is shown.
  ///
  /// Returns `null` if `tzHour` is null or in case of any error during processing, logging the error.
  ///
  /// Example:
  /// ```dart
  /// TimeEmojiUtils.getEmojiDayOrNight(7);  // Returns '☀️' (7am — start of day)
  /// TimeEmojiUtils.getEmojiDayOrNight(10); // Returns '☀️' (10am)
  /// TimeEmojiUtils.getEmojiDayOrNight(18); // Returns '🌙' (6pm — start of night)
  /// TimeEmojiUtils.getEmojiDayOrNight(20); // Returns '🌙' (8pm)
  /// TimeEmojiUtils.getEmojiDayOrNight(null); // Returns null
  /// ```
  static String? getEmojiDayOrNight(int? tzHour) {
    if (tzHour == null) {
      return null;
    }

    return tzHour >= dayStartHour && tzHour < dayEndHour
        ? sunEmoji
        : moonEmoji;
  }
}

/// Extension on [DateTime] to easily access day/night emoji representation.
extension EmojiDateTimeExtensions on DateTime {
  /// Returns [TimeEmojiUtils.sunEmoji] if the [DateTime]'s hour is during daytime
  /// (7am inclusive to 6pm exclusive), otherwise returns [TimeEmojiUtils.moonEmoji].
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
