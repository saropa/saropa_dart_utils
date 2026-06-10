# URI template expansion, RFC 6570 subset (roadmap #629)

Item 9 of the second "next 10" roadmap-utilities batch. Expands `{...}` expressions in a URI template against a variable map — how API clients build request URLs from a template.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/url/url_template_utils.dart` (`expandUriTemplate`), new test, barrel export, CHANGELOG entry.

**Design:** `expandUriTemplate` replaces each `{...}` via `replaceAllMapped`; literal text passes through. `_expandExpression` reads the leading operator (`+ # . / ; ? &` or default) into an `_Op` rules record (prefix char, separator, named flag, ifEmpty, allowReserved), splits the body on commas, expands each varspec, and joins with the operator's separator behind its prefix. `_expandSpec` parses `name` / `name:3` / `name*` via one regex (no substring slicing). Scalars go through `_expandString` (optional prefix truncation + encode + named formatting); lists through `_expandList` (explode → separator-joined, possibly `name=` each; else comma-joined). `_pctEncode` UTF-8 percent-encodes, keeping RFC 3986 unreserved chars and — for `+`/`#` — the reserved set.

**Scope boundary (documented):** Levels 1–3 plus prefix/explode modifiers. Map/associative values are out of scope; literal text is passed through without the minimal re-encoding the full spec applies. This covers the overwhelming majority of real API-client templates.

**Complements `UriPattern` (#630):** that matches concrete paths against a template (extraction); this builds concrete URLs from a template (expansion). Opposite directions, no overlap.

**Tests:** 18 cases across the levels — Level 1 (simple substitution + encoding, literal passthrough, undefined-drop, number/bool), Level 2 (`+` reserved, `#` fragment), Level 3 (`{x,y}` comma-join, `?` query, `&` continuation, `/` segments, `.` label, `;` path-style, empty-named-value per operator), and modifiers (`:3` prefix truncation, list comma-join, `*` explode under `?` and `/`, empty-list drop). All pass; `flutter analyze` clean.

**Reviewer notes:** two `substring` sites (operator-char strip, prefix truncation) carry `// ignore: avoid_string_substring` with bounds proofs; the varspec parse uses a regex to avoid further slicing. The IDE's `prefer_boolean_prefixes` Info on the `_Op.named` field is not in the project tier (`flutter analyze` clean). Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
