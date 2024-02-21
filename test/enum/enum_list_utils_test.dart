import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/enum/enum_list_utils.dart';

enum EnumListTestEnum {
  value1,
  value2,
  value3,
}

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
}
