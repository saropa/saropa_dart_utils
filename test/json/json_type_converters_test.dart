import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_type_utils.dart';

void main() {
  group('toIntJson', () {
    test('passes through ints and truncates doubles', () {
      expect(JsonTypeUtils.toIntJson(5), 5);
      expect(JsonTypeUtils.toIntJson(5.9), 5);
    });

    test('parses numeric strings; null otherwise', () {
      expect(JsonTypeUtils.toIntJson('42'), 42);
      expect(JsonTypeUtils.toIntJson('x'), isNull);
      expect(JsonTypeUtils.toIntJson(null), isNull);
    });
  });

  group('toBoolJson', () {
    test('handles bools, 1, and "true"', () {
      expect(JsonTypeUtils.toBoolJson(true), isTrue);
      expect(JsonTypeUtils.toBoolJson(1), isTrue);
      expect(JsonTypeUtils.toBoolJson('true'), isTrue);
      expect(JsonTypeUtils.toBoolJson(0), isFalse);
    });

    test('case sensitivity controls "TRUE"', () {
      expect(JsonTypeUtils.toBoolJson('TRUE'), isFalse);
      expect(JsonTypeUtils.toBoolJson('TRUE', isCaseSensitive: false), isTrue);
    });

    test('null input is null', () {
      expect(JsonTypeUtils.toBoolJson(null), isNull);
    });
  });

  group('toDoubleJson', () {
    test('parses numbers and numeric strings', () {
      expect(JsonTypeUtils.toDoubleJson('1.5'), 1.5);
      expect(JsonTypeUtils.toDoubleJson(2), 2.0);
    });

    test('null for non-numeric or null', () {
      expect(JsonTypeUtils.toDoubleJson('x'), isNull);
      expect(JsonTypeUtils.toDoubleJson(null), isNull);
    });
  });

  group('toDateTimeJson', () {
    test('parses ISO strings', () {
      expect(JsonTypeUtils.toDateTimeJson('2026-06-15'), DateTime(2026, 6, 15));
    });

    test('treats ints as epoch milliseconds', () {
      expect(
        JsonTypeUtils.toDateTimeJson(0),
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });

    test('null for unparseable or null', () {
      expect(JsonTypeUtils.toDateTimeJson('nope'), isNull);
      expect(JsonTypeUtils.toDateTimeJson(null), isNull);
    });
  });

  group('toListMap', () {
    test('keeps only the map entries', () {
      final List<Map<String, dynamic>>? result = JsonTypeUtils.toListMap(<Object?>[
        <String, dynamic>{'a': 1},
        <String, dynamic>{'b': 2},
      ]);
      expect(result, hasLength(2));
      expect(result!.first['a'], 1);
    });

    test('null for null input or no maps', () {
      expect(JsonTypeUtils.toListMap(null), isNull);
      expect(JsonTypeUtils.toListMap(<Object?>[1, 'x']), isNull);
    });
  });
}
