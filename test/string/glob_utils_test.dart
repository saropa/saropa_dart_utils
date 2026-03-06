import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/glob_utils.dart';

void main() {
  group('GlobUtils.match', () {
    test('star', () => expect(GlobUtils.match('lib/foo.dart', 'lib/*.dart'), isTrue));
    test('double star', () => expect(GlobUtils.match('a/b/c', 'a/**/c'), isTrue));
    test('no match', () => expect(GlobUtils.match('lib/foo.txt', 'lib/*.dart'), isFalse));
  });
}
