# Template-driven log line parser (roadmap #631)

Item 10 (final) of the second "next 10" roadmap-utilities batch. Parses log lines against a `{field}` format template into a field map, with Apache/nginx presets.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/log_line_parser_utils.dart` (`LogLineParser`), new test, barrel export, CHANGELOG entry.

**Design:** `LogLineParser(template)` is a factory that compiles a format template into an anchored regex with one named group per `{field}` placeholder. `_compile` walks the placeholders, escaping the literal text between them (the delimiters) and emitting `(?<name>pattern)` — pattern defaults to lazy `.*?` (bounded by the following literal) or greedy `.*` for the final field, and a `{name:regex}` placeholder supplies an explicit pattern. `parse(line)` runs the regex and returns `field → value` (missing captures → empty string) or null on no match. Named factories `apacheCommon` / `apacheCombined` / `nginxCombined` carry the standard templates (nginx combined shares Apache combined's shape).

**Distinction from `UriPattern` (#630):** that matches URL *paths* by segment; this matches arbitrary log lines where brackets/quotes/spaces are the field delimiters. Related idea (template → named captures), different domain and bounding strategy.

**Tests:** 9 cases — apacheCommon full-line parse (host/user/time/request/status/size, including a request and bracketed time containing spaces), field-name ordering, non-match → null; apacheCombined referer + user-agent capture; nginxCombined same-shape parse (with `"-"` referer); custom `{level}: {message}` template; explicit `{id:\d+}` pattern (matches digits, rejects non-numeric); and a bracketed+quoted custom format. All pass; `flutter analyze` clean.

**Reviewer notes:** the two `substring` sites in `_compile` (literal-before-placeholder, trailing-literal) carry `// ignore: avoid_string_substring` with index proofs (`last <= m.start <= length`). No `late` — the factory computes the compiled `(RegExp, List<String>)` and passes it to a private constructor. Duplicate field names would make the regex throw (documented: names must be unique). The IDE's `prefer_cascade_over_chained` Info on the two trailing `buffer.write` calls is not in the project tier (`flutter analyze` clean). Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
