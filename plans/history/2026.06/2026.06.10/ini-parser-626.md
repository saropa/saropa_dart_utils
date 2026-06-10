# INI / `.env` configuration parser (roadmap #626)

Item 1 of the "next 10" roadmap-utilities batch (user: "build them all"). Adds a dependency-free reader for the two near-universal flat-config formats — INI (`[section]` + `key=value`) and dotenv (`KEY=value`) — which apps otherwise hand-roll repeatedly.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/ini_parser_utils.dart` (`parseIni`, `parseEnv`, `iniGlobalSection`), new test, barrel export, CHANGELOG entry.

**Design:** One core line walker (`parseIni`) backs both entry points. It trims each line, skips blanks and full-line `#`/`;` comments, opens a section on `[name]` (created eagerly so empty sections are observable), and otherwise splits on the **first** `=` — keeping colons in values (`url=http://host:80`). `parseEnv` flattens the sectioned result (normally just the global section) and strips a leading `export `, so a stray header in a `.env` file is never lossy. Quote handling: a matched surrounding pair is stripped; double-quoted values expand `\n \t \r \\ \"` via a small char map, single-quoted are literal (dotenv/POSIX convention). Inline `#` is intentionally NOT a comment, so passwords/URLs/hex colors survive unquoted.

**Strictness:** a non-comment, non-section line without `=`, or an empty key, throws `FormatException` with the original (untrimmed) line as context — config typos surface instead of silently vanishing.

**Reuse check:** `config_precedence_utils.mergeConfig` merges already-parsed maps (different concern); no existing parser covers INI/.env. `parser_error_utils.ParserErrorUtils` is positional/snippet-oriented; `FormatException` is the lighter fit here since the offending line is the whole context.

**Tests:** 18 cases — sectioned parse, global section, comments + inline-`#`-as-data, colon-in-value, empty-section preservation, duplicate-key-last-wins, quote stripping, double-vs-single escape semantics, FormatException on no-`=` and empty-key, empty input, export gating; `parseEnv` flat parse, export strip, escapes, CRLF, header flattening, empty value. All pass; `flutter analyze` clean.

**Reviewer notes:** two `avoid_string_substring` warnings resolved with `// ignore … -- <proof>` directives (both indices provably in bounds: bracket-confirmed header, length-≥2 quote pair). Functions all ≤20 lines, file ~190 lines (under the 200 limit).

No bug archive — task did not close a bugs/*.md file.
