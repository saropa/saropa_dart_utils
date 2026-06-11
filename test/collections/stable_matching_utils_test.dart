import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/stable_matching_utils.dart';

void main() {
  group('stableMatching', () {
    test('should match a single pair', () {
      final result = stableMatching((
        proposers: {
          'a': ['x'],
        },
        acceptors: {
          'x': ['a'],
        },
      ));
      expect(result, {'a': 'x'});
    });

    test('should return empty map when both sides are empty', () {
      final result = stableMatching((
        proposers: <String, List<String>>{},
        acceptors: <String, List<String>>{},
      ));
      expect(result, isEmpty);
    });

    test('should give each proposer its top non-conflicting choice', () {
      // a and b both rank x first, but only one can take it; the displaced
      // proposer falls to its second choice y.
      final result = stableMatching((
        proposers: {
          'a': ['x', 'y'],
          'b': ['x', 'y'],
        },
        acceptors: {
          'x': ['a', 'b'],
          'y': ['a', 'b'],
        },
      ));
      expect(result, {'a': 'x', 'b': 'y'});
    });

    test('should be proposer-optimal when sides disagree', () {
      // Each proposer prefers the OTHER acceptor than the one that prefers it.
      // Proposer-optimality means proposers get their first choices.
      final result = stableMatching((
        proposers: {
          'a': ['y', 'x'],
          'b': ['x', 'y'],
        },
        acceptors: {
          'x': ['a', 'b'],
          'y': ['b', 'a'],
        },
      ));
      expect(result, {'a': 'y', 'b': 'x'});
    });

    test('should leave extra proposers unmatched when acceptors run out', () {
      // Three proposers, one acceptor: x picks its most preferred (a); b and c
      // exhaust their single-entry lists and stay out of the map.
      final result = stableMatching((
        proposers: {
          'a': ['x'],
          'b': ['x'],
          'c': ['x'],
        },
        acceptors: {
          'x': ['a', 'b', 'c'],
        },
      ));
      expect(result, {'a': 'x'});
    });

    test('should leave extra acceptors unmatched when proposers run out', () {
      final result = stableMatching((
        proposers: {
          'a': ['x'],
        },
        acceptors: {
          'x': ['a'],
          'y': ['a'],
        },
      ));
      expect(result, {'a': 'x'});
    });

    test('should leave a proposer unmatched when no acceptor ranks it', () {
      // a is on nobody's list; an incomplete acceptor list means a stays single
      // rather than forcing an unwanted pairing.
      final result = stableMatching((
        proposers: {
          'a': ['x'],
          'b': ['x'],
        },
        acceptors: {
          'x': ['b'],
        },
      ));
      expect(result, {'b': 'x'});
    });

    test('should reject a proposer whose only choice does not rank it', () {
      final result = stableMatching((
        proposers: {
          'a': ['x'],
        },
        acceptors: {
          'x': <String>[],
        },
      ));
      expect(result, isEmpty);
    });

    test('should produce a stable matching with no blocking pair', () {
      // Classic 3x3 instance; verify stability directly rather than a fixed map.
      final prefs = (
        proposers: {
          'a': ['x', 'y', 'z'],
          'b': ['y', 'x', 'z'],
          'c': ['x', 'y', 'z'],
        },
        acceptors: {
          'x': ['b', 'a', 'c'],
          'y': ['a', 'b', 'c'],
          'z': ['a', 'b', 'c'],
        },
      );
      final result = stableMatching(prefs);
      expect(_hasBlockingPair(prefs, result), isFalse);
      expect(result, hasLength(3));
    });

    test('should handle Unicode and emoji party identifiers', () {
      final result = stableMatching((
        proposers: {
          '世界': ['🚀'],
        },
        acceptors: {
          '🚀': ['世界'],
        },
      ));
      expect(result, {'世界': '🚀'});
    });

    test('should throw when a proposer ranks an unknown acceptor', () {
      expect(
        () => stableMatching((
          proposers: {
            'a': ['ghost'],
          },
          acceptors: {
            'x': ['a'],
          },
        )),
        throwsArgumentError,
      );
    });

    test('should throw when an acceptor ranks an unknown proposer', () {
      expect(
        () => stableMatching((
          proposers: {
            'a': ['x'],
          },
          acceptors: {
            'x': ['phantom'],
          },
        )),
        throwsArgumentError,
      );
    });

    test('should throw when a preference list repeats a party (tie)', () {
      expect(
        () => stableMatching((
          proposers: {
            'a': ['x', 'x'],
          },
          acceptors: {
            'x': ['a'],
          },
        )),
        throwsArgumentError,
      );
    });
  });
}

/// Returns true if [matching] contains a blocking pair: a proposer and acceptor
/// that each prefer the other over their assigned partner (the definition of an
/// unstable matching). Used to assert stability independent of a fixed result.
bool _hasBlockingPair(StableMatchingPrefs prefs, Map<String, String> matching) {
  for (final MapEntry<String, List<String>> p in prefs.proposers.entries) {
    final String proposer = p.key;
    final String? partner = matching[proposer];
    for (final String acceptor in p.value) {
      // Only acceptors the proposer prefers over its current partner can block.
      if (partner == acceptor) {
        break;
      }
      if (_acceptorWouldSwitch(prefs, acceptor, proposer, matching)) {
        return true;
      }
    }
  }
  return false;
}

/// Whether [acceptor] ranks [proposer] and prefers it over whoever it is matched
/// to (or is currently unmatched), which would make the pair blocking.
bool _acceptorWouldSwitch(
  StableMatchingPrefs prefs,
  String acceptor,
  String proposer,
  Map<String, String> matching,
) {
  final List<String> ranking = prefs.acceptors[acceptor] ?? const <String>[];
  final int suitorRank = ranking.indexOf(proposer);
  if (suitorRank < 0) {
    return false;
  }
  final String? currentProposer = _proposerMatchedTo(acceptor, matching);
  if (currentProposer == null) {
    return true;
  }
  return suitorRank < ranking.indexOf(currentProposer);
}

/// Finds the proposer matched to [acceptor] in [matching], or null if none.
String? _proposerMatchedTo(String acceptor, Map<String, String> matching) {
  for (final MapEntry<String, String> e in matching.entries) {
    if (e.value == acceptor) {
      return e.key;
    }
  }
  return null;
}
