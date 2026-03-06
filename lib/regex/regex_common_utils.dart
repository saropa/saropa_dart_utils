/// Common regex: email (simple), phone (digits), URL (loose). Roadmap #187–189.
RegExp get regexEmailSimple => RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

RegExp get regexPhoneDigits => RegExp(r'^\d{7,15}$');

RegExp get regexUrlLoose => RegExp(
  r'https?://[^\s<>"{}|\\^`\[\]]+',
  caseSensitive: false,
);
