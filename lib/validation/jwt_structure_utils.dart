/// JWT structural checks (no crypto) — roadmap #688.
library;

import 'dart:convert';
import 'dart:developer' show log;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kDebugMode;

const int _jwtPartCount = 3;
const int _base64PaddingBlockSize = 4;
const int _jwtPayloadPartIndex = 1;
const String _kLogJwtPayloadFailed = 'jwtPayload failed';

/// Returns true if [token] looks like a JWT (three base64url parts separated by .).
/// Audited: 2026-06-12 11:26 EDT
bool isJwtStructure(String token) {
  final List<String> parts = token.split('.');
  return parts.length == _jwtPartCount &&
      parts.every((String p) => p.isNotEmpty && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(p));
}

/// Decodes payload (middle part) as JSON map; returns null if invalid.
/// Audited: 2026-06-12 11:26 EDT
Map<String, Object?>? jwtPayload(String token) {
  // Validate structure first so the index access below is safe: isJwtStructure
  // guarantees exactly three non-empty parts, making the [1] read on the split
  // result an established invariant rather than an unchecked subscript.
  if (!isJwtStructure(token)) return null;
  // Decoding can fail many ways (bad base64url, non-UTF8 bytes, malformed JSON,
  // a non-object payload); catch broadly and report null rather than throwing
  // into the caller, logging only in debug to aid diagnosis.
  try {
    final String payload = token.split('.')[_jwtPayloadPartIndex];
    // base64url omits '=' padding, but base64Url.decode requires the length to be
    // a multiple of four — restore the stripped padding before decoding. The
    // outer `% block` keeps this at 0 when the length is already aligned;
    // `block - 0` would otherwise append a spurious full '====' block, making
    // the decoder reject an otherwise-valid token.
    final int padLen =
        (_base64PaddingBlockSize - payload.length % _base64PaddingBlockSize) %
        _base64PaddingBlockSize;
    final String padded = payload + '=' * padLen;
    final Uint8List bytes = Uint8List.fromList(base64Url.decode(padded));
    // Decode the bytes as UTF-8, not raw code units: a claim value with any
    // multi-byte character would otherwise become mojibake. Malformed UTF-8
    // throws and is caught below as an invalid payload.
    final String json = utf8.decode(bytes);
    final decoded = jsonDecode(json);
    // A well-formed JWT payload is a JSON object; anything else (array, scalar)
    // is not a claims set.
    if (decoded is! Map) return null;
    return Map<String, Object?>.from(decoded);
  } on Object catch (e, st) {
    if (kDebugMode) log(_kLogJwtPayloadFailed, error: e, stackTrace: st);
    return null;
  }
}
