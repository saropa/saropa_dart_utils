# CSV writer (roadmap #622)

Item 2 of 10 in the user's "build the top 10 obvious roadmap utilities, run /finish after each" batch. Adds the missing inverse of the existing `parseCsvLine`: an RFC 4180 CSV/TSV encoder with auto-quoting.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/csv_writer_utils.dart` (`writeCsvLine`, `writeCsv`), new test `test/parsing/csv_writer_utils_test.dart`, barrel export, CODE_INDEX rows, CHANGELOG entry.

**Design:** `writeCsvLine(fields, {delimiter, forceQuote})` quotes a field only when it contains the delimiter, a `"`, CR, or LF — the characters that corrupt row structure — and doubles embedded quotes (RFC 4180). `forceQuote` quotes unconditionally for strict consumers. `writeCsv(rows, {delimiter, eol, forceQuote})` joins encoded lines with `eol` (CRLF default). Custom delimiter supports TSV; a comma inside a TSV field is correctly left unquoted.

**Tests:** 11 cases including plain/quoted/embedded-quote/newline/CR fields, forceQuote, custom delimiter (TSV with a safe comma), empty field, default CRLF join, custom eol, empty document, and a **round-trip** (`writeCsvLine` → `parseCsvLine` recovers the original fields). All pass; `flutter analyze` clean.

**Reviewer notes:** Pure functions, no state, no unsafe accessors. The quote-decision predicate is the only logic of note; the round-trip test pins correctness against the existing parser.

No bug archive — task did not close a bugs/*.md file.
