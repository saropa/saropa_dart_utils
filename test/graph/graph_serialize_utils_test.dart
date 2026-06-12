import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/graph_serialize_utils.dart';
import 'package:saropa_dart_utils/graph/graph_utils.dart';

void main() {
  group('serializeAdjacency', () {
    test('should encode nodes, neighbors, and empty nodes compactly', () {
      final Adjacency g = <List<int>>[
        <int>[1, 2],
        <int>[],
        <int>[0],
      ];

      expect(serializeAdjacency(g), equals('0>1,2;1;2>0'));
    });

    test('should encode an empty graph as the empty string', () {
      expect(serializeAdjacency(<List<int>>[]), equals(''));
    });

    test('should preserve neighbor order', () {
      final Adjacency g = <List<int>>[
        <int>[3, 1, 2],
      ];

      expect(serializeAdjacency(g), equals('0>3,1,2'));
    });
  });

  group('parseAdjacency', () {
    test('should decode the compact form', () {
      expect(
        parseAdjacency('0>1,2;1;2>0'),
        equals(<List<int>>[
          <int>[1, 2],
          <int>[],
          <int>[0],
        ]),
      );
    });

    test('should return an empty graph for empty or whitespace input', () {
      expect(parseAdjacency(''), isEmpty);
      expect(parseAdjacency('   '), isEmpty);
    });

    test('should size the graph to the largest index and fill gaps', () {
      // Only node 5 is mentioned; nodes 0..4 become isolated.
      final Adjacency g = parseAdjacency('5>0');

      expect(g.length, equals(6));
      expect(g[5], equals(<int>[0]));
      expect(g[2], isEmpty);
    });

    test('should accept records in any order', () {
      expect(
        parseAdjacency('2>0;0>1'),
        equals(<List<int>>[
          <int>[1],
          <int>[],
          <int>[0],
        ]),
      );
    });

    test('should throw on a non-integer token', () {
      expect(() => parseAdjacency('0>x'), throwsFormatException);
    });

    test('should throw on a negative index', () {
      expect(() => parseAdjacency('-1>0'), throwsFormatException);
    });
  });

  group('round trip', () {
    test('should be loss-free for a representative directed graph', () {
      final Adjacency original = <List<int>>[
        <int>[1, 2, 3],
        <int>[],
        <int>[0, 2],
        <int>[1],
        <int>[],
      ];

      expect(parseAdjacency(serializeAdjacency(original)), equals(original));
    });
  });
}
