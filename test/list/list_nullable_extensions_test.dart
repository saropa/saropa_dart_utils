import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_nullable_extensions.dart';

void main() {
  group('ListExtensionsNullable', () {
    group('isListNullOrEmpty', () {
      test('Null list returns true', () {
        const List<int>? list = null;
        expect(list.isListNullOrEmpty, true);
      });

      test('Empty list returns true', () {
        final List<int> list = [];
        expect(list.isListNullOrEmpty, true);
      });

      test('Non-empty list returns false', () {
        final List<int> list = [1, 2, 3];
        expect(list.isListNullOrEmpty, false);
      });

      test('List with one element returns false', () {
        final List<String> list = ['hello'];
        expect(list.isListNullOrEmpty, false);
      });

      test('List with null elements returns false (list is not null or empty)', () {
        final List<String?> list = [null, null];
        expect(list.isListNullOrEmpty, false);
      });

      test('List of doubles returns false', () {
        final List<double> list = [1.0, 2.0];
        expect(list.isListNullOrEmpty, false);
      });

      test('List of booleans returns false', () {
        final List<bool> list = [true, false];
        expect(list.isListNullOrEmpty, false);
      });

      test('List of maps returns false', () {
        final List<Map<dynamic, dynamic>> list = [{}];
        expect(list.isListNullOrEmpty, false);
      });

      test('List of lists returns false', () {
        final List<List<int>> list = [[]];
        expect(list.isListNullOrEmpty, false);
      });

      test('Large non-empty list returns false', () {
        final List<int> list = List.generate(100, (index) => index);
        expect(list.isListNullOrEmpty, false);
      });
    });

    group('isNotListNullOrEmpty', () {
      test('Null list returns false', () {
        const List<int>? list = null;
        expect(list.isNotListNullOrEmpty, false);
      });

      test('Empty list returns false', () {
        final List<int> list = [];
        expect(list.isNotListNullOrEmpty, false);
      });

      test('Non-empty list returns true', () {
        final List<int> list = [1, 2, 3];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List with one element returns true', () {
        final List<String> list = ['hello'];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List with null elements returns true (list is not null or empty)', () {
        final List<String?> list = [null, null];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List of doubles returns true', () {
        final List<double> list = [1.0, 2.0];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List of booleans returns true', () {
        final List<bool> list = [true, false];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List of maps returns true', () {
        final List<Map<dynamic, dynamic>> list = [{}];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('List of lists returns true', () {
        final List<List<int>> list = [[]];
        expect(list.isNotListNullOrEmpty, true);
      });

      test('Large non-empty list returns true', () {
        final List<int> list = List.generate(100, (index) => index);
        expect(list.isNotListNullOrEmpty, true);
      });
    });
  });
}
