import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/safe_parse_utils.dart';

void main() {
  group('ParseOk', () {
    test('exposes value', () => expect(ParseOk<int>(5).value, 5));
    test('valueOrNull returns value', () => expect(ParseOk<int>(5).valueOrNull, 5));
    test('toString includes value', () => expect(ParseOk<int>(5).toString(), 'ParseOk(value: 5)'));
    test('is a SafeParseUtils', () => expect(ParseOk<String>('x'), isA<SafeParseUtils<String>>()));
  });

  group('ParseErr', () {
    test('exposes message', () => expect(ParseErr<int>('boom').message, 'boom'));
    test('valueOrNull is null', () => expect(ParseErr<int>('boom').valueOrNull, isNull));
    test('details default to null', () => expect(ParseErr<int>('boom').details, isNull));
    test('details captured when provided', () {
      final StackTrace st = StackTrace.current;
      expect(ParseErr<int>('boom', st).details, st);
    });
    test('toString includes message', () {
      expect(ParseErr<int>('boom').toString(), 'ParseErr(message: boom)');
    });
  });

  group('safeParse', () {
    test('successful parse returns ParseOk with value', () {
      final SafeParseUtils<int> r = safeParse<int>(int.parse, '42');
      expect(r, isA<ParseOk<int>>());
      expect(r.valueOrNull, 42);
    });

    test('failing parse returns ParseErr', () {
      final SafeParseUtils<int> r = safeParse<int>(int.parse, 'not-a-number');
      expect(r, isA<ParseErr<int>>());
      expect(r.valueOrNull, isNull);
    });

    test('ParseErr message is the exception string', () {
      final SafeParseUtils<int> r = safeParse<int>(int.parse, 'abc');
      expect(r, isA<ParseErr<int>>());
      expect((r as ParseErr<int>).message, contains('FormatException'));
    });

    test('custom parse function with mapping', () {
      final SafeParseUtils<String> r = safeParse<String>(
        (String s) => s.toUpperCase(),
        'hi',
      );
      expect(r.valueOrNull, 'HI');
    });
  });
}
