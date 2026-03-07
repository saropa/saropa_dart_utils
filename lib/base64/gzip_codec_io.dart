/// IO-based gzip implementation using `dart:io`.
import 'dart:io' as io;

/// Gzip-encodes [bytes] using `dart:io`.
List<int>? gzipEncode(List<int> bytes) => io.gzip.encode(bytes);

/// Gzip-decodes [bytes] using `dart:io`.
List<int>? gzipDecode(List<int> bytes) => io.gzip.decode(bytes);
