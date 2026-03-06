import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/regex/regex_common_utils.dart';
import 'package:saropa_dart_utils/regex/regex_match_utils.dart';

void main() {
  group('regexEmailSimple', () {
    test('matches email', () => expect(regexEmailSimple.hasMatch('u@h.com'), isTrue));
  });
  group('matchAll', () {
    test('returns all matches', () {
      final List<RegExpMatch> m = matchAll(RegExp(r'\d+'), 'a1b22c');
      expect(m, hasLength(2));
      expect(m[0][0], '1');
      expect(m[1][0], '22');
    });
  });
  group('replaceAllWithCallback', () {
    test('replaces with callback', () {
      final String r = replaceAllWithCallback('a1b2', RegExp(r'\d'), (m) => 'X');
      expect(r, 'aXbX');
    });
  });
}
