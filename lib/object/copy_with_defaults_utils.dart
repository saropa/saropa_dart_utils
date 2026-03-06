import 'package:saropa_dart_utils/map/map_deep_merge_extensions.dart';

/// Copy with defaults (merge with default object). Roadmap #200.
Map<String, dynamic> copyWithDefaults(
  Map<String, dynamic> source,
  Map<String, dynamic> defaults,
) {
  return defaults.deepMerge(source);
}
