import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_of_list_extensions.dart';

void main() {
  group('ListOfListExtension', () {
    group('totalLength', () {
      test('Empty list of lists should have a total length of 0', () {
        final List<List<int>> list = <List<int>>[];
        expect(list.totalLength, 0);
      });

      test('List of empty lists should have a total length of 0', () {
        final List<List<int>> list = <List<int>>[<int>[], <int>[], <int>[]];
        expect(list.totalLength, 0);
      });

      test('List with one inner list', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 3],
        ];
        expect(list.totalLength, 3);
      });

      test('List with multiple inner lists of the same length', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
          <int>[5, 6],
        ];
        expect(list.totalLength, 6);
      });

      test('List with inner lists of different lengths', () {
        final List<List<int>> list = <List<int>>[
          <int>[1],
          <int>[2, 3],
          <int>[4, 5, 6],
        ];
        expect(list.totalLength, 6);
      });

      test('List containing a mix of empty and non-empty lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[],
          <int>[3, 4, 5],
        ];
        expect(list.totalLength, 5);
      });

      test('List of lists of strings', () {
        final List<List<String>> list = <List<String>>[
          <String>['a', 'b'],
          <String>['c'],
          <String>['d', 'e', 'f'],
        ];
        expect(list.totalLength, 6);
      });

      test('Large list of lists', () {
        final List<List<int>> list = List<List<int>>.generate(
          100,
          (int index) => List<int>.generate(10, (int i) => i),
        );
        expect(list.totalLength, 1000);
      });

      test('List with duplicate elements across inner lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[2, 3],
          <int>[3, 3],
        ];
        expect(list.totalLength, 6);
      });

      test('List of lists with null values', () {
        final List<List<int?>> list = <List<int?>>[
          <int?>[1, null],
          <int?>[2, 3, null],
        ];
        expect(list.totalLength, 5);
      });
    });

    group('totalUniqueLength', () {
      test('Empty list of lists should have a total unique length of 0', () {
        final List<List<int>> list = <List<int>>[];
        expect(list.totalUniqueLength, 0);
      });

      test('List of empty lists should have a total unique length of 0', () {
        final List<List<int>> list = <List<int>>[<int>[], <int>[], <int>[]];
        expect(list.totalUniqueLength, 0);
      });

      test('List with all unique elements', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
          <int>[5, 6],
        ];
        expect(list.totalUniqueLength, 6);
      });

      test('List with duplicate elements within inner lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 1],
          <int>[2, 2],
        ];
        expect(list.totalUniqueLength, 2);
      });

      test('List with duplicate elements across inner lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[2, 3],
        ];
        expect(list.totalUniqueLength, 3);
      });

      test('List with a mix of unique and duplicate elements', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 2],
          <int>[3, 4, 1],
          <int>[5],
        ];
        expect(list.totalUniqueLength, 5);
      });

      test('List containing empty lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[],
          <int>[3],
        ];
        expect(list.totalUniqueLength, 3);
      });

      test('List of lists of strings with duplicates', () {
        final List<List<String>> list = <List<String>>[
          <String>['a', 'b'],
          <String>['b', 'c'],
          <String>['a'],
        ];
        expect(list.totalUniqueLength, 3);
      });

      test('List with null values', () {
        final List<List<int?>> list = <List<int?>>[
          <int?>[1, null],
          <int?>[2, 1],
          <int?>[null],
        ];
        // The unique non-null values are [1, 2]. The length is 2.
        expect(list.totalUniqueLength, 2); // Correct expectation
      });

      test('List with all elements being the same', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 1],
          <int>[1, 1],
          <int>[1],
        ];
        expect(list.totalUniqueLength, 1);
      });
    });

    group('toFlattenedList', () {
      test('Empty list of lists returns null', () {
        final List<List<int>> list = <List<int>>[];
        expect(list.toFlattenedList(), null);
      });

      test('List of empty lists returns an empty list', () {
        final List<List<int>> list = <List<int>>[<int>[], <int>[]];
        expect(list.toFlattenedList(), <int>[]);
      });

      test('List with all unique elements', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        expect(list.toFlattenedList(), <int>[1, 2, 3, 4]);
      });

      test('List with duplicate elements is flattened to a unique list', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 2],
          <int>[3, 1],
        ];
        expect(list.toFlattenedList(), <int>[1, 2, 3]);
      });

      test('List with inner lists of different lengths', () {
        final List<List<int>> list = <List<int>>[
          <int>[1],
          <int>[2, 3],
          <int>[4, 5, 6],
        ];
        expect(list.toFlattenedList(), <int>[1, 2, 3, 4, 5, 6]);
      });

      test('List containing a mix of empty and non-empty lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[],
          <int>[3, 1],
        ];
        expect(list.toFlattenedList(), <int>[1, 2, 3]);
      });

      test('Flattened list of strings with duplicates', () {
        final List<List<String>> list = <List<String>>[
          <String>['a', 'b'],
          <String>['c', 'b'],
        ];
        expect(list.toFlattenedList(), <String>['a', 'b', 'c']);
      });

      test('List with null values is flattened with null included as a unique value', () {
        final List<List<int?>> list = <List<int?>>[
          <int?>[1, null],
          <int?>[2, null],
        ];
        expect(list.toFlattenedList(ignoreNulls: false), <int?>[1, null, 2]);
      });

      test('Order of elements is preserved from their first appearance', () {
        final List<List<int>> list = <List<int>>[
          <int>[4, 2],
          <int>[1, 2, 3],
        ];
        expect(list.toFlattenedList(), <int>[4, 2, 1, 3]);
      });

      test('List where all elements are the same', () {
        final List<List<int>> list = <List<int>>[
          <int>[7, 7],
          <int>[7],
          <int>[7, 7, 7],
        ];
        expect(list.toFlattenedList(), <int>[7]);
      });
    });

    group('getChildListLengths', () {
      test('Empty list of lists returns an empty list', () {
        final List<List<int>> list = <List<int>>[];
        expect(list.getChildListLengths(), <int>[]);
      });

      test('List of empty lists returns a list of zeros', () {
        final List<List<int>> list = <List<int>>[<int>[], <int>[], <int>[]];
        expect(list.getChildListLengths(), <int>[0, 0, 0]);
      });

      test('List with inner lists of the same length', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        expect(list.getChildListLengths(), <int>[2, 2]);
      });

      test('List with inner lists of different lengths', () {
        final List<List<int>> list = <List<int>>[
          <int>[1],
          <int>[2, 3, 4],
          <int>[5, 6],
        ];
        expect(list.getChildListLengths(), <int>[1, 3, 2]);
      });

      test('List containing a mix of empty and non-empty lists', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 3],
          <int>[],
          <int>[4, 5],
        ];
        expect(list.getChildListLengths(), <int>[3, 0, 2]);
      });

      test('List with one inner list', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 3, 4],
        ];
        expect(list.getChildListLengths(), <int>[4]);
      });

      test('List of lists of strings', () {
        final List<List<String>> list = <List<String>>[
          <String>['a'],
          <String>['b', 'c'],
          <String>[],
        ];
        expect(list.getChildListLengths(), <int>[1, 2, 0]);
      });

      test('Large list of lists', () {
        final List<List<int>> list = <List<int>>[
          List<int>.generate(10, (int i) => i),
          List<int>.generate(5, (int i) => i),
        ];
        expect(list.getChildListLengths(), <int>[10, 5]);
      });

      test('List with inner lists containing nulls', () {
        final List<List<int?>> list = <List<int?>>[
          <int?>[1, null],
          <int?>[2, 3, 4, null],
        ];
        expect(list.getChildListLengths(), <int>[2, 4]);
      });

      test('List with deeply nested but empty lists', () {
        final List<List<List<int>>> list = <List<List<int>>>[
          <List<int>>[<int>[]],
          <List<int>>[<int>[], <int>[]],
        ];
        expect(list.getChildListLengths(), <int>[1, 2]);
      });
    });

    group('copy', () {
      test('Copying to a destination with the same dimensions succeeds', () {
        final List<List<int>> source = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[0, 0],
          <int>[0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ]);
      });

      test('Copying fails if number of rows differ', () {
        final List<List<int>> source = <List<int>>[
          <int>[1, 2],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[0, 0],
          <int>[0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isFalse);
        expect(destination, <List<int>>[
          <int>[0, 0],
          <int>[0, 0],
        ]); // Destination remains unchanged
      });

      test('Copying fails if number of columns differ in any row', () {
        final List<List<int>> source = <List<int>>[
          <int>[1, 2],
          <int>[3, 4, 5],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[0, 0],
          <int>[0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isFalse);
        expect(destination, <List<int>>[
          <int>[0, 0],
          <int>[0, 0],
        ]); // Destination remains unchanged
      });

      test('Copying an empty list to an empty list succeeds', () {
        final List<List<int>> source = <List<int>>[];
        final List<List<int>> destination = <List<int>>[];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<int>>[]);
      });

      test('Copying a list with empty inner lists succeeds', () {
        final List<List<int>> source = <List<int>>[
          <int>[],
          <int>[1, 2],
          <int>[],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[],
          <int>[0, 0],
          <int>[],
        ];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<int>>[
          <int>[],
          <int>[1, 2],
          <int>[],
        ]);
      });

      test('Copying from an empty list to a non-empty list fails', () {
        final List<List<int>> source = <List<int>>[];
        final List<List<int>> destination = <List<int>>[
          <int>[0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isFalse);
      });

      test('Copying a list of strings succeeds', () {
        final List<List<String>> source = <List<String>>[
          <String>['a', 'b'],
        ];
        final List<List<String>> destination = <List<String>>[
          <String>['', ''],
        ];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<String>>[
          <String>['a', 'b'],
        ]);
      });

      test('Copying a list with nulls succeeds', () {
        final List<List<int?>> source = <List<int?>>[
          <int?>[1, null],
        ];
        final List<List<int?>> destination = <List<int?>>[
          <int?>[0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<int?>>[
          <int?>[1, null],
        ]);
      });

      test('Copying into a destination with different references succeeds', () {
        final List<List<int>> source = <List<int>>[
          <int>[1, 2],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[0, 0],
        ];
        source.copy(destination);
        source[0][0] = 99;
        expect(source, <List<int>>[
          <int>[99, 2],
        ]);
        expect(destination, <List<int>>[
          <int>[1, 2],
        ]);
      });

      test('Copying ragged array to ragged array of same shape succeeds', () {
        final List<List<int>> source = <List<int>>[
          <int>[1],
          <int>[2, 3],
          <int>[4, 5, 6],
        ];
        final List<List<int>> destination = <List<int>>[
          <int>[0],
          <int>[0, 0],
          <int>[0, 0, 0],
        ];
        final bool result = source.copy(destination);
        expect(result, isTrue);
        expect(destination, <List<int>>[
          <int>[1],
          <int>[2, 3],
          <int>[4, 5, 6],
        ]);
      });
    });

    group('clone', () {
      test('Cloned list is equal to the original', () {
        final List<List<int>> original = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        final List<List<int>> cloned = original.clone();
        expect(cloned, original);
      });

      test('Cloned list is a different instance from the original', () {
        final List<List<int>> original = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        final List<List<int>> cloned = original.clone();
        expect(identical(cloned, original), isFalse);
      });

      test('Inner lists of the cloned list are different instances', () {
        final List<List<int>> original = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        final List<List<int>> cloned = original.clone();
        expect(identical(cloned[0], original[0]), isFalse);
        expect(identical(cloned[1], original[1]), isFalse);
      });

      test('Modifying the cloned list does not affect the original', () {
        final List<List<int>> original = <List<int>>[
          <int>[1, 2],
        ];
        final List<List<int>> cloned = original.clone();
        cloned[0][0] = 99;
        expect(original, <List<int>>[
          <int>[1, 2],
        ]);
        expect(cloned, <List<int>>[
          <int>[99, 2],
        ]);
      });

      test('Modifying the original list does not affect the cloned list', () {
        final List<List<int>> original = <List<int>>[
          <int>[1, 2],
        ];
        final List<List<int>> cloned = original.clone();
        original[0][0] = 99;
        expect(original, <List<int>>[
          <int>[99, 2],
        ]);
        expect(cloned, <List<int>>[
          <int>[1, 2],
        ]);
      });

      test('Cloning an empty list results in a new empty list', () {
        final List<List<int>> original = <List<int>>[];
        final List<List<int>> cloned = original.clone();
        expect(cloned, <List<int>>[]);
        expect(identical(cloned, original), isFalse);
      });

      test('Cloning a list with empty inner lists works correctly', () {
        final List<List<int>> original = <List<int>>[<int>[], <int>[]];
        final List<List<int>> cloned = original.clone();
        expect(cloned, <List<int>>[<int>[], <int>[]]);
        cloned.add(<int>[1]);
        expect(original.length, 2);
        expect(cloned.length, 3);
      });

      test('Cloning a ragged list works correctly', () {
        final List<List<int>> original = <List<int>>[
          <int>[1],
          <int>[2, 3],
        ];
        final List<List<int>> cloned = original.clone();
        expect(cloned, original);
        expect(identical(cloned[0], original[0]), isFalse);
      });

      test('Cloning a list of strings works correctly', () {
        final List<List<String>> original = <List<String>>[
          <String>['a', 'b'],
        ];
        final List<List<String>> cloned = original.clone();
        expect(cloned, original);
      });

      test('Cloning a list with nulls works correctly', () {
        final List<List<int?>> original = <List<int?>>[
          <int?>[1, null],
        ];
        final List<List<int?>> cloned = original.clone();
        expect(cloned, original);
      });
    });

    group('toMatrixString', () {
      test('Empty list returns an empty string', () {
        final List<List<int>> list = <List<int>>[];
        expect(list.toMatrixString(), '');
      });

      test('List with one row, one column', () {
        final List<List<int>> list = <List<int>>[
          <int>[1],
        ];
        expect(list.toMatrixString(), '1');
      });

      test('List with one row, multiple columns', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 3],
        ];
        expect(list.toMatrixString(), '1,2,3');
      });

      test('List with multiple rows, one column', () {
        final List<List<int>> list = <List<int>>[
          <int>[1],
          <int>[2],
          <int>[3],
        ];
        expect(list.toMatrixString(), '1\n2\n3');
      });

      test('Standard 2x2 matrix', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ];
        expect(list.toMatrixString(), '1,2\n3,4');
      });

      test('Ragged matrix with default line break', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5],
          <int>[6],
        ];
        expect(list.toMatrixString(), '1,2,3\n4,5\n6');
      });

      test('Matrix with a custom line break', () {
        final List<List<String>> list = <List<String>>[
          <String>['a', 'b'],
          <String>['c', 'd'],
        ];
        expect(list.toMatrixString(lineBreak: ' | '), 'a,b | c,d');
      });

      test('List containing an empty inner list', () {
        final List<List<int>> list = <List<int>>[
          <int>[1, 2],
          <int>[],
          <int>[3, 4],
        ];
        expect(list.toMatrixString(), '1,2\n\n3,4');
      });

      test('List with various data types including null', () {
        final List<List<dynamic>> list = <List<dynamic>>[
          <dynamic>[1, 'hello', null],
          <dynamic>[true, 3.14],
        ];
        expect(list.toMatrixString(), '1,hello,\ntrue,3.14');
      });

      test('List of empty lists', () {
        final List<List<int>> list = <List<int>>[<int>[], <int>[]];
        expect(list.toMatrixString(), '\n');
      });
    });
  });
}
