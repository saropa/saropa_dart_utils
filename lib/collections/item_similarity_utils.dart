/// Co-occurrence item-to-item similarity recommender (roadmap #490).
///
/// Builds a "customers who bought X also bought Y" style model from baskets —
/// sets of items observed together (orders, sessions, playlists, co-edited
/// tags). Similarity between two items is the Jaccard overlap of the baskets
/// they appear in: items that keep showing up in the same baskets score high,
/// items that rarely co-occur score low. This is the lightweight, training-free
/// recommender used when you have transaction-style data but no ratings.
///
/// The model is immutable once built; [fromBaskets] indexes each item to the
/// set of basket ids it appeared in, and all queries read that index.
library;

import 'package:meta/meta.dart';

/// An immutable item-to-item similarity model over items of type [T], built
/// from co-occurrence baskets.
///
/// Example:
/// ```dart
/// final ItemSimilarityModel<String> model =
///     ItemSimilarityModel<String>.fromBaskets(<Set<String>>[
///   <String>{'bread', 'butter', 'jam'},
///   <String>{'bread', 'butter'},
///   <String>{'bread', 'jam'},
/// ]);
/// model.similarity('bread', 'butter'); // Jaccard of their basket sets
/// model.recommend('bread', topN: 2);   // most co-occurring items
/// ```
@immutable
class ItemSimilarityModel<T> {
  /// Private constructor; use [ItemSimilarityModel.fromBaskets].
  /// Audited: 2026-06-12 11:26 EDT
  const ItemSimilarityModel._(this._basketsByItem);

  /// Builds a model from [baskets], where each basket is the set of items seen
  /// together once. Duplicate items within a basket collapse to one membership
  /// (a basket is a set), and empty baskets contribute nothing.
  /// Audited: 2026-06-12 11:26 EDT
  factory ItemSimilarityModel.fromBaskets(Iterable<Iterable<T>> baskets) {
    // Map each item to the set of basket indices it appeared in. The index set
    // is the per-item signature Jaccard similarity is later computed over.
    final Map<T, Set<int>> basketsByItem = <T, Set<int>>{};
    int basketId = 0;
    for (final Iterable<T> basket in baskets) {
      // Deduplicate within the basket so an item counts once per basket.
      for (final T item in basket.toSet()) {
        basketsByItem.putIfAbsent(item, () => <int>{}).add(basketId);
      }
      basketId++;
    }
    return ItemSimilarityModel<T>._(basketsByItem);
  }

  /// For each item, the set of basket ids in which it appeared.
  final Map<T, Set<int>> _basketsByItem;

  /// Every distinct item the model knows about.
  /// Audited: 2026-06-12 11:26 EDT
  Set<T> get items => _basketsByItem.keys.toSet();

  /// Jaccard similarity between items [a] and [b]: the number of baskets
  /// containing both, divided by the number containing either. The result is
  /// symmetric and lies in `[0, 1]`. Returns 0 when either item is unknown or
  /// the two never co-occur; returns 1 for items with identical basket sets.
  /// Audited: 2026-06-12 11:26 EDT
  double similarity(T a, T b) {
    final Set<int>? setA = _basketsByItem[a];
    final Set<int>? setB = _basketsByItem[b];
    // An unknown item has no signature, so similarity is undefined → treat as 0.
    if (setA == null || setB == null) {
      return 0;
    }
    final int intersection = setA.intersection(setB).length;
    final int union = setA.union(setB).length;
    // Union is 0 only if both sets are empty, which fromBaskets never produces
    // (an item exists only because it appeared in at least one basket); guard
    // anyway so a degenerate construction can't divide by zero.
    if (union == 0) {
      return 0;
    }
    return intersection / union;
  }

  /// The items most similar to [item], highest score first, capped at [topN].
  ///
  /// The query [item] itself is excluded, as is any candidate scoring 0 (no
  /// co-occurrence). An unknown [item] yields an empty list. Ties keep the
  /// order in which candidates were first seen.
  /// Audited: 2026-06-12 11:26 EDT
  List<({T item, double score})> recommend(T item, {int topN = 10}) {
    // An unknown query has no neighbors; return early before scoring.
    if (!_basketsByItem.containsKey(item)) {
      return <({T item, double score})>[];
    }
    final List<({T item, double score})> scored = <({T item, double score})>[];
    // Score every other known item; drop zero-overlap candidates as noise.
    for (final T candidate in _basketsByItem.keys) {
      if (candidate == item) {
        continue;
      }
      final double score = similarity(item, candidate);
      if (score > 0) {
        scored.add((item: candidate, score: score));
      }
    }
    // Stable sort by descending score, then take the top N.
    scored.sort(
      (({T item, double score}) a, ({T item, double score}) b) => b.score.compareTo(a.score),
    );
    return scored.take(topN).toList();
  }
}
