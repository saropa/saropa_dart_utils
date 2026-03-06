import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_binary_search_extensions.dart';

void main() {
  group('binarySearchIndex', () {
    test('found', () => expect([1, 2, 3].binarySearchIndex(2), 1));
    test('not found', () => expect([1, 2, 3].binarySearchIndex(4), -1));
  });
  group('binarySearchInsertPoint', () {
    test('insert', () => expect([1, 3, 5].binarySearchInsertPoint(4), 2));
  });
  group('mergeSorted', () {
    test('basic', () {
      expect(mergeSorted<int>([1, 3], [2, 4]), [1, 2, 3, 4]);
    });
  });
}
