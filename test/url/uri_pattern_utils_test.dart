import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/uri_pattern_utils.dart';

void main() {
  group('UriPattern.match', () {
    test('captures named segment params', () {
      final Map<String, String>? m =
          UriPattern('/users/{id}/posts/{slug}').match('/users/42/posts/hello');
      expect(m, <String, String>{'id': '42', 'slug': 'hello'});
    });

    test('returns null on segment-count mismatch', () {
      expect(UriPattern('/users/{id}').match('/users/42/extra'), isNull);
      expect(UriPattern('/users/{id}').match('/users'), isNull);
    });

    test('returns null on literal mismatch', () {
      expect(UriPattern('/users/{id}').match('/teams/42'), isNull);
    });

    test('int constraint matches only integers', () {
      final UriPattern p = UriPattern('/users/{id:int}');
      expect(p.match('/users/42'), <String, String>{'id': '42'});
      expect(p.match('/users/abc'), isNull);
    });

    test('ignores leading and trailing slashes', () {
      final UriPattern p = UriPattern('users/{id}');
      expect(p.match('/users/42/'), <String, String>{'id': '42'});
    });

    test('all-literal template matches with an empty param map', () {
      expect(UriPattern('/health/live').match('/health/live'), <String, String>{});
      expect(UriPattern('/health/live').match('/health/ready'), isNull);
    });

    test('root template matches the root path', () {
      expect(UriPattern('/').match('/'), <String, String>{});
    });

    test('negative-looking int still parses as int', () {
      expect(UriPattern('/n/{v:int}').match('/n/-7'), <String, String>{'v': '-7'});
    });
  });
}
