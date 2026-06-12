/// Compact text serialization for adjacency-list graphs — roadmap #554.
///
/// Encodes a directed [Adjacency] graph as a single line of text and decodes it
/// back, with no dependency on `dart:convert` or any JSON library. The format
/// is deliberately compact and human-readable for logs, snapshots, and test
/// fixtures: each node is `index>neighbor,neighbor,...`, nodes are joined by
/// `;`, and a node with no out-edges is just its index. For example the graph
/// `0 -> 1, 0 -> 2, 2 -> 0` serializes to `0>1,2;1;2>0`.
///
/// The round trip is loss-free for any non-negative-indexed graph: neighbor
/// order within a node is preserved, and isolated trailing nodes survive
/// because every node index appears explicitly.
library;

import 'graph_utils.dart';

/// Serializes [graph] to the compact `index>n,n;index>n` text form.
///
/// Example:
/// ```dart
/// final Adjacency g = <List<int>>[<int>[1, 2], <int>[], <int>[0]];
/// serializeAdjacency(g); // '0>1,2;1;2>0'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String serializeAdjacency(Adjacency graph) => <String>[
  for (int i = 0; i < graph.length; i++)
    // Omit the '>' suffix entirely for nodes with no out-edges to stay compact.
    graph[i].isEmpty ? '$i' : '$i>${graph[i].join(',')}',
].join(';');

/// Parses the compact text form produced by [serializeAdjacency] back into an
/// [Adjacency] list sized to `maxNodeIndex + 1`.
///
/// An empty or whitespace-only string yields an empty graph. Malformed integer
/// tokens throw [FormatException]. Node entries may appear in any order; gaps
/// in the index range become isolated nodes.
///
/// Example:
/// ```dart
/// parseAdjacency('0>1,2;1;2>0'); // [[1, 2], [], [0]]
/// ```
/// Audited: 2026-06-12 11:26 EDT
Adjacency parseAdjacency(String text) {
  final String trimmed = text.trim();
  if (trimmed.isEmpty) return <List<int>>[];
  // First pass: parse each "index>neighbors" record into (index, neighbors).
  final List<(int, List<int>)> records = <(int, List<int>)>[
    for (final String part in trimmed.split(';'))
      if (part.isNotEmpty) _parseRecord(part),
  ];
  return _assemble(records);
}

// Parses one "index" or "index>n,n,n" record. Throws FormatException on a
// non-integer or negative index/neighbor.
(int, List<int>) _parseRecord(String part) {
  final int arrow = part.indexOf('>');
  if (arrow < 0) return (_parseIndex(part), <int>[]);
  final int node = _parseIndex(part.substring(0, arrow));
  final List<int> neighbors = <int>[
    for (final String n in part.substring(arrow + 1).split(','))
      if (n.isNotEmpty) _parseIndex(n),
  ];
  return (node, neighbors);
}

int _parseIndex(String token) {
  final int? value = int.tryParse(token.trim());
  if (value == null || value < 0) {
    throw FormatException('invalid node index', token);
  }
  return value;
}

// Builds the adjacency list, sizing it to hold the largest index seen.
Adjacency _assemble(List<(int, List<int>)> records) {
  int maxIndex = -1;
  for (final (int, List<int>) r in records) {
    if (r.$1 > maxIndex) maxIndex = r.$1;
  }
  final Adjacency graph = List<List<int>>.generate(maxIndex + 1, (_) => <int>[]);
  for (final (int, List<int>) r in records) {
    graph[r.$1] = r.$2;
  }
  return graph;
}
