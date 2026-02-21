import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_nullable_extensions.dart';

void main() {
  group('ListExtensionsNullable', () {
    group('isListNullOrEmpty', () {
      test('Null list returns true', () {
        const List<int>? list = null;
        expect(list.isListNullOrEmpty, isTrue);
      });

      test('Empty list returns true', () {
        final List<int> list = <int>[];
        expect(list.isListNullOrEmpty, isTrue);
      });

      test('Non-empty list returns false', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List with one element returns false', () {
        final List<String> list = <String>['hello'];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List with null elements returns false (list is not null or empty)', () {
        final List<String?> list = <String?>[null, null];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List of doubles returns false', () {
        final List<double> list = <double>[1.0, 2.0];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List of booleans returns false', () {
        final List<bool> list = <bool>[true, false];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List of maps returns false', () {
        final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[<dynamic, dynamic>{}];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('List of lists returns false', () {
        final List<List<int>> list = <List<int>>[<int>[]];
        expect(list.isListNullOrEmpty, isFalse);
      });

      test('Large non-empty list returns false', () {
        final List<int> list = List<int>.generate(100, (int index) => index);
        expect(list.isListNullOrEmpty, isFalse);
      });
    });

    group('isNotListNullOrEmpty', () {
      test('Null list returns false', () {
        const List<int>? list = null;
        expect(list.isNotListNullOrEmpty, isFalse);
      });

      test('Empty list returns false', () {
        final List<int> list = <int>[];
        expect(list.isNotListNullOrEmpty, isFalse);
      });

      test('Non-empty list returns true', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List with one element returns true', () {
        final List<String> list = <String>['hello'];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List with null elements returns true (list is not null or empty)', () {
        final List<String?> list = <String?>[null, null];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List of doubles returns true', () {
        final List<double> list = <double>[1.0, 2.0];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List of booleans returns true', () {
        final List<bool> list = <bool>[true, false];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List of maps returns true', () {
        final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[<dynamic, dynamic>{}];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('List of lists returns true', () {
        final List<List<int>> list = <List<int>>[<int>[]];
        expect(list.isNotListNullOrEmpty, isTrue);
      });

      test('Large non-empty list returns true', () {
        final List<int> list = List<int>.generate(100, (int index) => index);
        expect(list.isNotListNullOrEmpty, isTrue);
      });
    });
  });
}
