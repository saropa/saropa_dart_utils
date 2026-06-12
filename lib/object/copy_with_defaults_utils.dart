import 'package:saropa_dart_utils/map/map_deep_merge_extensions.dart';

/// Copy with defaults (merge with default object). Roadmap #200.
/// Audited: 2026-06-12 11:26 EDT
Map<String, dynamic> copyWithDefaults(
  Map<String, dynamic> source,
  Map<String, dynamic> defaults,
) => defaults.deepMerge(source);
