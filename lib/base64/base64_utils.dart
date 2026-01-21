import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';

/// Utility class for Base64 encoding/decoding and text compression.
///
/// Provides methods to compress and decompress text using gzip and Base64 encoding,
/// which is useful for reducing payload sizes when transmitting or storing text data.
///
/// Example usage:
/// ```dart
/// final compressed = Base64Utils.compressText('Hello, World!');
/// final decompressed = Base64Utils.decompressText(compressed!);
/// print(decompressed); // 'Hello, World!'
/// ```
class Base64Utils {
  const Base64Utils._(); // Private constructor to prevent instantiation

  /// Compresses a string using gzip and encodes it as Base64.
  ///
  /// This method first encodes the input string to UTF-8, then compresses it
  /// using gzip, and finally encodes the compressed bytes as a Base64 string.
  ///
  /// Returns `null` if:
  /// - The input [value] is empty
  /// - An error occurs during compression
  ///
  /// Example:
  /// ```dart
  /// final compressed = Base64Utils.compressText('Hello, World!');
  /// // compressed is a Base64-encoded gzipped string
  /// ```
  ///
  /// See also:
  /// - [decompressText] to reverse this operation
  static String? compressText(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final List<int> encodedJson = utf8.encode(value);
      final List<int> gzipJson = io.gzip.encode(encodedJson);

      return base64.encode(gzipJson);
    } on Object catch (e, stackTrace) {
      // ignore: avoid_print_error - debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      debugPrint('Base64Utils.compressText failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Decompresses a Base64-encoded gzipped string back to its original form.
  ///
  /// This method reverses the [compressText] operation by:
  /// 1. Decoding the Base64 string to bytes
  /// 2. Decompressing the gzipped bytes
  /// 3. Decoding the UTF-8 bytes back to a string
  ///
  /// Returns `null` if:
  /// - The input [compressedBase64] is empty
  /// - The input is not valid Base64
  /// - The decoded data is not valid gzip
  /// - An error occurs during decompression
  ///
  /// Example:
  /// ```dart
  /// final original = Base64Utils.decompressText(compressedString);
  /// ```
  ///
  /// See also:
  /// - [compressText] to create compressed strings
  static String? decompressText(String? compressedBase64) {
    if (compressedBase64 == null || compressedBase64.isEmpty) {
      return null;
    }

    try {
      final Uint8List decodedBase64 = base64.decode(compressedBase64);
      final List<int> decodedGzip = io.gzip.decode(decodedBase64);

      return utf8.decode(decodedGzip);
    } on Object catch (e, stackTrace) {
      // ignore: avoid_print_error - debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      debugPrint('Base64Utils.decompressText failed: $e\n$stackTrace');
      return null;
    }
  }
}
