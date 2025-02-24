import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/enum/enum_iterable_extensions.dart';

enum EnumListTestEnum { value1, value2, value3 }

void main() {
  group('mostOccurrences tests', () {
    test('Test case 1: Normal case', () {
      final list1 = <EnumListTestEnum>[
        EnumListTestEnum.value1,
        EnumListTestEnum.value2,
        EnumListTestEnum.value2,
        EnumListTestEnum.value3,
        EnumListTestEnum.value3,
        EnumListTestEnum.value3,
      ];
      final result = list1.mostOccurrences();
      expect(result.key, EnumListTestEnum.value3);
      expect(result.value, 3);
    });

    test('Test case 2: All elements are the same', () {
      final list2 = <EnumListTestEnum>[
        EnumListTestEnum.value1,
        EnumListTestEnum.value1,
        EnumListTestEnum.value1,
        EnumListTestEnum.value1,
        EnumListTestEnum.value1,
      ];
      final result = list2.mostOccurrences();
      expect(result.key, EnumListTestEnum.value1);
      expect(result.value, 5);
    });

    test('Test case 3: Each element appears only once', () {
      final list3 = <EnumListTestEnum>[
        EnumListTestEnum.value1,
        EnumListTestEnum.value2,
        EnumListTestEnum.value3,
      ];
      final result = list3.mostOccurrences();
      expect(result.value, 1);
    });

    test('Test case 4: Empty list', () {
      final list4 = <EnumListTestEnum>[];
      expect(list4.mostOccurrences, throwsA(isA<Exception>()));
    });

    test('Test case 5: List with one element', () {
      final list5 = <EnumListTestEnum>[EnumListTestEnum.value1];
      final result = list5.mostOccurrences();
      expect(result.key, EnumListTestEnum.value1);
      expect(result.value, 1);
    });
  });

  group('byNameTry tests', () {
    test('Test case 1: Case-sensitive match', () {
      const list = EnumListTestEnum.values;
      final result = list.byNameTry('value1');
      expect(result, EnumListTestEnum.value1);
    });

    test('Test case 2: Case-insensitive match', () {
      const list = EnumListTestEnum.values;
      final result = list.byNameTry('VALUE2', caseSensitive: false);
      expect(result, EnumListTestEnum.value2);
    });

    test('Test case 3: No match found', () {
      const list = EnumListTestEnum.values;
      final result = list.byNameTry('value4');
      expect(result, isNull);
    });

    test('Test case 4: Null name', () {
      const list = EnumListTestEnum.values;
      final result = list.byNameTry(null);
      expect(result, isNull);
    });

    test('Test case 5: Empty name', () {
      const list = EnumListTestEnum.values;
      final result = list.byNameTry('');
      expect(result, isNull);
    });
  });

  group('sortedEnumValues tests', () {
    test('Test case 1: Normal case', () {
      const list = EnumListTestEnum.values;
      final result = list.sortedEnumValues();
      expect(result, [EnumListTestEnum.value1, EnumListTestEnum.value2, EnumListTestEnum.value3]);
    });

    test('Test case 2: Already sorted', () {
      final list = [EnumListTestEnum.value1, EnumListTestEnum.value2, EnumListTestEnum.value3];
      final result = list.sortedEnumValues();
      expect(result, [EnumListTestEnum.value1, EnumListTestEnum.value2, EnumListTestEnum.value3]);
    });

    test('Test case 3: Reverse order', () {
      final list = [EnumListTestEnum.value3, EnumListTestEnum.value2, EnumListTestEnum.value1];
      final result = list.sortedEnumValues();
      expect(result, [EnumListTestEnum.value1, EnumListTestEnum.value2, EnumListTestEnum.value3]);
    });

    test('Test case 4: Single element', () {
      final list = [EnumListTestEnum.value2];
      final result = list.sortedEnumValues();
      expect(result, [EnumListTestEnum.value2]);
    });

    test('Test case 5: Empty list', () {
      final list = <EnumListTestEnum>[];
      final result = list.sortedEnumValues();
      expect(result, <EnumListTestEnum>[]);
    });
  });
}
