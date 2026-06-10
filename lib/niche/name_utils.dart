import 'package:collection/collection.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Abbreviate name, initials from name. Roadmap #216–217.
String abbreviateName(String name) {
  // Trim first so leading/trailing whitespace does not produce empty parts, then
  // split on any run of whitespace to tolerate double spaces / tabs between names.
  final List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  // A single token has no surname to keep, so return it whole rather than
  // abbreviating it to just an initial.
  if (parts.length == 1) return parts.firstOrNull ?? '';
  // Abbreviate as "F. Last": first initial of the first token, full last token.
  // substringSafe avoids a range error if the first token is somehow empty.
  final first = parts.firstOrNull;
  final last = parts.lastOrNull;
  if (first == null || last == null) return '';
  return '${first.substringSafe(0, 1)}. $last';
}

/// Returns the uppercase initials for [name].
///
/// Uses the first letter of the first and last whitespace-separated parts; a
/// single-word name yields one initial. Returns an empty string when [name]
/// has no usable parts.
///
/// Example:
/// ```dart
/// initialsFromName('Ada Lovelace'); // 'AL'
/// initialsFromName('Plato'); // 'P'
/// ```
String initialsFromName(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substringSafe(0, 1).toUpperCase();
  final first = parts.firstOrNull;
  final last = parts.lastOrNull;
  if (first == null || last == null) return '';
  return '${first.substringSafe(0, 1)}${last.substringSafe(0, 1)}'.toUpperCase();
}
