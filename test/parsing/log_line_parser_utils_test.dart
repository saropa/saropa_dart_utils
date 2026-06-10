import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/log_line_parser_utils.dart';

void main() {
  group('LogLineParser', () {
    group('apacheCommon', () {
      final LogLineParser parser = LogLineParser.apacheCommon();

      test('should parse a common-log line into named fields', () {
        const String line =
            '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326';

        final Map<String, String>? result = parser.parse(line);

        expect(result, isNotNull);
        expect(result!['host'], equals('127.0.0.1'));
        expect(result['user'], equals('frank'));
        expect(result['time'], equals('10/Oct/2000:13:55:36 -0700'));
        expect(result['request'], equals('GET /apache_pb.gif HTTP/1.0'));
        expect(result['status'], equals('200'));
        expect(result['size'], equals('2326'));
      });

      test('should expose its field names in order', () {
        expect(
          parser.fields,
          equals(<String>['host', 'ident', 'user', 'time', 'request', 'status', 'size']),
        );
      });

      test('should return null for a non-matching line', () {
        expect(parser.parse('not a log line'), isNull);
      });
    });

    group('apacheCombined / nginxCombined', () {
      test('should also capture referer and user-agent', () {
        const String line =
            '10.0.0.1 - - [12/Dec/2025:08:00:00 +0000] "POST /api HTTP/1.1" 201 15 '
            '"https://ref.example" "Mozilla/5.0 (X11)"';

        final Map<String, String>? result = LogLineParser.apacheCombined().parse(line);

        expect(result, isNotNull);
        expect(result!['referer'], equals('https://ref.example'));
        expect(result['userAgent'], equals('Mozilla/5.0 (X11)'));
        expect(result['status'], equals('201'));
      });

      test('nginxCombined should parse the same shape', () {
        const String line =
            '1.2.3.4 - - [01/Jan/2026:00:00:00 +0000] "GET / HTTP/2.0" 304 0 "-" "curl/8.0"';

        final Map<String, String>? result = LogLineParser.nginxCombined().parse(line);

        expect(result!['userAgent'], equals('curl/8.0'));
        expect(result['referer'], equals('-'));
      });
    });

    group('custom templates', () {
      test('should parse a custom template', () {
        final LogLineParser parser = LogLineParser('{level}: {message}');

        final Map<String, String>? result = parser.parse('ERROR: disk full');

        expect(result, equals(<String, String>{'level': 'ERROR', 'message': 'disk full'}));
      });

      test('should honor an explicit field pattern', () {
        // Constrain id to digits so the trailing word stays in `name`.
        final LogLineParser parser = LogLineParser(r'{id:\d+} {name}');

        expect(parser.parse('42 alice'), equals(<String, String>{'id': '42', 'name': 'alice'}));
        // A non-numeric id fails the \d+ constraint → no match.
        expect(parser.parse('x alice'), isNull);
      });

      test('should match a bracketed and quoted custom format', () {
        final LogLineParser parser = LogLineParser('[{ts}] <{tag}> "{msg}"');

        expect(
          parser.parse('[2026-01-01] <auth> "login ok"'),
          equals(<String, String>{'ts': '2026-01-01', 'tag': 'auth', 'msg': 'login ok'}),
        );
      });
    });
  });
}
