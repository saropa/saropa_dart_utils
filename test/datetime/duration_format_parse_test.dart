import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/duration_format_utils.dart';
import 'package:saropa_dart_utils/datetime/duration_parse_utils.dart';

void main() {
  group('formatDuration', () {
    test('short format', () {
      expect(formatDuration(const Duration(hours: 2, minutes: 30)), '2h 30m');
    });
    test('zero', () {
      expect(formatDuration(Duration.zero, isIncludeSeconds: true), '0s');
    });
  });
  group('parseDuration', () {
    test('parses 90m', () {
      expect(parseDuration('90m'), const Duration(minutes: 90));
    });
    test('parses 1.5h', () {
      expect(parseDuration('1.5h'), const Duration(hours: 1, minutes: 30));
    });
    test('invalid returns null', () {
      expect(parseDuration(''), isNull);
      expect(parseDuration('x'), isNull);
    });
  });
}
