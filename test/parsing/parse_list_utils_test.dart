import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/parse_list_utils.dart';

void main() {
  group('parseListFromString', () {
    test('comma-separated split and trimmed', () {
      expect(parseListFromString('a, b ,c'), <String>['a', 'b', 'c']);
    });

    test('empty string yields empty list', () {
      expect(parseListFromString(''), <String>[]);
    });

    test('whitespace only yields empty list', () {
      expect(parseListFromString('   '), <String>[]);
    });

    test('blank segments dropped', () {
      expect(parseListFromString('a,,b'), <String>['a', 'b']);
    });

    test('custom delimiter', () {
      expect(parseListFromString('a;b;c', delimiter: ';'), <String>['a', 'b', 'c']);
    });

    test('JSON array of strings', () {
      expect(parseListFromString('["a","b","c"]'), <String>['a', 'b', 'c']);
    });

    test('JSON array preserves quoted commas', () {
      expect(parseListFromString('["a,b","c"]'), <String>['a,b', 'c']);
    });

    test('empty JSON array yields empty list', () {
      expect(parseListFromString('[]'), <String>[]);
    });

    test('JSON array with unquoted tokens', () {
      expect(parseListFromString('[1, 2, 3]'), <String>['1', '2', '3']);
    });

    test('JSON array with escaped quote inside string', () {
      expect(parseListFromString(r'["a\"b"]'), <String>['a"b']);
    });

    test('single value no delimiter', () {
      expect(parseListFromString('solo'), <String>['solo']);
    });
  });
}
