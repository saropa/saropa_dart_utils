/// IO-based gzip implementation using `dart:io`.
library;

import 'dart:io' as io;

/// Gzip-encodes [bytes] using `dart:io`.
/// Audited: 2026-06-12 11:26 EDT
List<int>? gzipEncode(List<int> bytes) => io.gzip.encode(bytes);

/// Gzip-decodes [bytes] using `dart:io`.
/// Audited: 2026-06-12 11:26 EDT
List<int>? gzipDecode(List<int> bytes) => io.gzip.decode(bytes);
