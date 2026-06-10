import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/regex/regex_match_utils.dart';

void main() {
  group('namedGroupMap', () {
    test('extracts named groups into a map', () {
      final RegExpMatch match = RegExp(r'(?<y>\d{4})-(?<m>\d{2})').firstMatch('2026-06')!;
      expect(namedGroupMap(match), <String, String>{'y': '2026', 'm': '06'});
    });

    test('returns an empty map when there are no named groups', () {
      final RegExpMatch match = RegExp(r'\d+').firstMatch('123')!;
      expect(namedGroupMap(match), isEmpty);
    });
  });
}
