// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/relative_date_bucket_utils.dart';

void main() {
  group('relativeDateBucket', () {
    final DateTime today = DateTime(2023, 6, 15);

    test('same day returns "today" (ignores time component)', () {
      expect(relativeDateBucket(DateTime(2023, 6, 15, 23), today), 'today');
    });

    test('one day ago returns "yesterday"', () {
      expect(relativeDateBucket(DateTime(2023, 6, 14), today), 'yesterday');
    });

    test('two days ago returns "last 7 days"', () {
      expect(relativeDateBucket(DateTime(2023, 6, 13), today), 'last 7 days');
    });

    test('seven days ago is still "last 7 days" (upper boundary)', () {
      expect(relativeDateBucket(DateTime(2023, 6, 8), today), 'last 7 days');
    });

    test('eight days ago crosses into "last 30 days"', () {
      expect(relativeDateBucket(DateTime(2023, 6, 7), today), 'last 30 days');
    });

    test('thirty days ago is still "last 30 days" (upper boundary)', () {
      expect(relativeDateBucket(DateTime(2023, 5, 16), today), 'last 30 days');
    });

    test('thirty-one days ago returns "older"', () {
      expect(relativeDateBucket(DateTime(2023, 5, 15), today), 'older');
    });

    test('future date returns "older" (negative days)', () {
      expect(relativeDateBucket(DateTime(2023, 6, 16), today), 'older');
    });
  });
}
