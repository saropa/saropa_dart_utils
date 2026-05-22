// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/base64/gzip_codec_stub.dart';

void main() {
  group('gzip stub (unsupported platforms)', () {
    test('gzipEncode returns null', () {
      expect(gzipEncode(<int>[1, 2, 3]), isNull);
    });

    test('gzipDecode returns null', () {
      expect(gzipDecode(<int>[1, 2, 3]), isNull);
    });

    test('gzipEncode returns null for empty input', () {
      expect(gzipEncode(<int>[]), isNull);
    });

    test('gzipDecode returns null for empty input', () {
      expect(gzipDecode(<int>[]), isNull);
    });
  });
}
