import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_extensions.dart';

// cspell: disable
void main() {
  group('MapExtensions.nullIfEmpty', () {
    test('1. Empty map returns null', () => expect(<String, int>{}.nullIfEmpty(), isNull));
    test('2. Non-empty map returns self', () {
      final Map<String, int> map = <String, int>{'a': 1};
      expect(map.nullIfEmpty(), same(map));
    });
    test(
      '3. Single entry',
      () => expect(<String, int>{'key': 1}.nullIfEmpty(), <String, int>{'key': 1}),
    );
    test('4. Multiple entries', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      expect(map.nullIfEmpty(), isNotNull);
    });
    test('5. String keys', () => expect(<String, String>{'a': 'b'}.nullIfEmpty(), isNotNull));
    test('6. Int keys', () => expect(<int, String>{1: 'a'}.nullIfEmpty(), isNotNull));
    test(
      '7. Nested map',
      () => expect(
        <String, Map<String, int>>{
          'a': <String, int>{'b': 1},
        }.nullIfEmpty(),
        isNotNull,
      ),
    );
    test(
      '8. List values',
      () => expect(
        <String, List<int>>{
          'a': <int>[1, 2],
        }.nullIfEmpty(),
        isNotNull,
      ),
    );
    test('9. Null values', () => expect(<String, int?>{'a': null}.nullIfEmpty(), isNotNull));
    test('10. Dynamic types', () => expect(<dynamic, dynamic>{'a': 1}.nullIfEmpty(), isNotNull));
  });

  group('MapExtensions.getRandomListExcept', () {
    test('1. Get random entries', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 2,
        ignoreList: <String>[],
      );
      expect(result, isNotNull);
      expect(result?.length, 2);
    });
    test('2. Exclude some keys', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2, 'c': 3};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 2,
        ignoreList: <String>['a'],
      );
      expect(result, isNotNull);
      expect(result?.any((MapEntry<String, int> e) => e.key == 'a'), isFalse);
    });
    test('3. All keys excluded', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 1,
        ignoreList: <String>['a', 'b'],
      );
      expect(result, isNull);
    });
    test('4. Null ignore list', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 1,
        ignoreList: null,
      );
      expect(result, isNotNull);
    });
    test('5. Empty map', () {
      final Map<String, int> map = <String, int>{};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 1,
        ignoreList: <String>[],
      );
      expect(result, isNull);
    });
    test('6. Request more than available', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 5,
        ignoreList: <String>[],
      );
      expect(result, isNotNull);
      expect(result?.length, 2);
    });
    test('7. Request zero', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 0,
        ignoreList: <String>[],
      );
      expect(result, isNotNull);
      expect(result?.isEmpty, isTrue);
    });
    test('8. Single entry', () {
      final Map<String, int> map = <String, int>{'a': 1};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 1,
        ignoreList: <String>[],
      );
      expect(result, isNotNull);
      expect(result?.length, 1);
    });
    test('9. Exclude non-existent key', () {
      final Map<String, int> map = <String, int>{'a': 1, 'b': 2};
      final List<MapEntry<String, int>>? result = map.getRandomListExcept(
        count: 2,
        ignoreList: <String>['x'],
      );
      expect(result, isNotNull);
      expect(result?.length, 2);
    });
    test('10. Int keys', () {
      final Map<int, String> map = <int, String>{1: 'a', 2: 'b', 3: 'c'};
      final List<MapEntry<int, String>>? result = map.getRandomListExcept(
        count: 2,
        ignoreList: <int>[1],
      );
      expect(result, isNotNull);
      expect(result?.any((MapEntry<int, String> e) => e.key == 1), isFalse);
    });
  });

  group('StringMapExtensions.formatMap', () {
    test('1. Empty map', () => expect(<String, dynamic>{}.formatMap(), ''));
    test('2. Single entry', () {
      final String result = <String, dynamic>{'key': 'value'}.formatMap();
      expect(result.contains('key'), isTrue);
      expect(result.contains('value'), isTrue);
    });
    test('3. Multiple entries', () {
      final String result = <String, dynamic>{'a': 1, 'b': 2}.formatMap();
      expect(result.contains('a'), isTrue);
      expect(result.contains('b'), isTrue);
    });
    test('4. Nested map', () {
      final String result = <String, dynamic>{
        'outer': <String, dynamic>{'inner': 'value'},
      }.formatMap();
      expect(result.contains('outer'), isTrue);
      expect(result.contains('inner'), isTrue);
    });
    test('5. List value', () {
      final String result = <String, dynamic>{
        'list': <int>[1, 2, 3],
      }.formatMap();
      expect(result.contains('list'), isTrue);
      expect(result.contains('1'), isTrue);
    });
    test('6. Null value', () {
      final String result = <String, dynamic>{'key': null}.formatMap();
      expect(result.contains('key'), isTrue);
      expect(result.contains('null'), isTrue);
    });
    test('7. Mixed types', () {
      final String result = <String, dynamic>{'str': 'text', 'num': 42, 'bool': true}.formatMap();
      expect(result.isNotEmpty, isTrue);
    });
    test('8. Contains braces', () {
      final String result = <String, dynamic>{'a': 1}.formatMap();
      expect(result.contains('{'), isTrue);
      expect(result.contains('}'), isTrue);
    });
    test('9. Contains newlines', () {
      final String result = <String, dynamic>{'a': 1, 'b': 2}.formatMap();
      expect(result.contains('\n'), isTrue);
    });
    test('10. Contains indentation', () {
      final String result = <String, dynamic>{'a': 1}.formatMap();
      expect(result.contains('  '), isTrue);
    });
  });

  group('StringMapExtensions.getChildString', () {
    test(
      '1. Key exists',
      () => expect(<String, dynamic>{'name': 'John'}.getChildString('name'), 'John'),
    );
    test(
      '2. Key not exists',
      () => expect(<String, dynamic>{'name': 'John'}.getChildString('age'), isNull),
    );
    test(
      '3. Value is null',
      () => expect(<String, dynamic>{'name': null}.getChildString('name'), isNull),
    );
    test('4. Empty map', () => expect(<String, dynamic>{}.getChildString('key'), isNull));
    test(
      '5. Multiple keys',
      () => expect(<String, dynamic>{'a': 'A', 'b': 'B'}.getChildString('b'), 'B'),
    );
    test(
      '6. Empty string value',
      () => expect(<String, dynamic>{'name': ''}.getChildString('name'), ''),
    );
    test(
      '7. Whitespace key',
      () => expect(<String, dynamic>{' ': 'space'}.getChildString(' '), 'space'),
    );
    test(
      '8. Unicode value',
      () => expect(<String, dynamic>{'name': '你好'}.getChildString('name'), '你好'),
    );
    test(
      '9. Number key in string',
      () => expect(<String, dynamic>{'1': 'one'}.getChildString('1'), 'one'),
    );
    test(
      '10. Long string',
      () => expect(<String, dynamic>{'key': 'a' * 100}.getChildString('key'), 'a' * 100),
    );
  });

  group('StringMapExtensions.getGrandchild', () {
    test('1. Grandchild exists', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'parent': <String, dynamic>{'child': 'value'},
      };
      expect(map.getGrandchild('parent', 'child'), 'value');
    });
    test('2. Parent not exists', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'other': <String, dynamic>{'child': 'value'},
      };
      expect(map.getGrandchild('parent', 'child'), isNull);
    });
    test('3. Child not exists', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'parent': <String, dynamic>{'other': 'value'},
      };
      expect(map.getGrandchild('parent', 'child'), isNull);
    });
    test('4. Parent is null', () {
      final Map<String, dynamic> map = <String, dynamic>{'parent': null};
      expect(map.getGrandchild('parent', 'child'), isNull);
    });
    test('5. Nested int value', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'parent': <String, dynamic>{'child': 42},
      };
      expect(map.getGrandchild('parent', 'child'), 42);
    });
    test(
      '6. Empty map',
      () => expect(<String, dynamic>{}.getGrandchild('parent', 'child'), isNull),
    );
    test('7. Deeply nested', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 'deep'},
        },
      };
      expect(map.getGrandchild('a', 'b'), isNotNull);
    });
    test('8. List as grandchild', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'parent': <String, dynamic>{
          'child': <int>[1, 2],
        },
      };
      expect(map.getGrandchild('parent', 'child'), <int>[1, 2]);
    });
    test('9. Unicode keys', () {
      final Map<String, dynamic> map = <String, dynamic>{
        '你好': <String, dynamic>{'世界': 'value'},
      };
      expect(map.getGrandchild('你好', '世界'), 'value');
    });
    test('10. Bool value', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'parent': <String, dynamic>{'child': true},
      };
      expect(map.getGrandchild('parent', 'child'), true);
    });
  });

  group('StringMapExtensions.getValue', () {
    test('1. Nested map exists', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'nested': <String, dynamic>{'key': 'value'},
      };
      expect(map.getValue('nested'), <String, dynamic>{'key': 'value'});
    });
    test('2. Key not exists', () => expect(<String, dynamic>{'a': 1}.getValue('b'), isNull));
    test('3. Empty map', () => expect(<String, dynamic>{}.getValue('key'), isNull));
    test('4. Null key', () => expect(<String, dynamic>{'a': 1}.getValue(null), isNull));
    test(
      '5. Value is not map',
      () => expect(<String, dynamic>{'key': 'string'}.getValue('key'), isNull),
    );
    test('6. Value is null', () => expect(<String, dynamic>{'key': null}.getValue('key'), isNull));
    test('7. Deeply nested', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 1},
        },
      };
      expect(map.getValue('a')?.getValue('b'), <String, dynamic>{'c': 1});
    });
    test('8. Dynamic map converted', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'key': <dynamic, dynamic>{1: 'one'},
      };
      expect(map.getValue('key'), isNotNull);
    });
    test('9. Multiple nested maps', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': <String, dynamic>{'x': 1},
        'b': <String, dynamic>{'y': 2},
      };
      expect(map.getValue('b'), <String, dynamic>{'y': 2});
    });
    test('10. Empty nested map', () {
      final Map<String, dynamic> map = <String, dynamic>{'nested': <String, dynamic>{}};
      expect(map.getValue('nested'), <String, dynamic>{});
    });
  });

  group('StringMapExtensions.removeKeys', () {
    test('1. Remove single key', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1, 'b': 2, 'c': 3};
      map.removeKeys(<String>['b']);
      expect(map.containsKey('b'), isFalse);
    });
    test('2. Remove multiple keys', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1, 'b': 2, 'c': 3};
      map.removeKeys(<String>['a', 'c']);
      expect(map.keys, <String>['b']);
    });
    test('3. Remove non-existent key', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1};
      final bool result = map.removeKeys(<String>['x']);
      expect(result, isTrue);
      expect(map.length, 1);
    });
    test('4. Null list', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1};
      final bool result = map.removeKeys(null);
      expect(result, isFalse);
    });
    test('5. Empty list', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1};
      final bool result = map.removeKeys(<String>[]);
      expect(result, isFalse);
    });
    test('6. Recurse into nested', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': 1,
        'nested': <String, dynamic>{'a': 2, 'b': 3},
      };
      map.removeKeys(<String>['a']);
      expect(map.containsKey('a'), isFalse);
      expect((map['nested'] as Map<String, dynamic>).containsKey('a'), isFalse);
    });
    test('7. No recurse', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': 1,
        'nested': <String, dynamic>{'a': 2},
      };
      map.removeKeys(<String>['a'], recurseChildValues: false);
      expect(map.containsKey('a'), isFalse);
      expect((map['nested'] as Map<String, dynamic>).containsKey('a'), isTrue);
    });
    test('8. Empty map', () {
      final Map<String, dynamic> map = <String, dynamic>{};
      final bool result = map.removeKeys(<String>['a']);
      expect(result, isTrue);
    });
    test('9. All keys removed', () {
      final Map<String, dynamic> map = <String, dynamic>{'a': 1, 'b': 2};
      map.removeKeys(<String>['a', 'b']);
      expect(map.isEmpty, isTrue);
    });
    test('10. Deeply nested recurse', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'a': 1,
        'l1': <String, dynamic>{
          'a': 2,
          'l2': <String, dynamic>{'a': 3},
        },
      };
      map.removeKeys(<String>['a']);
      expect((map['l1'] as Map<String, dynamic>)['l2'], <String, dynamic>{});
    });
  });

  group('StringMapExtensions.toKeySorted', () {
    test('1. Already sorted', () {
      final Map<String, dynamic> result = <String, dynamic>{'a': 1, 'b': 2, 'c': 3}.toKeySorted();
      expect(result.keys.toList(), <String>['a', 'b', 'c']);
    });
    test('2. Reverse order', () {
      final Map<String, dynamic> result = <String, dynamic>{'c': 3, 'b': 2, 'a': 1}.toKeySorted();
      expect(result.keys.toList(), <String>['a', 'b', 'c']);
    });
    test('3. Random order', () {
      final Map<String, dynamic> result = <String, dynamic>{'b': 2, 'a': 1, 'c': 3}.toKeySorted();
      expect(result.keys.toList(), <String>['a', 'b', 'c']);
    });
    test('4. Empty map', () => expect(<String, dynamic>{}.toKeySorted(), <String, dynamic>{}));
    test('5. Single entry', () {
      final Map<String, dynamic> result = <String, dynamic>{'a': 1}.toKeySorted();
      expect(result.keys.toList(), <String>['a']);
    });
    test('6. Numeric string keys', () {
      final Map<String, dynamic> result = <String, dynamic>{
        '2': 'b',
        '1': 'a',
        '3': 'c',
      }.toKeySorted();
      expect(result.keys.toList(), <String>['1', '2', '3']);
    });
    test('7. Values preserved', () {
      final Map<String, dynamic> result = <String, dynamic>{'b': 2, 'a': 1}.toKeySorted();
      expect(result['a'], 1);
      expect(result['b'], 2);
    });
    test('8. Mixed case keys', () {
      final Map<String, dynamic> result = <String, dynamic>{'B': 2, 'a': 1, 'A': 3}.toKeySorted();
      expect(result.keys.toList()[0], 'A');
    });
    test('9. Unicode keys', () {
      final Map<String, dynamic> result = <String, dynamic>{'你': 1, 'a': 2}.toKeySorted();
      expect(result.keys.toList(), <String>['a', '你']);
    });
    test('10. Long keys', () {
      final Map<String, dynamic> result = <String, dynamic>{
        'beta': 2,
        'alpha': 1,
        'gamma': 3,
      }.toKeySorted();
      expect(result.keys.toList(), <String>['alpha', 'beta', 'gamma']);
    });
  });

  group('MapUtils.countItems', () {
    test('1. Multiple lists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1, 2],
        'b': <int>[3, 4, 5],
      };
      expect(MapUtils.countItems(map), 5);
    });
    test('2. Empty lists', () {
      final Map<String, List<int>> map = <String, List<int>>{'a': <int>[], 'b': <int>[]};
      expect(MapUtils.countItems(map), 0);
    });
    test('3. Single list', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1, 2, 3],
      };
      expect(MapUtils.countItems(map), 3);
    });
    test('4. Empty map', () {
      final Map<String, List<int>> map = <String, List<int>>{};
      expect(MapUtils.countItems(map), 0);
    });
    test('5. Mixed sizes', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
        'b': <int>[1, 2, 3],
        'c': <int>[],
      };
      expect(MapUtils.countItems(map), 4);
    });
    test('6. Set values', () {
      final Map<String, Set<int>> map = <String, Set<int>>{
        'a': <int>{1, 2},
        'b': <int>{3},
      };
      expect(MapUtils.countItems(map), 3);
    });
    test('7. Large lists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': List<int>.generate(100, (int i) => i),
      };
      expect(MapUtils.countItems(map), 100);
    });
    test('8. String lists', () {
      final Map<String, List<String>> map = <String, List<String>>{
        'a': <String>['x', 'y'],
        'b': <String>['z'],
      };
      expect(MapUtils.countItems(map), 3);
    });
    test('9. Single item lists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
        'b': <int>[2],
        'c': <int>[3],
      };
      expect(MapUtils.countItems(map), 3);
    });
    test('10. Int keys', () {
      final Map<int, List<String>> map = <int, List<String>>{
        1: <String>['a'],
        2: <String>['b', 'c'],
      };
      expect(MapUtils.countItems(map), 3);
    });
  });

  group('MapUtils.mapToggleValue', () {
    test('1. Add new value', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
      };
      MapUtils.mapToggleValue(map, 'a', 2);
      expect(map['a'], contains(2));
    });
    test('2. Remove existing value', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1, 2],
      };
      MapUtils.mapToggleValue(map, 'a', 2);
      expect(map['a'], isNot(contains(2)));
    });
    test('3. Add to new key', () {
      final Map<String, List<int>> map = <String, List<int>>{};
      MapUtils.mapToggleValue(map, 'a', 1);
      expect(map['a'], <int>[1]);
    });
    test('4. Force add', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
      };
      MapUtils.mapToggleValue(map, 'a', 1, add: true);
      expect(map['a']?.where((int e) => e == 1).length ?? 0, 2);
    });
    test('5. Force remove', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
      };
      MapUtils.mapToggleValue(map, 'a', 2, add: false);
      expect(map['a'], <int>[1]);
    });
    test('6. Toggle null value', () {
      final Map<String, List<int?>> map = <String, List<int?>>{
        'a': <int?>[1],
      };
      MapUtils.mapToggleValue(map, 'a', null);
      expect(map['a'], <int?>[1]);
    });
    test('7. String values', () {
      final Map<String, List<String>> map = <String, List<String>>{
        'a': <String>['x'],
      };
      MapUtils.mapToggleValue(map, 'a', 'y');
      expect(map['a'], contains('y'));
    });
    test('8. Int keys', () {
      final Map<int, List<String>> map = <int, List<String>>{
        1: <String>['a'],
      };
      MapUtils.mapToggleValue(map, 1, 'b');
      expect(map[1], contains('b'));
    });
    test('9. Remove from empty list', () {
      final Map<String, List<int>> map = <String, List<int>>{'a': <int>[]};
      MapUtils.mapToggleValue(map, 'a', 1, add: false);
      expect(map['a'], <int>[]);
    });
    test('10. Multiple toggles', () {
      final Map<String, List<int>> map = <String, List<int>>{'a': <int>[]};
      MapUtils.mapToggleValue(map, 'a', 1);
      MapUtils.mapToggleValue(map, 'a', 1);
      expect(map['a'], <int>[]);
    });
  });

  group('MapUtils.mapContainsValue', () {
    test('1. Value exists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1, 2, 3],
      };
      expect(MapUtils.mapContainsValue(map, 'a', 2), isTrue);
    });
    test('2. Value not exists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1, 2, 3],
      };
      expect(MapUtils.mapContainsValue(map, 'a', 5), isFalse);
    });
    test('3. Key not exists', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
      };
      expect(MapUtils.mapContainsValue(map, 'b', 1), isFalse);
    });
    test('4. Empty list', () {
      final Map<String, List<int>> map = <String, List<int>>{'a': <int>[]};
      expect(MapUtils.mapContainsValue(map, 'a', 1), isFalse);
    });
    test('5. Empty map', () {
      final Map<String, List<int>> map = <String, List<int>>{};
      expect(MapUtils.mapContainsValue(map, 'a', 1), isFalse);
    });
    test('6. Null value', () {
      final Map<String, List<int?>> map = <String, List<int?>>{
        'a': <int?>[1, null],
      };
      expect(MapUtils.mapContainsValue(map, 'a', null), isFalse);
    });
    test('7. String values', () {
      final Map<String, List<String>> map = <String, List<String>>{
        'a': <String>['x', 'y'],
      };
      expect(MapUtils.mapContainsValue(map, 'a', 'x'), isTrue);
    });
    test('8. Int keys', () {
      final Map<int, List<String>> map = <int, List<String>>{
        1: <String>['a', 'b'],
      };
      expect(MapUtils.mapContainsValue(map, 1, 'a'), isTrue);
    });
    test('9. Single value list', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
      };
      expect(MapUtils.mapContainsValue(map, 'a', 1), isTrue);
    });
    test('10. Multiple keys', () {
      final Map<String, List<int>> map = <String, List<int>>{
        'a': <int>[1],
        'b': <int>[2],
      };
      expect(MapUtils.mapContainsValue(map, 'b', 2), isTrue);
    });
    test('11. Missing input - empty map', () {
      final Map<String, List<String>> testMap = <String, List<String>>{};
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value'), false);
      expect(MapUtils.mapContainsValue(testMap, 'key', ''), false);
      expect(MapUtils.mapContainsValue(testMap, 'key', null), false);
      expect(MapUtils.mapContainsValue(testMap, null, 'value'), false);
      expect(MapUtils.mapContainsValue(testMap, '', 'value'), false);
    });
    test('12. Invalid input - empty or null key/value', () {
      final Map<String, List<String>> testMap = <String, List<String>>{};
      MapUtils.mapAddValue(testMap, 'key', 'value');
      expect(MapUtils.mapContainsValue(testMap, 'key', ''), false);
      expect(MapUtils.mapContainsValue(testMap, 'key', null), false);
      expect(MapUtils.mapContainsValue(testMap, '', 'value'), false);
      expect(MapUtils.mapContainsValue(testMap, null, 'value'), false);
    });
    test('13. Valid input with mapAddValue', () {
      final Map<String, List<String>> testMap = <String, List<String>>{};
      MapUtils.mapAddValue(testMap, 'key', 'value1');
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value1'), true);
      MapUtils.mapAddValue(testMap, 'key', 'value2');
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value1'), true);
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value2'), true);
    });
  });

  group('MapUtils.mapRemoveValue', () {
    test('1. Remove value from list', () {
      final Map<String, List<String>> testMap = <String, List<String>>{};
      MapUtils.mapAddValue(testMap, 'key', 'value1');
      MapUtils.mapAddValue(testMap, 'key', 'value2');
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value1'), true);
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value2'), true);

      MapUtils.mapRemoveValue(testMap, 'key', 'value1');
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value1'), false);
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value2'), true);

      MapUtils.mapRemoveValue(testMap, 'key', 'value2');
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value1'), false);
      expect(MapUtils.mapContainsValue(testMap, 'key', 'value2'), false);
    });
  });

  group('MapUtils.toMapStringDynamic', () {
    test('1. Already correct type', () {
      final Map<String, dynamic> input = <String, dynamic>{'a': 1};
      expect(MapUtils.toMapStringDynamic(input), same(input));
    });
    test('2. Dynamic map', () {
      final Map<dynamic, dynamic> input = <dynamic, dynamic>{'a': 1, 'b': 2};
      final Map<String, dynamic>? result = MapUtils.toMapStringDynamic(input);
      expect(result, <String, dynamic>{'a': 1, 'b': 2});
    });
    test('3. Int keys converted', () {
      final Map<dynamic, dynamic> input = <dynamic, dynamic>{1: 'one', 2: 'two'};
      final Map<String, dynamic>? result = MapUtils.toMapStringDynamic(input);
      expect(result, isNotNull);
      expect(result?['1'], 'one');
    });
    test('4. Null input', () => expect(MapUtils.toMapStringDynamic(null), isNull));
    test('5. Non-map input', () => expect(MapUtils.toMapStringDynamic('string'), isNull));
    test(
      '6. Empty map',
      () => expect(MapUtils.toMapStringDynamic(<dynamic, dynamic>{}), <String, dynamic>{}),
    );
    test('7. Ensure unique key with int keys', () {
      final Map<dynamic, dynamic> input = <dynamic, dynamic>{1: 'one', '1': 'string-one'};
      final Map<String, dynamic>? result = MapUtils.toMapStringDynamic(
        input,
        ensureUniqueKey: true,
      );
      expect(result, isNotNull);
      expect(result?['1'], isNotNull);
    });
    test('8. List input', () => expect(MapUtils.toMapStringDynamic(<int>[1, 2]), isNull));
    test('9. Nested map', () {
      final Map<dynamic, dynamic> input = <dynamic, dynamic>{
        'a': <String, dynamic>{'b': 1},
      };
      final Map<String, dynamic>? result = MapUtils.toMapStringDynamic(input);
      expect(result, isNotNull);
      expect(result?['a'], <String, dynamic>{'b': 1});
    });
    test('10. Number input', () => expect(MapUtils.toMapStringDynamic(42), isNull));
  });
}
