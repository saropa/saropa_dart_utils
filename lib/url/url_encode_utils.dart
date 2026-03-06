/// URL encode/decode (component vs full). Safe decode. Roadmap #166, #171.
import 'dart:developer' as dev;

const String _kLogSafeDecodeUriFailed = 'safeDecodeUri failed';

String urlEncodeComponent(String value) => Uri.encodeComponent(value);

String urlDecodeComponent(String value) => Uri.decodeComponent(value);

String? safeDecodeUri(String value) {
  try {
    return Uri.decodeComponent(value);
  } catch (e, st) {
    dev.log(_kLogSafeDecodeUriFailed, error: e, stackTrace: st);
    return null;
  }
}
