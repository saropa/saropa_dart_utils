import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/csv_parse_utils.dart';

void main() {
  group('parseCsvLine', () {
    test('simple fields', () => expect(parseCsvLine('a,b,c'), <String>['a', 'b', 'c']));

    test('quoted field with comma inside', () {
      expect(parseCsvLine('"a,b",c'), <String>['a,b', 'c']);
    });

    test('doubled quote becomes literal quote', () {
      expect(parseCsvLine('"a""b",c'), <String>['a"b', 'c']);
    });

    test('empty string yields single empty field', () {
      expect(parseCsvLine(''), <String>['']);
    });

    test('trailing comma yields trailing empty field', () {
      expect(parseCsvLine('a,'), <String>['a', '']);
    });

    test('leading comma yields leading empty field', () {
      expect(parseCsvLine(',a'), <String>['', 'a']);
    });

    test('consecutive commas yield empty fields', () {
      expect(parseCsvLine('a,,b'), <String>['a', '', 'b']);
    });

    test('custom delimiter splits on it', () {
      expect(parseCsvLine('a;b;c', delimiter: ';'), <String>['a', 'b', 'c']);
    });

    test('custom delimiter ignores comma', () {
      expect(parseCsvLine('a,b;c', delimiter: ';'), <String>['a,b', 'c']);
    });

    test('single field no delimiter', () {
      expect(parseCsvLine('hello'), <String>['hello']);
    });

    test('quotes around whole field stripped', () {
      expect(parseCsvLine('"hello"'), <String>['hello']);
    });
  });
}
