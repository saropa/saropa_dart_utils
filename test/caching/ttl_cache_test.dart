import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/ttl_cache.dart';

// TtlCache uses wall-clock DateTime.now() for expiry, which fake_async cannot
// advance, so the expiry tests use short real delays instead.
void main() {
  group('TtlCache', () {
    test('ttl getter reflects the configured duration', () {
      expect(TtlCache<String, int>(const Duration(minutes: 5)).ttl, const Duration(minutes: 5));
    });

    test('get returns a freshly stored value', () {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(minutes: 5))
        ..set('x', 1);
      expect(c.get('x'), 1);
    });

    test('get returns null for an absent key', () {
      expect(TtlCache<String, int>(const Duration(minutes: 5)).get('nope'), isNull);
    });

    test('returns null after the entry expires and purges it', () async {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(milliseconds: 20))
        ..set('x', 1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.get('x'), isNull); // expired
      expect(c.toString(), contains('length: 0')); // purged on read
    });

    test('returns the value while still within the TTL', () {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(seconds: 30))
        ..set('x', 1);
      expect(c.get('x'), 1);
    });

    test('re-setting a key refreshes its expiry', () async {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(milliseconds: 60))
        ..set('x', 1);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      c.set('x', 2); // refresh expiry to 60ms from now
      await Future<void>.delayed(
        const Duration(milliseconds: 40),
      ); // 80ms total, 40ms since refresh
      expect(c.get('x'), 2); // still valid because expiry was reset
    });

    test('clear removes all entries', () {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(minutes: 5))
        ..set('a', 1)
        ..set('b', 2)
        ..clear();
      expect(c.get('a'), isNull);
      expect(c.toString(), contains('length: 0'));
    });

    test('toString reports ttl and length', () {
      final TtlCache<String, int> c = TtlCache<String, int>(const Duration(seconds: 2))
        ..set('a', 1);
      expect(c.toString(), 'TtlCache(ttl: 0:00:02.000000, length: 1)');
    });
  });
}
