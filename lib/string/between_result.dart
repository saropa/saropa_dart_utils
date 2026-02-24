import 'package:meta/meta.dart';

/// Represents the result of extracting content between delimiters.
///
/// Contains the [content] found between the delimiters and the
/// [remaining] string after the delimiters are removed.
///
/// Example:
/// ```dart
/// final result = 'hello (world) test'.betweenResult('(', ')');
/// print(result?.content);   // 'world'
/// print(result?.remaining); // 'hello test'
/// ```
@immutable
// Manual == is simpler than adding equatable dependency for one class.
// ignore: require_extend_equatable
class BetweenResult {
  /// Creates a [BetweenResult] with the given [content] and [remaining].
  const BetweenResult(this.content, this.remaining);

  /// The content found between the delimiters.
  final String content;

  /// The remaining string after removing the delimited section.
  ///
  /// May be `null` when no content remains after the match (e.g. when
  /// the end delimiter is optional and not found).
  // remaining is genuinely null when endOptional triggers without a match.
  // ignore: avoid_unnecessary_nullable_fields
  final String? remaining;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetweenResult &&
          content == other.content &&
          remaining == other.remaining;

  @override
  int get hashCode => Object.hash(content, remaining);

  @override
  String toString() =>
      'BetweenResult($content, ${remaining ?? 'null'})';
}
