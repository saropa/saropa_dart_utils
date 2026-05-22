import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/pii_detector_utils.dart';

void main() {
  group('detectPii', () {
    test('detects a lone email with exact span', () {
      expect(detectPii('a@b.com'), <(String, int, int)>[('email', 0, 7)]);
    });

    test('detects a lone phone with exact span', () {
      expect(detectPii('555-123-4567'), <(String, int, int)>[('phone', 0, 12)]);
    });

    test('detects phone with dot separators', () {
      final List<(String, int, int)> r = detectPii('555.123.4567');
      expect(r, hasLength(1));
      expect(r.first.$1, 'phone');
    });

    test('detects both email and phone, emails first', () {
      final List<(String, int, int)> r = detectPii('mail x@y.com call 555-123-4567');
      expect(r, hasLength(2));
      expect(r[0].$1, 'email');
      expect(r[1].$1, 'phone');
    });

    test('no PII yields empty list', () {
      expect(detectPii('just some plain words'), isEmpty);
    });

    test('empty string yields empty list', () {
      expect(detectPii(''), isEmpty);
    });

    test('detects multiple emails', () {
      final List<(String, int, int)> r = detectPii('a@b.com and c@d.org');
      expect(r.where(((String, int, int) m) => m.$1 == 'email'), hasLength(2));
    });

    test('email span points at the matched substring', () {
      final List<(String, int, int)> r = detectPii('hi a@b.com');
      final (String, int, int) email = r.firstWhere(((String, int, int) m) => m.$1 == 'email');
      expect(email.$2, 3);
      expect(email.$3, 10);
    });
  });
}
