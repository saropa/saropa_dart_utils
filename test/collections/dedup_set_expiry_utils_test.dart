import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/dedup_set_expiry_utils.dart';

void main() {
  group('DedupSetExpiryUtils', () {
    group('expiry getter', () {
      test('should expose the configured duration', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(minutes: 5));
        expect(set.expiry, const Duration(minutes: 5));
      });
    });

    group('add', () {
      test('should return true for a new key', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        expect(set.add('a'), isTrue);
      });

      test('should return false for a recently seen key', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        set.add('a');
        expect(set.add('a'), isFalse);
      });

      test('should treat distinct keys independently', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        expect(set.add('a'), isTrue);
        expect(set.add('b'), isTrue);
      });

      test('should re-add a key once enough time has elapsed past expiry', () {
        // A negative expiry makes the prune cutoff in the future, so any
        // previously added key is always "before" it and gets forgotten,
        // deterministically allowing re-add without sleeping the test.
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(seconds: -1));
        expect(set.add('a'), isTrue);
        expect(set.add('a'), isTrue);
      });
    });

    group('contains', () {
      test('should return true for an unexpired key', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        set.add('a');
        expect(set.contains('a'), isTrue);
      });

      test('should return false for a never-added key', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        expect(set.contains('missing'), isFalse);
      });

      test('should return false after expiry', () {
        // Negative expiry pushes the prune cutoff into the future, so the just
        // -added key is already expired by the time contains() prunes.
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(seconds: -1))..add('a');
        expect(set.contains('a'), isFalse);
      });
    });

    group('toString', () {
      test('should include expiry and seen count', () {
        final DedupSetExpiryUtils set = DedupSetExpiryUtils(const Duration(hours: 1));
        set.add('a');
        expect(set.toString(), contains('seen: 1'));
        expect(set.toString(), startsWith('DedupSetExpiryUtils(expiry:'));
      });
    });
  });
}
