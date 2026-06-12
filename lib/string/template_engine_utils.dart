/// Simple template engine: `{{key}}` substitution only, no eval — roadmap #413.
///
/// NOTE: despite the roadmap title, this performs plain placeholder
/// substitution; there are no conditionals or loops.
library;

/// Replaces {{key}} in [template] with values from [data]. Missing keys become empty.
/// Audited: 2026-06-12 11:26 EDT
String substituteTemplate(String template, Map<String, String> data) =>
    template.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (Match m) => data[m.group(1) ?? ''] ?? '');
