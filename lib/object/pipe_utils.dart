/// Also/let style (pipe value through function). Roadmap #202.
library;

/// Runs [fn] for its side effects on [value] and returns [value] unchanged.
///
/// Mirrors Kotlin's `also` for inline configuration within an expression.
///
/// Example:
/// ```dart
/// final list = also(<int>[], (l) => l.add(1)); // [1]
/// ```
/// Audited: 2026-06-12 11:26 EDT
T also<T>(T value, void Function(T) fn) {
  fn(value);
  return value;
}

/// Applies [fn] to [value] and returns its result.
///
/// Mirrors Kotlin's `let` for transforming a value inline.
///
/// Example:
/// ```dart
/// let(5, (n) => n * 2); // 10
/// ```
/// Audited: 2026-06-12 11:26 EDT
R let<T, R>(T value, R Function(T) fn) => fn(value);
