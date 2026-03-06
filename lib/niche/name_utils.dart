import 'package:collection/collection.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Abbreviate name, initials from name. Roadmap #216–217.
String abbreviateName(String name) {
  final List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0];
  final first = parts.firstOrNull;
  final last = parts.lastOrNull;
  if (first == null || last == null) return '';
  return '${first.substringSafe(0, 1)}. $last';
}

String initialsFromName(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0].substringSafe(0, 1).toUpperCase();
  final first = parts.firstOrNull;
  final last = parts.lastOrNull;
  if (first == null || last == null) return '';
  return '${first.substringSafe(0, 1)}${last.substringSafe(0, 1)}'.toUpperCase();
}
