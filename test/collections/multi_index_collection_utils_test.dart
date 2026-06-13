import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/multi_index_collection_utils.dart';

class _User {
  const _User(this.id, this.email, this.city);
  final int id;
  final String email;
  final String city;
}

void main() {
  group('MultiIndexCollection', () {
    MultiIndexCollection<_User> build() =>
        MultiIndexCollection<_User>(<String, Object Function(_User)>{
          'id': (_User u) => u.id,
          'email': (_User u) => u.email,
          'city': (_User u) => u.city,
        });

    test('should require at least one index', () {
      expect(
        () => MultiIndexCollection<_User>(<String, Object Function(_User)>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should look up by each index in O(1)', () {
      final MultiIndexCollection<_User> c = build();
      const _User alice = _User(1, 'a@x.com', 'NYC');
      const _User bob = _User(2, 'b@x.com', 'NYC');
      c.addAll(<_User>[alice, bob]);

      expect(c.getOneBy('id', 1), equals(alice));
      expect(c.getOneBy('email', 'b@x.com'), equals(bob));
      // Non-unique index: two users share a city.
      expect(c.getBy('city', 'NYC'), equals(<_User>[alice, bob]));
    });

    test('should return an empty list for an absent key', () {
      final MultiIndexCollection<_User> c = build()..add(const _User(1, 'a@x.com', 'NYC'));

      expect(c.getBy('city', 'LA'), isEmpty);
      expect(c.getOneBy('id', 99), isNull);
      expect(c.containsKey('email', 'missing@x.com'), isFalse);
    });

    test('should throw on an unknown index name', () {
      final MultiIndexCollection<_User> c = build();

      expect(() => c.getBy('phone', '555'), throwsArgumentError);
    });

    test('should keep all indexes in sync on remove', () {
      final MultiIndexCollection<_User> c = build();
      const _User alice = _User(1, 'a@x.com', 'NYC');
      const _User bob = _User(2, 'b@x.com', 'NYC');
      c.addAll(<_User>[alice, bob]);

      expect(c.remove(alice), isTrue);

      expect(c.length, equals(1));
      expect(c.getOneBy('id', 1), isNull);
      expect(c.getOneBy('email', 'a@x.com'), isNull);
      // bob still present; the NYC bucket shrank but survives.
      expect(c.getBy('city', 'NYC'), equals(<_User>[bob]));
    });

    test('should prune a bucket that becomes empty', () {
      final MultiIndexCollection<_User> c = build();
      const _User solo = _User(1, 'a@x.com', 'LA');
      c.add(solo);

      expect(c.containsKey('city', 'LA'), isTrue);
      c.remove(solo);
      expect(c.containsKey('city', 'LA'), isFalse);
    });

    test('should report false when removing an absent item', () {
      final MultiIndexCollection<_User> c = build();

      expect(c.remove(const _User(9, 'z@x.com', 'LA')), isFalse);
    });

    test('should expose all items and index names', () {
      final MultiIndexCollection<_User> c = build()..add(const _User(1, 'a@x.com', 'NYC'));

      expect(c.all, hasLength(1));
      expect(c.indexNames.toSet(), equals(<String>{'id', 'email', 'city'}));
      expect(() => c.all.add(const _User(2, 'b', 'c')), throwsUnsupportedError); // unmodifiable
    });
  });
}
