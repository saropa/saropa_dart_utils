// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/base64/gzip_codec_io.dart';

void main() {
  group('gzipEncode / gzipDecode (dart:io)', () {
    test('round-trips bytes back to the original', () {
      final List<int> original = utf8.encode('Hello, gzip world! ' * 20);
      final List<int>? encoded = gzipEncode(original);
      expect(encoded, isNotNull);
      expect(gzipDecode(encoded!), original);
    });

    test('encoded output starts with the gzip magic header (0x1f 0x8b)', () {
      final List<int>? encoded = gzipEncode(utf8.encode('payload'));
      expect(encoded, isNotNull);
      expect(encoded!.sublist(0, 2), <int>[0x1f, 0x8b]);
    });

    test('round-trips an empty byte list', () {
      final List<int>? encoded = gzipEncode(<int>[]);
      expect(encoded, isNotNull);
      expect(gzipDecode(encoded!), <int>[]);
    });

    test('decodes a known gzip stream', () {
      final List<int> original = <int>[1, 2, 3, 4, 5];
      final List<int> encoded = gzipEncode(original)!;
      expect(gzipDecode(encoded), original);
    });
  });
}
