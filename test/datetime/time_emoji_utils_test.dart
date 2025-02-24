import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/time_emoji_utils.dart';

void main() {
  group('TimeEmojiUtils', () {
    group('getEmojiDayOrNight', () {
      test('Null tzHour returns null', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(null), null);
      });

      test('Hour 6 (6am) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(6), TimeEmojiUtils.moonEmoji);
      });

      test('Hour 7 (7am) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(7), TimeEmojiUtils.moonEmoji);
      });

      test('Hour 8 (8am) returns sunEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(8), TimeEmojiUtils.sunEmoji);
      });

      test('Hour 12 (12pm) returns sunEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(12), TimeEmojiUtils.sunEmoji);
      });

      test('Hour 17 (5pm) returns sunEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(17), TimeEmojiUtils.sunEmoji);
      });

      test('Hour 18 (6pm) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(18), TimeEmojiUtils.moonEmoji);
      });

      test('Hour 19 (7pm) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(19), TimeEmojiUtils.moonEmoji);
      });

      test('Hour 0 (midnight) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(0), TimeEmojiUtils.moonEmoji);
      });

      test('Hour 23 (11pm) returns moonEmoji', () {
        expect(TimeEmojiUtils.getEmojiDayOrNight(23), TimeEmojiUtils.moonEmoji);
      });
    });
  });

  group('EmojiDateTimeExtensions', () {
    group('emojiDayOrNight', () {
      test('DateTime with hour 6 (6am) returns moonEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 6);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });

      test('DateTime with hour 9 (9am) returns sunEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 9);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.sunEmoji);
      });

      test('DateTime with hour 18 (6pm) returns moonEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 18);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });

      test('DateTime with hour 7 (7am) returns moonEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 7);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });

      test('DateTime with hour 17 (5pm) returns sunEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 17);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.sunEmoji);
      });

      test('DateTime with hour 12 (noon) returns sunEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 12);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.sunEmoji);
      });

      test('DateTime with hour 0 (midnight) returns moonEmoji', () {
        final dateTime = DateTime(2024);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });

      test('DateTime with hour 23 (11pm) returns moonEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 23);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });
      test('DateTime with hour 8 (8am) returns sunEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 8);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.sunEmoji);
      });
      test('DateTime with hour 5 (5am) returns moonEmoji', () {
        final dateTime = DateTime(2024, 1, 1, 5);
        expect(dateTime.emojiDayOrNight, TimeEmojiUtils.moonEmoji);
      });
    });
  });
}
