import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_constant_extensions.dart';

void main() {
  group('isUnixEpochDate', () {
    test('returns true when the date is the Unix epoch date', () {
      expect(DateTime.utc(1970).isUnixEpochDate, isTrue);
    });

    test('returns false when the date is not the Unix epoch date', () {
      expect(DateTime.utc(1970, 1, 2).isUnixEpochDate, isFalse);
      expect(DateTime.utc(1969, 12, 31).isUnixEpochDate, isFalse);
      expect(DateTime.utc(1970, 2).isUnixEpochDate, isFalse);
      expect(DateTime.utc(1969).isUnixEpochDate, isFalse);
    });
  });

  group('isUnixEpochDateTime', () {
    test('returns true when the date and time are the Unix epoch', () {
      expect(DateTime.utc(1970).isUnixEpochDateTime, isTrue);
    });

    test('returns false when the date and time are not the Unix epoch', () {
      expect(DateTime.utc(1970, 1, 1, 0, 0, 1).isUnixEpochDateTime, isFalse);
      expect(DateTime.utc(1970, 1, 1, 0, 1).isUnixEpochDateTime, isFalse);
      expect(DateTime.utc(1970, 1, 1, 1).isUnixEpochDateTime, isFalse);
      expect(DateTime.utc(1969, 12, 31, 23, 59, 59).isUnixEpochDateTime, isFalse);
    });
  });
}
