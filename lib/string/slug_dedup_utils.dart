/// Slug deduplicator: append incremental suffixes based on taken slugs (roadmap #411).
library;

/// Returns a slug that is not in [takenSlugs].
/// If [baseSlug] is not in [takenSlugs], returns it as-is.
/// Otherwise tries [baseSlug]-1, [baseSlug]-2, ... until one is free.
String deduplicateSlug(String baseSlug, Set<String> takenSlugs) {
  final String trimmed = baseSlug.trim();
  if (trimmed.isEmpty) {
    int i = 1;
    while (takenSlugs.contains('-$i')) i++;
    return '-$i';
  }
  if (!takenSlugs.contains(trimmed)) return trimmed;
  int suffix = 1;
  while (takenSlugs.contains('$trimmed-$suffix')) {
    suffix++;
  }
  return '$trimmed-$suffix';
}
