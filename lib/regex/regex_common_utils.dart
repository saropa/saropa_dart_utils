/// Common regex: email (simple), phone (digits), URL (loose). Roadmap #187–189.
/// Audited: 2026-06-12 11:26 EDT
RegExp get regexEmailSimple => RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

/// A loose phone-number pattern: 7 to 15 ASCII digits, with no separators or
/// country prefix. Anchored to match the whole string.
/// Audited: 2026-06-12 11:26 EDT
RegExp get regexPhoneDigits => RegExp(r'^\d{7,15}$');

/// A loose URL pattern matching an `http://` or `https://` scheme (case-
/// insensitive) followed by a run of non-whitespace, non-delimiter characters.
/// Not anchored, so it can find URLs embedded within larger text.
/// Audited: 2026-06-12 11:26 EDT
RegExp get regexUrlLoose => RegExp(
  r'https?://[^\s<>"{}|\\^`\[\]]+',
  caseSensitive: false,
);
