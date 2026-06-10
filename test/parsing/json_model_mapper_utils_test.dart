import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/json_model_mapper_utils.dart';

void main() {
  group('JsonModelReader', () {
    test('reads typed fields when present and well-typed', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{
        'name': 'Ada',
        'age': 36,
        'active': true,
        'score': 9,
        'nick': 'A',
        'tags': <String>['x', 'y'],
      });
      expect(r.requireString('name'), 'Ada');
      expect(r.requireInt('age'), 36);
      expect(r.requireBool('active'), isTrue);
      // int is widened to double.
      expect(r.requireDouble('score'), 9.0);
      expect(r.optionalString('nick'), 'A');
      expect(r.requireList<String>('tags'), <String>['x', 'y']);
      expect(r.errors.isEmpty, isTrue);
    });

    test('collects every error instead of throwing on the first', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{'age': 'NaN'});
      expect(r.requireString('name'), isNull);
      expect(r.requireInt('age'), isNull);
      expect(r.requireBool('active'), isNull);
      expect(r.errors.errors, hasLength(3));
    });

    test('distinguishes missing from wrong-type via code', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{'age': 'x'});
      r.requireString('name'); // missing
      r.requireInt('age'); // wrong type
      final List<String?> codes = r.errors.errors.map((e) => e.code).toList();
      expect(codes, containsAll(<String>['missing', 'type']));
    });

    test('optionalString returns fallback when absent, errors on bad type', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{'a': 1});
      expect(r.optionalString('missing', fallback: 'def'), 'def');
      expect(r.errors.isEmpty, isTrue);
      expect(r.optionalString('a', fallback: 'def'), 'def');
      expect(r.errors.isNotEmpty, isTrue);
    });

    test('requireList rejects heterogeneous element types', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{
        'tags': <Object?>['x', 2],
      });
      expect(r.requireList<String>('tags'), isNull);
      expect(r.errors.errors.single.path, 'tags');
    });

    test('non-map source treats every required read as missing', () {
      final JsonModelReader r = JsonModelReader(<Object?>[1, 2, 3]);
      expect(r.requireString('name'), isNull);
      expect(r.errors.errors.single.code, 'missing');
    });

    test('child reports nested errors with a dotted path on shared collection', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{
        'address': <String, Object?>{'zip': 90210},
      });
      final JsonModelReader? child = r.child('address');
      expect(child, isNotNull);
      child!.requireString('city');
      expect(child.errors.errors.single.path, 'address.city');
    });

    test('child records an error when the nested value is not an object', () {
      final JsonModelReader r = JsonModelReader(<String, Object?>{'address': 7});
      expect(r.child('address'), isNull);
      expect(r.errors.errors.single.path, 'address');
    });
  });
}
