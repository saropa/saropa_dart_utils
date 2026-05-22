import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/priority_map_utils.dart';

void main() {
  group('PriorityMapUtils', () {
    test('should start empty', () {
      final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>();
      expect(pm.isEmpty, isTrue);
      expect(pm.removeFirst(), isNull);
    });

    group('add / isEmpty', () {
      test('should become non-empty after add', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()..add(1, 'a');
        expect(pm.isEmpty, isFalse);
      });
    });

    group('removeFirst', () {
      test('should return items FIFO within the same priority', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()
          ..add(1, 'a')
          ..add(1, 'b');
        expect(pm.removeFirst(), 'a');
        expect(pm.removeFirst(), 'b');
      });

      test('should drain the first priority bucket before reporting empty', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()
          ..add(1, 'a')
          ..add(2, 'b');
        // Insertion-ordered map: priority 1 added first, drained first.
        expect(pm.removeFirst(), 'a');
        expect(pm.removeFirst(), 'b');
        expect(pm.removeFirst(), isNull);
      });

      test('should prune an emptied queue and report empty', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()..add(5, 'only');
        expect(pm.removeFirst(), 'only');
        expect(pm.isEmpty, isTrue);
      });

      test('should return null when empty', () {
        expect(PriorityMapUtils<int, String>().removeFirst(), isNull);
      });

      test('should allow re-adding to a previously drained priority', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()..add(1, 'a');
        pm.removeFirst();
        pm.add(1, 'b');
        expect(pm.removeFirst(), 'b');
      });
    });

    group('toString', () {
      test('should report the number of priority buckets', () {
        final PriorityMapUtils<int, String> pm = PriorityMapUtils<int, String>()
          ..add(1, 'a')
          ..add(2, 'b');
        expect(pm.toString(), 'PriorityMapUtils(priorities: 2)');
      });
    });
  });
}
