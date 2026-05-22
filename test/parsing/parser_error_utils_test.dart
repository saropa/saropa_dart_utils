import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/parser_error_utils.dart';

void main() {
  group('ParserErrorUtils', () {
    test('exposes message and null position by default', () {
      const ParserErrorUtils e = ParserErrorUtils('boom');
      expect(e.message, 'boom');
      expect(e.line, isNull);
      expect(e.column, isNull);
      expect(e.snippet, isNull);
    });

    test('exposes line, column, snippet when provided', () {
      const ParserErrorUtils e = ParserErrorUtils(
        'bad token',
        line: 3,
        column: 7,
        snippet: 'foo',
      );
      expect(e.message, 'bad token');
      expect(e.line, 3);
      expect(e.column, 7);
      expect(e.snippet, 'foo');
    });

    test('toString without position is the message', () {
      expect(const ParserErrorUtils('boom').toString(), 'boom');
    });

    test('toString with line and column formats position', () {
      expect(
        const ParserErrorUtils('bad', line: 2, column: 5).toString(),
        'Line 2, column 5: bad',
      );
    });

    test('toString with only line falls back to message', () {
      expect(const ParserErrorUtils('bad', line: 2).toString(), 'bad');
    });

    test('toString with only column falls back to message', () {
      expect(const ParserErrorUtils('bad', column: 5).toString(), 'bad');
    });
  });
}
