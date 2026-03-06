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
bool isJwtStructure(String token) {
  final List<String> parts = token.split('.');
  return parts.length == _jwtPartCount &&
      parts.every((String p) => p.isNotEmpty && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(p));
}

/// Decodes payload (middle part) as JSON map; returns null if invalid.
Map<String, Object?>? jwtPayload(String token) {
  if (!isJwtStructure(token)) return null;
  try {
    final String payload = token.split('.')[_jwtPayloadPartIndex];
    final int padLen = _base64PaddingBlockSize - payload.length % _base64PaddingBlockSize;
    final String padded = payload + '=' * padLen;
    final Uint8List bytes = Uint8List.fromList(base64Url.decode(padded));
    final String json = String.fromCharCodes(bytes);
    final decoded = jsonDecode(json);
    if (decoded is! Map) return null;
    return Map<String, Object?>.from(decoded);
  } catch (e, st) {
    if (kDebugMode) log(_kLogJwtPayloadFailed, error: e, stackTrace: st);
    return null;
  }
}
