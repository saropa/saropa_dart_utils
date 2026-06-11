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

  group('parseCsv (error-accumulating)', () {
    test('parses every row when all are valid', () {
      final CsvParseResult result = parseCsv('a,b,c\n1,2,3\n4,5,6');
      expect(result.rows, <List<String>>[
        <String>['a', 'b', 'c'],
        <String>['1', '2', '3'],
        <String>['4', '5', '6'],
      ]);
      expect(result.hasErrors, isFalse);
    });

    test('strips trailing CR from CRLF input', () {
      final CsvParseResult result = parseCsv('a,b\r\n1,2\r\n');
      expect(result.rows, <List<String>>[
        <String>['a', 'b'],
        <String>['1', '2'],
      ]);
      expect(result.errors, isEmpty);
    });

    test('skips blank lines without recording an error', () {
      final CsvParseResult result = parseCsv('a,b\n\n1,2\n');
      expect(result.rows, hasLength(2));
      expect(result.hasErrors, isFalse);
    });

    test('records an unterminated-quote error and continues', () {
      final CsvParseResult result = parseCsv('a,b\n"oops,b\n1,2');
      expect(result.rows, <List<String>>[
        <String>['a', 'b'],
        <String>['1', '2'],
      ]);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.lineNumber, 2);
      expect(result.errors.first.message, contains('unterminated quote'));
    });

    test('records a column-count mismatch against an explicit expectedColumns', () {
      final CsvParseResult result = parseCsv('1,2,3\n4,5\n6,7,8', expectedColumns: 3);
      expect(result.rows, <List<String>>[
        <String>['1', '2', '3'],
        <String>['6', '7', '8'],
      ]);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.lineNumber, 2);
      expect(result.errors.first.message, contains('expected 3 columns, found 2'));
    });

    test('uses the header row to set the expected width when hasHeader is true', () {
      final CsvParseResult result = parseCsv('id,name\n1,Alice\n2', hasHeader: true);
      // Header is kept as the first row.
      expect(result.rows.first, <String>['id', 'name']);
      expect(result.rows, hasLength(2));
      expect(result.errors, hasLength(1));
      expect(result.errors.first.lineNumber, 3);
    });

    test('runs only quote validation when no column count is known', () {
      // No expectedColumns, no header -> ragged rows are all accepted.
      final CsvParseResult result = parseCsv('1\n2,3\n4,5,6');
      expect(result.rows, hasLength(3));
      expect(result.hasErrors, isFalse);
    });
  });
}
