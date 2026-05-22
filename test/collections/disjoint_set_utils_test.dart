import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/disjoint_set_utils.dart';

void main() {
  group('DisjointSetUtils', () {
    group('find', () {
      test('should return element itself for fresh singletons', () {
        final DisjointSetUtils ds = DisjointSetUtils(5);
        expect(ds.find(0), 0);
        expect(ds.find(4), 4);
      });

      test('should return shared root after union', () {
        final DisjointSetUtils ds = DisjointSetUtils(5)..union(0, 1);
        expect(ds.find(0), ds.find(1));
      });
    });

    group('union / connected', () {
      test('should report unconnected singletons as disjoint', () {
        final DisjointSetUtils ds = DisjointSetUtils(5);
        expect(ds.connected(0, 1), isFalse);
      });

      test('should connect two elements', () {
        final DisjointSetUtils ds = DisjointSetUtils(5)..union(0, 1);
        expect(ds.connected(0, 1), isTrue);
      });

      test('should be transitive across chained unions', () {
        final DisjointSetUtils ds = DisjointSetUtils(5)
          ..union(0, 1)
          ..union(1, 2);
        expect(ds.connected(0, 2), isTrue);
        expect(ds.connected(0, 3), isFalse);
      });

      test('should be a no-op when already in same set', () {
        final DisjointSetUtils ds = DisjointSetUtils(3)
          ..union(0, 1)
          ..union(0, 1);
        expect(ds.connected(0, 1), isTrue);
      });

      test('should merge two multi-element groups', () {
        final DisjointSetUtils ds = DisjointSetUtils(6)
          ..union(0, 1)
          ..union(2, 3)
          ..union(1, 2);
        expect(ds.connected(0, 3), isTrue);
        expect(ds.connected(0, 4), isFalse);
      });

      test('should keep an element connected to itself', () {
        final DisjointSetUtils ds = DisjointSetUtils(3);
        expect(ds.connected(2, 2), isTrue);
      });
    });

    group('toString', () {
      test('should report size', () {
        expect(DisjointSetUtils(7).toString(), 'DisjointSetUtils(size: 7)');
      });
    });
  });
}
