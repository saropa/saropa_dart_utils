# SPEC: `String.preventOrphans({int minWrapChars})` — for inclusion

**Status:** Proposed (harvested from Saropa Contacts)
**Proposed location:** `lib/string/string_wrap_extensions.dart` (or a new `string_typography_extensions.dart`)
**Portability:** Pure Dart, zero dependencies. No Flutter, no external packages.

> IMPORTANT: the non-breaking space is written as the Dart escape ` ` and
> the ellipsis as `…` ON PURPOSE. Do NOT substitute raw U+00A0 / U+2026
> characters — they flatten to ASCII in transit and silently break the contract
> under test. Keep the escapes.

---

## Purpose

Typography helper: replace a breaking space with a non-breaking space (` `)
wherever a line wrap at that space would strand a token shorter than
`minWrapChars` on its own line. Prevents an "orphan" word/punctuation (a lone
`…`, `I`, `(5)`, `the`) at the end — or middle — of a wrapped heading.
General-purpose: any text-rendering UI wants it.

The rule is symmetric and position-agnostic — "no segment shorter than N stands
alone" — which beats the common "last-space + short-tail" heuristic.

---

## Source (from Saropa Contacts; escapes preserved)

```dart
String preventOrphans({int minWrapChars = 4}) {
  if (length < 2) return this;
  final List<String> parts = split(' ');
  if (parts.length < 2) return this;
  final StringBuffer buf = StringBuffer(parts.first);
  for (int i = 1; i < parts.length; i++) {
    // Fuse when EITHER adjacent token fails the minimum (symmetric: an orphan
    // is bad whether it is left behind or pulled forward).
    final bool fuse =
        parts[i - 1].length < minWrapChars || parts[i].length < minWrapChars;
    buf
      ..write(fuse ? ' ' : ' ')
      ..write(parts[i]);
  }
  return buf.toString();
}
```

---

## Test cases (from Contacts; escapes preserved)

```dart
group('preventOrphans', () {
  test('ellipsis is glued to the preceding word', () {
    expect('Importing Demo Companions …'.preventOrphans(),
        'Importing Demo Companions …');
  });
  test('any short token in the middle is also glued', () {
    expect('Hello I am here'.preventOrphans(), 'Hello I am here');
  });
  test('long tokens on both sides keep a breakable space', () {
    expect('Importing Demo Companions'.preventOrphans(),
        'Importing Demo Companions');
  });
  test('single-letter sequence is fully fused', () {
    expect('A B C D'.preventOrphans(), 'A B C D');
  });
  test('trailing 1-char punctuation is always caught', () {
    expect('End of sentence .'.preventOrphans(),
        'End of sentence .');
  });
  test('short parenthesized count fuses with preceding word', () {
    expect('Results (5)'.preventOrphans(), 'Results (5)');
  });
  test('three-dot ellipsis is short enough to fuse', () {
    expect('Loading ...'.preventOrphans(), 'Loading ...');
  });
  test('string with no spaces is returned unchanged', () {
    expect('Singleword'.preventOrphans(), 'Singleword');
  });
  test('empty string is returned unchanged', () {
    expect(''.preventOrphans(), '');
  });
  test('custom minimum tunes aggressiveness', () {
    expect('fit the box'.preventOrphans(), 'fit the box');
    expect('fit the box'.preventOrphans(minWrapChars: 3), 'fit the box');
    expect('a of b content'.preventOrphans(minWrapChars: 2),
        'a of b content');
  });
});
```

---

## Bulletproofing gaps to add (for massive coverage)

- **Multiple consecutive spaces** — `split(' ')` yields empty tokens for `"a  b"`;
  an empty token has length 0 (< min) so it fuses. Decide + test the contract.
  Current impl splits only on a single ASCII space — `\t` / `\n` / ` ` are
  NOT split. Document, or generalize to `\s`.
- **Leading/trailing spaces** — `" a"` / `"a "` produce empty edge tokens; test.
- **`minWrapChars <= 0`** and very large values (no fuse / all fuse) — boundary.
- **Grapheme width** — `length` counts code units; a token of emoji/combining
  marks may be "short" by code units but visually wide. Note the limit.
- **Idempotency** — `x.preventOrphans().preventOrphans()` must equal once-applied.
