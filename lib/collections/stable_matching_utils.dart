/// Stable matching via Gale-Shapley — roadmap #448.
///
/// Given two disjoint sides — proposers and acceptors — each ranking some or all
/// members of the other side, find a stable matching: a pairing in which no
/// proposer/acceptor pair would both prefer each other over their current
/// assignment. The classic application is matching applicants to positions.
///
/// This is the proposer-optimal Gale-Shapley algorithm: among ALL stable
/// matchings, every proposer gets the best acceptor it can have in any stable
/// matching (and, dually, every acceptor gets its worst). The algorithm always
/// terminates in a stable result.
///
/// Edge cases handled: unequal set sizes (extra members on either side stay
/// unmatched), incomplete preference lists (a party that does not list someone
/// prefers to stay unmatched rather than be paired with them), and the absence
/// of ties (preferences are strict — each list is a ranking with no duplicates).
/// Malformed input (a preference list referencing an unknown party, or a
/// duplicate within one list) throws [ArgumentError].
library;

/// Preference data for one stable-matching problem: each side maps a member to
/// its strict ranking (index 0 = most preferred) of the other side.
///
/// Grouping both maps in a record keeps [stableMatching] to a single argument and
/// makes the proposer/acceptor pairing explicit at the call site, avoiding two
/// loose positional maps that are easy to transpose.
///
/// Example:
/// ```dart
/// const prefs = StableMatchingPrefs(
///   proposers: {'a': ['x', 'y']},
///   acceptors: {'x': ['a'], 'y': ['a']},
/// );
/// ```
typedef StableMatchingPrefs = ({
  Map<String, List<String>> proposers,
  Map<String, List<String>> acceptors,
});

/// Computes a stable matching from [prefs], returning `proposer → acceptor` for
/// every matched proposer; unmatched proposers are absent from the map.
///
/// Proposer-optimal: each proposer receives the best partner it attains in any
/// stable matching. Incomplete lists mean a party may end unmatched rather than
/// pair with someone it did not rank. Throws [ArgumentError] when a preference
/// list names an unknown party or repeats a party (ties are disallowed).
///
/// Example:
/// ```dart
/// stableMatching((
///   proposers: {'a': ['x', 'y'], 'b': ['x', 'y']},
///   acceptors: {'x': ['a', 'b'], 'y': ['a', 'b']},
/// )); // {'a': 'x', 'b': 'y'}
/// ```
Map<String, String> stableMatching(StableMatchingPrefs prefs) {
  _validate(prefs);
  // Precompute each acceptor's rank map so it can compare two suitors in
  // constant time instead of re-scanning its preference list on every proposal.
  final Map<String, Map<String, int>> ranks = _acceptorRanks(prefs.acceptors);
  // matchOf maps acceptor → currently matched proposer (tentative until a better
  // suitor displaces it).
  final Map<String, String> matchOf = <String, String>{};
  // Free proposers still holding an index into their own preference list; each
  // proposer only ever moves DOWN its list, which bounds total proposals.
  final List<String> free = prefs.proposers.keys.toList();
  final Map<String, int> nextChoice = <String, int>{
    for (final String p in free) p: 0,
  };
  while (free.isNotEmpty) {
    final String proposer = free.removeLast();
    final List<String> choices = prefs.proposers[proposer] ?? const <String>[];
    _propose(proposer, choices, ranks, matchOf, nextChoice, free);
  }
  // Invert acceptor → proposer into the documented proposer → acceptor result.
  return <String, String>{
    for (final MapEntry<String, String> e in matchOf.entries) e.value: e.key,
  };
}

/// Advances [proposer] through its remaining choices, proposing to the first
/// acceptor that ranks it; on a successful displacement the ousted proposer is
/// pushed back onto [free] to propose again later.
void _propose(
  String proposer,
  List<String> choices,
  Map<String, Map<String, int>> ranks,
  Map<String, String> matchOf,
  Map<String, int> nextChoice,
  List<String> free,
) {
  // Walk down this proposer's list until it either gets (tentatively) matched or
  // exhausts its choices and stays unmatched. The index starts at the proposer's
  // last position so a re-freed proposer never re-asks an acceptor it already lost.
  int index = nextChoice[proposer] ?? 0;
  while (index < choices.length) {
    final String acceptor = choices[index];
    index++;
    nextChoice[proposer] = index;
    final Map<String, int> acceptorRanks = ranks[acceptor] ?? const <String, int>{};
    final int? suitorRank = acceptorRanks[proposer];
    // An acceptor that did not rank this proposer rejects it outright (incomplete
    // lists mean staying unmatched is preferred over an unranked partner).
    if (suitorRank == null) {
      continue;
    }
    if (_tryAccept(proposer, acceptor, suitorRank, acceptorRanks, matchOf, free)) {
      return;
    }
  }
}

/// Settles one proposal: accepts when [acceptor] is open or prefers [proposer]
/// over its current partner, displacing that partner; returns whether the
/// proposer ended up matched here.
bool _tryAccept(
  String proposer,
  String acceptor,
  int suitorRank,
  Map<String, int> acceptorRanks,
  Map<String, String> matchOf,
  List<String> free,
) {
  final String? current = matchOf[acceptor];
  // current was itself accepted earlier, so it is guaranteed present in this
  // acceptor's rank map; fall back to a sentinel only to keep the read null-safe.
  final int currentRank = current == null ? -1 : (acceptorRanks[current] ?? 1 << 30);
  // Lower rank index = more preferred; a free acceptor (current == null) accepts.
  if (current == null || suitorRank < currentRank) {
    matchOf[acceptor] = proposer;
    if (current != null) {
      free.add(current); // displaced proposer must seek a new match
    }
    return true;
  }
  return false;
}

/// Builds `acceptor → (proposer → rank index)` from each acceptor's ranking, so
/// preference comparisons during proposals are constant-time map reads.
Map<String, Map<String, int>> _acceptorRanks(Map<String, List<String>> acceptors) =>
    <String, Map<String, int>>{
      for (final MapEntry<String, List<String>> e in acceptors.entries)
        e.key: <String, int>{
          for (int i = 0; i < e.value.length; i++) e.value[i]: i,
        },
    };

/// Rejects malformed [prefs]: a list referencing a party absent from the other
/// side, or a duplicate entry within a single list (ties are disallowed).
void _validate(StableMatchingPrefs prefs) {
  _checkSide(prefs.proposers, prefs.acceptors.keys.toSet(), 'proposer');
  _checkSide(prefs.acceptors, prefs.proposers.keys.toSet(), 'acceptor');
}

/// Validates one [side]'s lists against the [known] members of the opposite
/// side, throwing on an unknown reference or an intra-list duplicate.
void _checkSide(Map<String, List<String>> side, Set<String> known, String label) {
  for (final MapEntry<String, List<String>> e in side.entries) {
    final Set<String> seen = <String>{};
    for (final String other in e.value) {
      if (!known.contains(other)) {
        throw ArgumentError('$label "${e.key}" ranks unknown party "$other"');
      }
      if (!seen.add(other)) {
        throw ArgumentError('$label "${e.key}" ranks "$other" more than once');
      }
    }
  }
}
