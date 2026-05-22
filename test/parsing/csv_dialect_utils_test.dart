import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/csv_dialect_utils.dart';

void main() {
  group('CsvDialectUtils', () {
    test('constructor exposes delimiter and hasHeader', () {
      const CsvDialectUtils d = CsvDialectUtils(delimiter: ';', hasHeader: false);
      expect(d.delimiter, ';');
      expect(d.hasHeader, isFalse);
    });

    test('toString includes delimiter and hasHeader', () {
      const CsvDialectUtils d = CsvDialectUtils(delimiter: ',', hasHeader: true);
      expect(d.toString(), 'CsvDialectUtils(delimiter: ,, hasHeader: true)');
    });
  });

  group('detectCsvDialect', () {
    test('tab-delimited detected as tab', () {
      expect(detectCsvDialect('a\tb\tc').delimiter, '\t');
    });

    test('comma-delimited detected as comma', () {
      expect(detectCsvDialect('a,b,c').delimiter, ',');
    });

    test('tabs tie with commas resolves to tab', () {
      // One tab, one comma -> tabs >= commas -> tab.
      expect(detectCsvDialect('a\tb,c').delimiter, '\t');
    });

    test('more commas than tabs resolves to comma', () {
      expect(detectCsvDialect('a,b,c\td').delimiter, ',');
    });

    test(
      'empty sample yields comma delimiter',
      () {
        expect(detectCsvDialect('').delimiter, ',');
      },
    );

    test('only inspects first line', () {
      // First line has commas, second has tabs; first line wins.
      expect(detectCsvDialect('a,b\nc\td\te').delimiter, ',');
    });

    test('always reports hasHeader true', () {
      expect(detectCsvDialect('a,b,c').hasHeader, isTrue);
      expect(detectCsvDialect('').hasHeader, isTrue);
    });
  });
}
