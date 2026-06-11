import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/ini_parser_utils.dart';

void main() {
  group('parseIni', () {
    test('should parse sections with key=value pairs', () {
      const String text = '[db]\nhost = localhost\nport = 5432\n[cache]\nttl = 60';

      final Map<String, Map<String, String>> result = parseIni(text);

      expect(result['db'], equals(<String, String>{'host': 'localhost', 'port': '5432'}));
      expect(result['cache'], equals(<String, String>{'ttl': '60'}));
    });

    test('should put pre-section entries under the global section', () {
      final Map<String, Map<String, String>> result = parseIni('name = top\n[s]\nk = v');

      expect(result[iniGlobalSection], equals(<String, String>{'name': 'top'}));
      expect(result['s'], equals(<String, String>{'k': 'v'}));
    });

    test('should skip blank lines and # / ; comments', () {
      const String text = '# header comment\n\n; another\n[s]\nk = v # not a comment';

      final Map<String, Map<String, String>> result = parseIni(text);

      // Inline `#` stays part of the value (no inline-comment stripping).
      expect(result['s'], equals(<String, String>{'k': 'v # not a comment'}));
    });

    test('should keep colons in values (first = is the separator)', () {
      final Map<String, Map<String, String>> result = parseIni('url = http://example.com:80');

      expect(result[iniGlobalSection]!['url'], equals('http://example.com:80'));
    });

    test('should create an empty map for a declared but empty section', () {
      final Map<String, Map<String, String>> result = parseIni('[empty]\n[full]\nk = v');

      expect(result['empty'], isEmpty);
      expect(result.containsKey('empty'), isTrue);
    });

    test('should let the last duplicate key win', () {
      final Map<String, Map<String, String>> result = parseIni('[s]\nk = 1\nk = 2');

      expect(result['s']!['k'], equals('2'));
    });

    test('should strip matching surrounding quotes', () {
      final Map<String, Map<String, String>> result = parseIni(
        '[s]\na = "  spaced  "\nb = \'lit\'',
      );

      expect(result['s']!['a'], equals('  spaced  '));
      expect(result['s']!['b'], equals('lit'));
    });

    test('should interpret escapes only inside double quotes', () {
      final Map<String, Map<String, String>> result = parseIni('[s]\nd = "a\\nb"\ns = \'a\\nb\'');

      expect(result['s']!['d'], equals('a\nb'));
      expect(result['s']!['s'], equals(r'a\nb'));
    });

    test('should throw FormatException on a line without =', () {
      expect(() => parseIni('[s]\nnonsense'), throwsFormatException);
    });

    test('should throw FormatException on an empty key', () {
      expect(() => parseIni('= value'), throwsFormatException);
    });

    test('should return an empty map for empty input', () {
      expect(parseIni(''), isEmpty);
    });

    test('should not strip export unless allowExport is set', () {
      final Map<String, Map<String, String>> result = parseIni('export KEY = v');

      expect(result[iniGlobalSection]!.containsKey('export KEY'), isTrue);
    });
  });

  group('parseEnv', () {
    test('should parse flat KEY=value lines', () {
      final Map<String, String> result = parseEnv('PORT=8080\nHOST=localhost');

      expect(result, equals(<String, String>{'PORT': '8080', 'HOST': 'localhost'}));
    });

    test('should strip the export prefix', () {
      final Map<String, String> result = parseEnv('export TOKEN=abc');

      expect(result['TOKEN'], equals('abc'));
    });

    test('should interpret double-quoted escapes', () {
      final Map<String, String> result = parseEnv(r'MSG="line1\nline2"');

      expect(result['MSG'], equals('line1\nline2'));
    });

    test('should tolerate CRLF line endings', () {
      final Map<String, String> result = parseEnv('A=1\r\nB=2\r\n');

      expect(result, equals(<String, String>{'A': '1', 'B': '2'}));
    });

    test('should flatten section headers rather than drop their keys', () {
      final Map<String, String> result = parseEnv('A=1\n[extra]\nB=2');

      expect(result, equals(<String, String>{'A': '1', 'B': '2'}));
    });

    test('should keep an empty value as empty string', () {
      final Map<String, String> result = parseEnv('EMPTY=');

      expect(result['EMPTY'], equals(''));
    });
  });
}
