import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/csv_parse_utils.dart';
import 'package:saropa_dart_utils/parsing/csv_writer_utils.dart';

void main() {
  group('writeCsvLine', () {
    test('plain fields are not quoted', () {
      expect(writeCsvLine(<String>['a', 'b', 'c']), 'a,b,c');
    });

    test('quotes fields containing the delimiter', () {
      expect(writeCsvLine(<String>['a,b', 'c']), '"a,b",c');
    });

    test('doubles embedded quotes and wraps the field', () {
      expect(writeCsvLine(<String>['say "hi"']), '"say ""hi"""');
    });

    test('quotes fields with newlines or carriage returns', () {
      expect(writeCsvLine(<String>['line1\nline2']), '"line1\nline2"');
      expect(writeCsvLine(<String>['a\rb']), '"a\rb"');
    });

    test('forceQuote quotes every field', () {
      expect(writeCsvLine(<String>['a', 'b'], forceQuote: true), '"a","b"');
    });

    test('honors a custom delimiter (TSV)', () {
      expect(writeCsvLine(<String>['a', 'b'], delimiter: '\t'), 'a\tb');
      // A comma is safe in TSV and must NOT trigger quoting.
      expect(writeCsvLine(<String>['a,b'], delimiter: '\t'), 'a,b');
    });

    test('empty field stays empty', () {
      expect(writeCsvLine(<String>['', 'x']), ',x');
    });
  });

  group('writeCsv', () {
    test('joins rows with CRLF by default', () {
      expect(
        writeCsv(<List<String>>[
          <String>['h1', 'h2'],
          <String>['1', '2'],
        ]),
        'h1,h2\r\n1,2',
      );
    });

    test('honors a custom eol', () {
      expect(
        writeCsv(<List<String>>[
          <String>['a'],
          <String>['b'],
        ], eol: '\n'),
        'a\nb',
      );
    });

    test('empty rows yield empty string', () {
      expect(writeCsv(<List<String>>[]), '');
    });
  });

  group('round-trip with parseCsvLine', () {
    test('write then parse recovers the original fields', () {
      final List<String> original = <String>['a,b', 'say "hi"', 'plain', ''];
      final String line = writeCsvLine(original);
      expect(parseCsvLine(line), original);
    });
  });
}
