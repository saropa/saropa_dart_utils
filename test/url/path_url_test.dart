import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/path_extension_utils.dart';
import 'package:saropa_dart_utils/url/path_join_utils.dart';
import 'package:saropa_dart_utils/url/url_absolute_utils.dart';
import 'package:saropa_dart_utils/url/url_query_utils.dart';

void main() {
  group('pathJoin', () {
    test('joins segments', () => expect(pathJoin(<String>['a', 'b', 'c']), 'a/b/c'));
  });
  group('pathNormalize', () {
    test('resolves ..', () => expect(pathNormalize('a/b/../c'), 'a/c'));
  });
  group('pathExtension', () {
    test('gets ext', () => expect(pathExtension('file.txt'), 'txt'));
  });
  group('pathWithoutExtension', () {
    test('removes ext', () => expect(pathWithoutExtension('file.txt'), 'file'));
  });
  group('parseQueryString', () {
    test('parses', () => expect(parseQueryString('a=1&b=2'), <String, String>{'a': '1', 'b': '2'}));
  });
  group('isAbsoluteUrl', () {
    test('https', () => expect(isAbsoluteUrl('https://x.com'), isTrue));
    test('relative', () => expect(isAbsoluteUrl('foo/bar'), isFalse));
  });
}
