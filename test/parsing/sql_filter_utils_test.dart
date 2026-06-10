import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/sql_filter_utils.dart';

void main() {
  final List<Map<String, Object?>> users = <Map<String, Object?>>[
    <String, Object?>{'name': 'Alice', 'age': 30, 'city': 'New York', 'vip': true, 'note': null},
    <String, Object?>{'name': 'Bob', 'age': 17, 'city': 'Newark', 'vip': false, 'note': 'hi'},
    <String, Object?>{'name': 'Carol', 'age': 25, 'city': 'Boston', 'vip': true, 'note': null},
  ];

  List<String> names(List<Map<String, Object?>> rows) =>
      rows.map((Map<String, Object?> r) => r['name']! as String).toList();

  group('filterRows', () {
    test('should filter by a numeric comparison', () {
      expect(names(filterRows(users, 'age >= 18')), equals(<String>['Alice', 'Carol']));
    });

    test('should combine predicates with AND', () {
      expect(names(filterRows(users, "age > 18 AND city = 'Boston'")), equals(<String>['Carol']));
    });

    test('should combine predicates with OR', () {
      expect(names(filterRows(users, "city = 'Boston' OR age < 18")), equals(<String>['Bob', 'Carol']));
    });

    test('should honor NOT and parentheses', () {
      expect(names(filterRows(users, "NOT (city = 'Boston')")), equals(<String>['Alice', 'Bob']));
    });

    test('should match LIKE with % and _ wildcards', () {
      expect(names(filterRows(users, "city LIKE 'New%'")), equals(<String>['Alice', 'Bob']));
      expect(names(filterRows(users, "name LIKE 'B_b'")), equals(<String>['Bob']));
    });

    test('should match IN a value list', () {
      expect(names(filterRows(users, 'age IN (17, 25)')), equals(<String>['Bob', 'Carol']));
    });

    test('should support IS NULL and IS NOT NULL', () {
      expect(names(filterRows(users, 'note IS NULL')), equals(<String>['Alice', 'Carol']));
      expect(names(filterRows(users, 'note IS NOT NULL')), equals(<String>['Bob']));
    });

    test('should compare booleans with =', () {
      expect(names(filterRows(users, 'vip = true')), equals(<String>['Alice', 'Carol']));
    });

    test('should compare strings lexicographically', () {
      expect(names(filterRows(users, "name > 'Bob'")), equals(<String>['Carol']));
    });

    test('should support <> for inequality', () {
      expect(names(filterRows(users, "city <> 'Boston'")), equals(<String>['Alice', 'Bob']));
    });

    test('should exclude rows where ordering types are incomparable', () {
      // age (num) vs a string literal: not comparable → no match, no throw.
      expect(filterRows(users, "age > 'x'"), isEmpty);
    });

    test('should be case-insensitive for keywords', () {
      expect(names(filterRows(users, "age > 18 and city = 'Boston'")), equals(<String>['Carol']));
    });
  });

  group('compileFilter', () {
    test('should compile once and apply to many rows', () {
      final RowPredicate isAdult = compileFilter('age >= 18');

      expect(isAdult(users[0]), isTrue);
      expect(isAdult(users[1]), isFalse);
    });

    test('should throw on a malformed clause', () {
      expect(() => compileFilter('age >'), throwsFormatException);
      expect(() => compileFilter('age 18'), throwsFormatException);
      expect(() => compileFilter('age > 18 extra'), throwsFormatException);
    });
  });
}
