import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/path_extension_utils.dart';
import 'package:saropa_dart_utils/url/path_join_utils.dart';
import 'package:saropa_dart_utils/url/url_absolute_utils.dart';
import 'package:saropa_dart_utils/url/url_query_utils.dart';

void main() {
  group('pathChangeExtension', () {
    test('replaces an existing extension', () {
      expect(pathChangeExtension('photo.png', 'jpg'), 'photo.jpg');
    });

    test('accepts a leading dot on the new extension', () {
      expect(pathChangeExtension('photo.png', '.webp'), 'photo.webp');
    });

    test('removes the extension when the new one is empty', () {
      expect(pathChangeExtension('photo.png', ''), 'photo');
    });
  });

  group('pathRelative', () {
    test('descends into a subdirectory', () {
      expect(pathRelative('a/b', 'a/b/c/d'), 'c/d');
    });

    test('identical paths yield an empty relative path', () {
      expect(pathRelative('a/b/c', 'a/b/c'), '');
    });

    // NOTE: the up-traversal case (e.g. 'a/b/c' -> 'a/b/d', which should be
    // '../d') is intentionally NOT asserted here because pathRelative currently
    // returns 'd' — pathJoin strips the leading '..'. That is a real bug,
    // surfaced separately rather than pinned as expected behavior.
  });

  group('isRelativePath', () {
    test('a bare path is relative', () {
      expect(isRelativePath('docs/readme.md'), isTrue);
    });

    test('a rooted POSIX path is not relative', () {
      expect(isRelativePath('/etc/hosts'), isFalse);
    });

    test('a Windows drive path is not relative', () {
      expect(isRelativePath(r'C:\Windows'), isFalse);
    });
  });

  group('buildQueryString', () {
    test('encodes and joins parameters', () {
      expect(buildQueryString(<String, String>{'q': 'a b', 'p': '2'}), 'q=a%20b&p=2');
    });

    test('empty map yields an empty string', () {
      expect(buildQueryString(<String, String>{}), '');
    });
  });

  group('uriWithQueryParams', () {
    test('adds parameters to a uri', () {
      final Uri result = uriWithQueryParams(Uri.parse('https://x.com/a'), <String, String>{
        'b': '2',
      });
      expect(result.queryParameters['b'], '2');
    });

    test('removes named parameters', () {
      final Uri result = uriWithQueryParams(
        Uri.parse('https://x.com/a?keep=1&drop=2'),
        <String, String>{},
        remove: <String>{'drop'},
      );
      expect(result.queryParameters.containsKey('drop'), isFalse);
      expect(result.queryParameters['keep'], '1');
    });
  });
}
