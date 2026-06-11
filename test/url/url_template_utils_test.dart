import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/url_template_utils.dart';

void main() {
  group('expandUriTemplate', () {
    group('Level 1 (simple)', () {
      test('should substitute a simple variable with encoding', () {
        expect(
          expandUriTemplate('/users/{name}', <String, Object?>{'name': 'A B&C'}),
          equals('/users/A%20B%26C'),
        );
      });

      test('should pass literal text through unchanged', () {
        expect(expandUriTemplate('/static/path', <String, Object?>{}), equals('/static/path'));
      });

      test('should drop an undefined variable', () {
        expect(expandUriTemplate('/x/{missing}', <String, Object?>{}), equals('/x/'));
      });

      test('should render numbers and bools', () {
        expect(
          expandUriTemplate('/{id}/{flag}', <String, Object?>{'id': 42, 'flag': true}),
          equals('/42/true'),
        );
      });
    });

    group('Level 2 (reserved / fragment)', () {
      test('should keep reserved characters with +', () {
        expect(
          expandUriTemplate('{+path}/here', <String, Object?>{'path': '/foo/bar'}),
          equals('/foo/bar/here'),
        );
      });

      test('should prefix a fragment with #', () {
        expect(
          expandUriTemplate('page{#section}', <String, Object?>{'section': 'top'}),
          equals('page#top'),
        );
      });
    });

    group('Level 3 (operators / multiple)', () {
      test('should comma-join multiple simple variables', () {
        expect(
          expandUriTemplate('{x,y}', <String, Object?>{'x': 1, 'y': 2}),
          equals('1,2'),
        );
      });

      test('should build a query string with ?', () {
        expect(
          expandUriTemplate('/search{?q,page}', <String, Object?>{'q': 'dart', 'page': 2}),
          equals('/search?q=dart&page=2'),
        );
      });

      test('should continue a query with &', () {
        expect(
          expandUriTemplate('/x?a=1{&b}', <String, Object?>{'b': 'two'}),
          equals('/x?a=1&b=two'),
        );
      });

      test('should build path segments with /', () {
        expect(
          expandUriTemplate('{/a,b}', <String, Object?>{'a': 'x', 'b': 'y'}),
          equals('/x/y'),
        );
      });

      test('should build a label with .', () {
        expect(
          expandUriTemplate('file{.ext}', <String, Object?>{'ext': 'json'}),
          equals('file.json'),
        );
      });

      test('should build path-style params with ;', () {
        expect(
          expandUriTemplate('{;x,y}', <String, Object?>{'x': 1, 'y': 2}),
          equals(';x=1;y=2'),
        );
      });

      test('should render an empty named value per its operator', () {
        expect(expandUriTemplate('{;x}', <String, Object?>{'x': ''}), equals(';x'));
        expect(expandUriTemplate('{?x}', <String, Object?>{'x': ''}), equals('?x='));
      });
    });

    group('modifiers', () {
      test('should truncate with a :prefix', () {
        expect(
          expandUriTemplate('{name:3}', <String, Object?>{'name': 'Alexander'}),
          equals('Ale'),
        );
      });

      test('should comma-join a list without explode', () {
        expect(
          expandUriTemplate('{list}', <String, Object?>{
            'list': <String>['a', 'b', 'c'],
          }),
          equals('a,b,c'),
        );
      });

      test('should explode a list with * under a query operator', () {
        expect(
          expandUriTemplate('{?tags*}', <String, Object?>{
            'tags': <String>['x', 'y'],
          }),
          equals('?tags=x&tags=y'),
        );
      });

      test('should explode a list with / segments', () {
        expect(
          expandUriTemplate('{/parts*}', <String, Object?>{
            'parts': <String>['a', 'b'],
          }),
          equals('/a/b'),
        );
      });

      test('should drop an empty list', () {
        expect(expandUriTemplate('x{/list*}', <String, Object?>{'list': <String>[]}), equals('x'));
      });
    });
  });
}
