/// Simple template engine (conditionals, no eval) — roadmap #413.
library;

/// Replaces {{key}} in [template] with values from [data]. Missing keys become empty.
String substituteTemplate(String template, Map<String, String> data) =>
    template.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (Match m) => data[m.group(1) ?? ''] ?? '');
