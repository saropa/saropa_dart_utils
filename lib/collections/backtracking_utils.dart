/// Generic depth-first backtracking solver with pruning and result limits
/// (roadmap #486).
///
/// Backtracking explores a tree of partial states: from a state it generates
/// candidate [choices], [apply]s each to descend, prunes any branch whose
/// partial state fails [isValid] before recursing, and records a state that
/// passes [isComplete]. This is the engine behind constraint puzzles
/// (N-Queens, Sudoku), subset/permutation search, and exact-cover problems —
/// anything where "try, check, undo, try the next" beats enumerating the whole
/// space.
///
/// The solver is immutable and stateless between runs: every callback is pure
/// over the [State]/[Choice] types you supply, and a fresh [State] is produced
/// by [apply] rather than mutating in place, so the same solver can be reused.
library;

// The solver's function-typed fields (choices/apply/isComplete/isValid) are
// pure strategy callbacks — a candidate generator, a state transform, and two
// predicates — not UI event handlers, so the onXxx convention enforced by
// prefer_correct_callback_field_name would misname them. They are also public
// fields of a published API, so renaming would be a breaking change.
// ignore_for_file: prefer_correct_callback_field_name

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A reusable backtracking search over states of type [State] reached by
/// applying choices of type [Choice].
///
/// Example:
/// ```dart
/// // Subset-sum: find a subset of [nums] summing to [target].
/// final BacktrackingSolver<(int index, List<int> picked, int sum), int>
///     solver = BacktrackingSolver<(int, List<int>, int), int>(
///   choices: ((int, List<int>, int) s) => s.$1 < nums.length
///       ? <int>[0, 1] // skip or take the item at index s.$1
///       : <int>[],
///   apply: ((int, List<int>, int) s, int take) => take == 1
///       ? (s.$1 + 1, <int>[...s.$2, nums[s.$1]], s.$3 + nums[s.$1])
///       : (s.$1 + 1, s.$2, s.$3),
///   isValid: ((int, List<int>, int) s) => s.$3 <= target,
///   isComplete: ((int, List<int>, int) s) => s.$3 == target,
/// );
/// final (int, List<int>, int)? hit = solver.solveFirst((0, <int>[], 0));
/// ```
@immutable
class BacktrackingSolver<State, Choice> {
  /// Creates a solver from the four pure callbacks that define the search:
  ///
  /// - [choices]: candidate moves available from a state (empty = dead end).
  /// - [apply]: produces the new state reached by taking a choice.
  /// - [isComplete]: whether a state is a full, accepted solution.
  /// - [isValid]: whether a partial state is still worth exploring; returning
  ///   false prunes the whole branch before any deeper recursion.
  /// Audited: 2026-06-12 11:26 EDT
  const BacktrackingSolver({
    required this.choices,
    required this.apply,
    required this.isComplete,
    required this.isValid,
  });

  /// Candidate choices available from a given state.
  /// Audited: 2026-06-12 11:26 EDT
  final Iterable<Choice> Function(State) choices;

  /// The state reached by applying a choice to a state (no mutation).
  /// Audited: 2026-06-12 11:26 EDT
  final State Function(State, Choice) apply;

  /// Whether a state is a complete, accepted solution.
  /// Audited: 2026-06-12 11:26 EDT
  final bool Function(State) isComplete;

  /// Whether a partial state is still valid (worth descending into).
  /// Audited: 2026-06-12 11:26 EDT
  final bool Function(State) isValid;

  /// Returns the first complete solution reachable from [initial], or null if
  /// the search exhausts every valid branch without finding one.
  /// Audited: 2026-06-12 11:26 EDT
  State? solveFirst(State initial) {
    final List<State> found = _search(initial, 1);
    // _search caps at the requested limit, so at most one element is present;
    // firstOrNull yields that one solution or null on the no-solution case
    // without a throwing accessor.
    return found.firstOrNull;
  }

  /// Returns up to [limit] complete solutions reachable from [initial], in
  /// discovery (depth-first) order. A null [limit] collects every solution.
  /// Audited: 2026-06-12 11:26 EDT
  List<State> solveAll(State initial, {int? limit}) => _search(initial, limit);

  /// Depth-first walk collecting complete solutions until [limit] is reached.
  /// A null [limit] means unbounded. Pruning happens via [isValid] at the top
  /// of each visit, so invalid branches never spawn children.
  /// Audited: 2026-06-12 11:26 EDT
  List<State> _search(State initial, int? limit) {
    final List<State> solutions = <State>[];
    // The boolean result signals "limit reached" to unwind recursion; at the
    // top level there is nothing left to unwind, so it is intentionally read
    // into a throwaway rather than acted on.
    final bool _ = _visit(initial, limit, solutions);
    return solutions;
  }

  /// Recursive visitor; appends to [out] and stops descending once [out] holds
  /// [limit] solutions. Returns true once the limit is hit so callers unwind.
  /// Audited: 2026-06-12 11:26 EDT
  bool _visit(State state, int? limit, List<State> out) {
    // Prune first: an invalid partial state and its entire subtree are skipped.
    if (!isValid(state)) {
      return false;
    }
    // Record a complete state, then check whether the limit is now satisfied.
    if (isComplete(state)) {
      out.add(state);
      return limit != null && out.length >= limit;
    }
    // Descend into each child; bubble up the moment the limit is reached.
    for (final Choice choice in choices(state)) {
      if (_visit(apply(state, choice), limit, out)) {
        return true;
      }
    }
    return false;
  }
}
