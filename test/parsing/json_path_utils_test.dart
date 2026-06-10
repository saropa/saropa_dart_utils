import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/json_path_utils.dart';

void main() {
  group('getByJsonPath', () {
    final Map<String, dynamic> data = <String, dynamic>{
      'users': <dynamic>[
        <String, dynamic>{'name': 'Ada'},
        <String, dynamic>{'name': 'Lin'},
      ],
      'meta': <String, dynamic>{'page': 1},
    };

    test('reads through a dollar-prefixed dotted/indexed path', () {
      expect(getByJsonPath(data, r'$.users[1].name'), 'Lin');
    });

    test('reads with no leading dollar', () {
      expect(getByJsonPath(data, 'users[0].name'), 'Ada');
      expect(getByJsonPath(data, 'meta.page'), 1);
    });

    test('returns null for an out-of-range index', () {
      expect(getByJsonPath(data, 'users[5].name'), isNull);
    });

    test('returns null for a missing key', () {
      expect(getByJsonPath(data, 'meta.missing'), isNull);
    });

    test('returns null when indexing a non-list', () {
      expect(getByJsonPath(data, 'meta[0]'), isNull);
    });

    test('indexes a top-level list', () {
      final List<dynamic> list = <dynamic>['x', 'y', 'z'];
      expect(getByJsonPath(list, '[2]'), 'z');
    });

    test('empty or dollar-only path returns the root', () {
      expect(getByJsonPath(data, r'$'), same(data));
      expect(getByJsonPath(data, ''), same(data));
    });

    test('null root yields null', () {
      expect(getByJsonPath(null, 'a.b'), isNull);
    });
  });
}
