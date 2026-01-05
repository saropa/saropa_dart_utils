import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/url_extensions.dart';

// cspell: disable
void main() {
  group('UriExtensions.removeQuery', () {
    test('1. Remove query and fragment', () {
      final Uri uri = Uri.parse('https://example.com/path?query=1#fragment');
      final Uri result = uri.removeQuery();
      expect(result.query, '');
      expect(result.fragment, '');
    });
    test('2. Keep fragment', () {
      final Uri uri = Uri.parse('https://example.com/path?query=1#fragment');
      final Uri result = uri.removeQuery(removeFragment: false);
      expect(result.query, '');
      expect(result.fragment, 'fragment');
    });
    test('3. No query to remove', () {
      final Uri uri = Uri.parse('https://example.com/path');
      final Uri result = uri.removeQuery();
      expect(result.path, '/path');
      expect(result.query, '');
    });
    test('4. Multiple query params', () {
      final Uri uri = Uri.parse('https://example.com?a=1&b=2&c=3');
      final Uri result = uri.removeQuery();
      expect(result.query, '');
    });
    test('5. Only fragment', () {
      final Uri uri = Uri.parse('https://example.com#section');
      final Uri result = uri.removeQuery();
      expect(result.fragment, '');
    });
    test('6. Path preserved', () {
      final Uri uri = Uri.parse('https://example.com/a/b/c?x=1');
      final Uri result = uri.removeQuery();
      expect(result.path, '/a/b/c');
    });
    test('7. Host preserved', () {
      final Uri uri = Uri.parse('https://example.com?x=1');
      final Uri result = uri.removeQuery();
      expect(result.host, 'example.com');
    });
    test('8. Scheme preserved', () {
      final Uri uri = Uri.parse('http://example.com?x=1');
      final Uri result = uri.removeQuery();
      expect(result.scheme, 'http');
    });
    test('9. Port preserved', () {
      final Uri uri = Uri.parse('https://example.com:8080?x=1');
      final Uri result = uri.removeQuery();
      expect(result.port, 8080);
    });
    test('10. Empty query', () {
      final Uri uri = Uri.parse('https://example.com/path?');
      final Uri result = uri.removeQuery();
      expect(result.query, '');
    });
  });

  group('UriExtensions.isImageUri', () {
    test(
      '1. PNG file',
      () => expect(Uri.parse('https://example.com/image.png').isImageUri, isTrue),
    );
    test(
      '2. JPG file',
      () => expect(Uri.parse('https://example.com/image.jpg').isImageUri, isTrue),
    );
    test(
      '3. JPEG file',
      () => expect(Uri.parse('https://example.com/image.jpeg').isImageUri, isTrue),
    );
    test(
      '4. GIF file',
      () => expect(Uri.parse('https://example.com/image.gif').isImageUri, isTrue),
    );
    test(
      '5. WEBP file',
      () => expect(Uri.parse('https://example.com/image.webp').isImageUri, isTrue),
    );
    test(
      '6. BMP file',
      () => expect(Uri.parse('https://example.com/image.bmp').isImageUri, isTrue),
    );
    test(
      '7. Non-image file',
      () => expect(Uri.parse('https://example.com/file.txt').isImageUri, isFalse),
    );
    test(
      '8. No extension',
      () => expect(Uri.parse('https://example.com/image').isImageUri, isFalse),
    );
    test('9. Empty path', () => expect(Uri.parse('https://example.com').isImageUri, isFalse));
    test(
      '10. Uppercase extension',
      () => expect(Uri.parse('https://example.com/image.PNG').isImageUri, isTrue),
    );
    test(
      '11. Mixed case',
      () => expect(Uri.parse('https://example.com/image.JpG').isImageUri, isTrue),
    );
    test(
      '12. Path with query',
      () => expect(Uri.parse('https://example.com/image.png?x=1').isImageUri, isTrue),
    );
    test(
      '13. Nested path',
      () => expect(Uri.parse('https://example.com/a/b/c/image.png').isImageUri, isTrue),
    );
    test(
      '14. PDF file',
      () => expect(Uri.parse('https://example.com/doc.pdf').isImageUri, isFalse),
    );
    test(
      '15. SVG file',
      () => expect(Uri.parse('https://example.com/image.svg').isImageUri, isFalse),
    );
  });

  group('UriExtensions.fileName', () {
    test(
      '1. Simple file',
      () => expect(Uri.parse('https://example.com/file.txt').fileName, 'file.txt'),
    );
    test(
      '2. Nested path',
      () => expect(Uri.parse('https://example.com/a/b/c/file.txt').fileName, 'file.txt'),
    );
    test('3. No file name', () => expect(Uri.parse('https://example.com/').fileName, isNull));
    test('4. Empty path', () => expect(Uri.parse('https://example.com').fileName, isNull));
    test(
      '5. File with query',
      () => expect(Uri.parse('https://example.com/file.txt?x=1').fileName, 'file.txt'),
    );
    test('6. Unicode file name', () {
      final String? result = Uri.parse('https://example.com/你好.txt').fileName;
      // Unicode may be URL-encoded
      expect(result, isNotNull);
      expect(result?.endsWith('.txt'), isTrue);
    });
    test(
      '7. No extension',
      () => expect(Uri.parse('https://example.com/filename').fileName, 'filename'),
    );
    test(
      '8. Hidden file',
      () => expect(Uri.parse('https://example.com/.hidden').fileName, '.hidden'),
    );
    test(
      '9. Multiple dots',
      () => expect(Uri.parse('https://example.com/file.name.txt').fileName, 'file.name.txt'),
    );
    test('10. Just slash', () => expect(Uri.parse('/').fileName, isNull));
  });

  group('UriExtensions.fileExtension', () {
    test(
      '1. TXT extension',
      () => expect(Uri.parse('https://example.com/file.txt').fileExtension, 'txt'),
    );
    test(
      '2. PNG extension',
      () => expect(Uri.parse('https://example.com/image.png').fileExtension, 'png'),
    );
    test(
      '3. No extension',
      () => expect(Uri.parse('https://example.com/file').fileExtension, isNull),
    );
    test('4. Empty path', () => expect(Uri.parse('https://example.com').fileExtension, isNull));
    test(
      '5. Uppercase extension',
      () => expect(Uri.parse('https://example.com/file.TXT').fileExtension, 'txt'),
    );
    test(
      '6. Multiple dots',
      () => expect(Uri.parse('https://example.com/file.name.txt').fileExtension, 'txt'),
    );
    test(
      '7. Hidden file',
      () => expect(Uri.parse('https://example.com/.hidden').fileExtension, 'hidden'),
    );
    test(
      '8. Dot at end',
      () => expect(Uri.parse('https://example.com/file.').fileExtension, isNull),
    );
    test(
      '9. Long extension',
      () => expect(Uri.parse('https://example.com/file.jpeg').fileExtension, 'jpeg'),
    );
    test(
      '10. Mixed case',
      () => expect(Uri.parse('https://example.com/file.JpEg').fileExtension, 'jpeg'),
    );
  });

  group('UriNullableExtensions.isUriNullOrEmpty', () {
    test('1. Null URI', () {
      const Uri? uri = null;
      expect(uri.isUriNullOrEmpty, isTrue);
    });
    test('2. Empty path', () {
      final Uri uri = Uri.parse('');
      expect(uri.isUriNullOrEmpty, isTrue);
    });
    test('3. Valid URI', () {
      final Uri uri = Uri.parse('https://example.com/path');
      expect(uri.isUriNullOrEmpty, isFalse);
    });
    test('4. Host only', () {
      final Uri uri = Uri.parse('https://example.com');
      expect(uri.isUriNullOrEmpty, isTrue);
    });
    test('5. Root path', () {
      final Uri uri = Uri.parse('https://example.com/');
      expect(uri.isUriNullOrEmpty, isFalse);
    });
    test('6. File path', () {
      final Uri uri = Uri.parse('file:///path/to/file');
      expect(uri.isUriNullOrEmpty, isFalse);
    });
    test('7. Query only', () {
      final Uri uri = Uri.parse('?query=1');
      expect(uri.isUriNullOrEmpty, isTrue);
    });
    test('8. Fragment only', () {
      final Uri uri = Uri.parse('#section');
      expect(uri.isUriNullOrEmpty, isTrue);
    });
    test('9. Relative path', () {
      final Uri uri = Uri.parse('/a/b/c');
      expect(uri.isUriNullOrEmpty, isFalse);
    });
    test('10. Single slash', () {
      final Uri uri = Uri.parse('/');
      expect(uri.isUriNullOrEmpty, isFalse);
    });
  });

  group('UriNullableExtensions.isNotUriNullOrEmpty', () {
    test('1. Null URI', () {
      const Uri? uri = null;
      expect(uri.isNotUriNullOrEmpty, isFalse);
    });
    test('2. Valid URI', () {
      final Uri uri = Uri.parse('https://example.com/path');
      expect(uri.isNotUriNullOrEmpty, isTrue);
    });
    test('3. Empty path', () {
      final Uri uri = Uri.parse('');
      expect(uri.isNotUriNullOrEmpty, isFalse);
    });
    test('4. With path', () {
      final Uri uri = Uri.parse('https://example.com/file.txt');
      expect(uri.isNotUriNullOrEmpty, isTrue);
    });
    test('5. Relative path', () {
      final Uri uri = Uri.parse('/path');
      expect(uri.isNotUriNullOrEmpty, isTrue);
    });
  });

  group('UrlUtils.tryParse', () {
    test('1. Valid URL', () => expect(UrlUtils.tryParse('https://example.com'), isNotNull));
    test('2. Null input', () => expect(UrlUtils.tryParse(null), isNull));
    test('3. Empty string', () => expect(UrlUtils.tryParse(''), isNull));
    test('4. Invalid URL', () => expect(UrlUtils.tryParse('not a url'), isNotNull));
    test('5. With path', () {
      final Uri? result = UrlUtils.tryParse('https://example.com/path');
      expect(result, isNotNull);
      expect(result?.path, '/path');
    });
    test('6. With query', () {
      final Uri? result = UrlUtils.tryParse('https://example.com?a=1');
      expect(result, isNotNull);
      expect(result?.query, 'a=1');
    });
    test('7. File URL', () {
      final Uri? result = UrlUtils.tryParse('file:///path/to/file');
      expect(result, isNotNull);
      expect(result?.scheme, 'file');
    });
    test('8. HTTP URL', () {
      final Uri? result = UrlUtils.tryParse('http://example.com');
      expect(result, isNotNull);
      expect(result?.scheme, 'http');
    });
    test('9. With port', () {
      final Uri? result = UrlUtils.tryParse('https://example.com:8080');
      expect(result, isNotNull);
      expect(result?.port, 8080);
    });
    test('10. Unicode URL', () {
      final Uri? result = UrlUtils.tryParse('https://example.com/你好');
      expect(result, isNotNull);
    });
  });

  group('UrlUtils.isValidUrl', () {
    test('1. Valid HTTPS', () => expect(UrlUtils.isValidUrl('https://example.com'), isTrue));
    test('2. Valid HTTP', () => expect(UrlUtils.isValidUrl('http://example.com'), isTrue));
    test('3. No scheme', () => expect(UrlUtils.isValidUrl('example.com'), isFalse));
    test('4. No host', () => expect(UrlUtils.isValidUrl('https://'), isFalse));
    test('5. Null input', () => expect(UrlUtils.isValidUrl(null), isFalse));
    test('6. Empty string', () => expect(UrlUtils.isValidUrl(''), isFalse));
    test(
      '7. File scheme',
      () => expect(UrlUtils.isValidUrl('file:///path'), isFalse),
    ); // File URLs have empty host
    test('8. FTP scheme', () => expect(UrlUtils.isValidUrl('ftp://example.com'), isTrue));
    test('9. With path', () => expect(UrlUtils.isValidUrl('https://example.com/path'), isTrue));
    test('10. With port', () => expect(UrlUtils.isValidUrl('https://example.com:8080'), isTrue));
    test('11. Localhost', () => expect(UrlUtils.isValidUrl('http://localhost'), isTrue));
    test('12. IP address', () => expect(UrlUtils.isValidUrl('http://192.168.1.1'), isTrue));
  });

  group('UrlUtils.isValidHttpUrl', () {
    test('1. Valid HTTPS', () => expect(UrlUtils.isValidHttpUrl('https://example.com'), isTrue));
    test('2. Valid HTTP', () => expect(UrlUtils.isValidHttpUrl('http://example.com'), isTrue));
    test('3. FTP scheme', () => expect(UrlUtils.isValidHttpUrl('ftp://example.com'), isFalse));
    test('4. File scheme', () => expect(UrlUtils.isValidHttpUrl('file:///path'), isFalse));
    test('5. No scheme', () => expect(UrlUtils.isValidHttpUrl('example.com'), isFalse));
    test('6. Null input', () => expect(UrlUtils.isValidHttpUrl(null), isFalse));
    test('7. Empty string', () => expect(UrlUtils.isValidHttpUrl(''), isFalse));
    test('8. No host', () => expect(UrlUtils.isValidHttpUrl('https://'), isFalse));
    test('9. With path', () => expect(UrlUtils.isValidHttpUrl('https://example.com/path'), isTrue));
    test('10. With port', () => expect(UrlUtils.isValidHttpUrl('http://localhost:3000'), isTrue));
    test('11. Localhost', () => expect(UrlUtils.isValidHttpUrl('http://localhost'), isTrue));
    test('12. IP address', () => expect(UrlUtils.isValidHttpUrl('http://127.0.0.1'), isTrue));
  });

  group('UrlUtils.extractDomain', () {
    test(
      '1. Simple domain',
      () => expect(UrlUtils.extractDomain('https://example.com'), 'example.com'),
    );
    test(
      '2. With path',
      () => expect(UrlUtils.extractDomain('https://example.com/path'), 'example.com'),
    );
    test(
      '3. Subdomain',
      () => expect(UrlUtils.extractDomain('https://www.example.com'), 'www.example.com'),
    );
    test('4. Null input', () => expect(UrlUtils.extractDomain(null), isNull));
    test('5. Empty string', () => expect(UrlUtils.extractDomain(''), isNull));
    test('6. Invalid URL', () => expect(UrlUtils.extractDomain('not a url'), isNull));
    test(
      '7. With port',
      () => expect(UrlUtils.extractDomain('https://example.com:8080'), 'example.com'),
    );
    test(
      '8. IP address',
      () => expect(UrlUtils.extractDomain('http://192.168.1.1'), '192.168.1.1'),
    );
    test('9. Localhost', () => expect(UrlUtils.extractDomain('http://localhost'), 'localhost'));
    test(
      '10. Complex subdomain',
      () => expect(UrlUtils.extractDomain('https://api.v2.example.com'), 'api.v2.example.com'),
    );
    test('11. No scheme', () => expect(UrlUtils.extractDomain('example.com'), isNull));
    test(
      '12. With query',
      () => expect(UrlUtils.extractDomain('https://example.com?a=1'), 'example.com'),
    );
  });

  group('UriExtensions.isSecure', () {
    test('1. HTTPS is secure', () => expect(Uri.parse('https://example.com').isSecure, isTrue));
    test('2. HTTP is not secure', () => expect(Uri.parse('http://example.com').isSecure, isFalse));
    test('3. HTTPS uppercase', () => expect(Uri.parse('HTTPS://example.com').isSecure, isTrue));
    test('4. FTP is not secure', () => expect(Uri.parse('ftp://example.com').isSecure, isFalse));
    test('5. File scheme not secure', () => expect(Uri.parse('file:///path').isSecure, isFalse));
    test('6. With path', () => expect(Uri.parse('https://example.com/path').isSecure, isTrue));
    test('7. With query', () => expect(Uri.parse('https://example.com?a=1').isSecure, isTrue));
    test('8. Mixed case scheme', () => expect(Uri.parse('HtTpS://example.com').isSecure, isTrue));
    test('9. HTTP with port', () => expect(Uri.parse('http://example.com:8080').isSecure, isFalse));
    test(
      '10. HTTPS with port',
      () => expect(Uri.parse('https://example.com:443').isSecure, isTrue),
    );
  });

  group('UriExtensions.addQueryParameter', () {
    test('1. Add to URI without query', () {
      final Uri result = Uri.parse('https://example.com').addQueryParameter('page', '1');
      expect(result.queryParameters['page'], '1');
    });
    test('2. Add to URI with existing query', () {
      final Uri result = Uri.parse('https://example.com?a=1').addQueryParameter('b', '2');
      expect(result.queryParameters['a'], '1');
      expect(result.queryParameters['b'], '2');
    });
    test('3. Update existing parameter', () {
      final Uri result = Uri.parse('https://example.com?page=1').addQueryParameter('page', '2');
      expect(result.queryParameters['page'], '2');
    });
    test('4. Remove with null value', () {
      final Uri result = Uri.parse('https://example.com?page=1').addQueryParameter('page', null);
      expect(result.queryParameters.containsKey('page'), isFalse);
    });
    test('5. Remove with empty value', () {
      final Uri result = Uri.parse('https://example.com?page=1').addQueryParameter('page', '');
      expect(result.queryParameters.containsKey('page'), isFalse);
    });
    test('6. Empty key returns same URI', () {
      final Uri original = Uri.parse('https://example.com');
      final Uri result = original.addQueryParameter('', 'value');
      expect(result.toString(), original.toString());
    });
    test('7. Special characters in value', () {
      final Uri result = Uri.parse('https://example.com').addQueryParameter('q', 'hello world');
      expect(result.queryParameters['q'], 'hello world');
    });
    test('8. Path preserved', () {
      final Uri result = Uri.parse('https://example.com/path').addQueryParameter('x', '1');
      expect(result.path, '/path');
    });
    test('9. Multiple params preserved', () {
      final Uri result = Uri.parse('https://example.com?a=1&b=2&c=3').addQueryParameter('d', '4');
      expect(result.queryParameters.length, 4);
    });
    test('10. Add to non-existent removes nothing', () {
      final Uri result = Uri.parse('https://example.com?a=1').addQueryParameter('b', null);
      expect(result.queryParameters['a'], '1');
    });
  });

  group('UriExtensions.hasQueryParameter', () {
    test(
      '1. Parameter exists',
      () => expect(Uri.parse('https://example.com?page=1').hasQueryParameter('page'), isTrue),
    );
    test(
      '2. Parameter does not exist',
      () => expect(Uri.parse('https://example.com?page=1').hasQueryParameter('limit'), isFalse),
    );
    test(
      '3. No query parameters',
      () => expect(Uri.parse('https://example.com').hasQueryParameter('page'), isFalse),
    );
    test(
      '4. Empty value parameter',
      () => expect(Uri.parse('https://example.com?flag=').hasQueryParameter('flag'), isTrue),
    );
    test('5. Multiple parameters', () {
      final Uri uri = Uri.parse('https://example.com?a=1&b=2&c=3');
      expect(uri.hasQueryParameter('b'), isTrue);
    });
    test(
      '6. Case sensitive',
      () => expect(Uri.parse('https://example.com?Page=1').hasQueryParameter('page'), isFalse),
    );
    test(
      '7. Special characters in key',
      () => expect(Uri.parse('https://example.com?my-key=1').hasQueryParameter('my-key'), isTrue),
    );
    test('8. Check after removal', () {
      final Uri uri = Uri.parse('https://example.com?a=1').addQueryParameter('a', null);
      expect(uri.hasQueryParameter('a'), isFalse);
    });
    test(
      '9. Numeric key',
      () => expect(Uri.parse('https://example.com?123=value').hasQueryParameter('123'), isTrue),
    );
  });

  group('UriExtensions.getQueryParameter', () {
    test(
      '1. Get existing parameter',
      () => expect(Uri.parse('https://example.com?page=1').getQueryParameter('page'), '1'),
    );
    test(
      '2. Non-existent returns null',
      () => expect(Uri.parse('https://example.com?page=1').getQueryParameter('limit'), isNull),
    );
    test(
      '3. No query returns null',
      () => expect(Uri.parse('https://example.com').getQueryParameter('page'), isNull),
    );
    test(
      '4. Empty value',
      () => expect(Uri.parse('https://example.com?flag=').getQueryParameter('flag'), ''),
    );
    test(
      '5. Value with spaces',
      () => expect(
        Uri.parse('https://example.com?q=hello%20world').getQueryParameter('q'),
        'hello world',
      ),
    );
    test('6. Multiple params get specific', () {
      final Uri uri = Uri.parse('https://example.com?a=1&b=2&c=3');
      expect(uri.getQueryParameter('b'), '2');
    });
    test(
      '7. Case sensitive key',
      () => expect(Uri.parse('https://example.com?Page=1').getQueryParameter('page'), isNull),
    );
    test(
      '8. Numeric value',
      () => expect(Uri.parse('https://example.com?count=42').getQueryParameter('count'), '42'),
    );
    test(
      '9. Special characters',
      () => expect(
        Uri.parse('https://example.com?email=test%40example.com').getQueryParameter('email'),
        'test@example.com',
      ),
    );
  });

  group('UriExtensions.replaceHost', () {
    test('1. Replace host', () {
      final Uri result = Uri.parse('https://example.com/path').replaceHost('newdomain.com');
      expect(result.host, 'newdomain.com');
    });
    test('2. Path preserved', () {
      final Uri result = Uri.parse('https://example.com/a/b/c').replaceHost('new.com');
      expect(result.path, '/a/b/c');
    });
    test('3. Query preserved', () {
      final Uri result = Uri.parse('https://example.com?a=1').replaceHost('new.com');
      expect(result.query, 'a=1');
    });
    test('4. Scheme preserved', () {
      final Uri result = Uri.parse('http://example.com').replaceHost('new.com');
      expect(result.scheme, 'http');
    });
    test('5. Port preserved', () {
      final Uri result = Uri.parse('https://example.com:8080').replaceHost('new.com');
      expect(result.port, 8080);
    });
    test('6. Empty host returns same', () {
      final Uri original = Uri.parse('https://example.com');
      final Uri result = original.replaceHost('');
      expect(result.toString(), original.toString());
    });
    test('7. Replace subdomain', () {
      final Uri result = Uri.parse('https://www.example.com').replaceHost('api.example.com');
      expect(result.host, 'api.example.com');
    });
    test('8. Replace with IP', () {
      final Uri result = Uri.parse('https://example.com').replaceHost('192.168.1.1');
      expect(result.host, '192.168.1.1');
    });
    test('9. Replace IP with domain', () {
      final Uri result = Uri.parse('https://192.168.1.1').replaceHost('example.com');
      expect(result.host, 'example.com');
    });
    test('10. Fragment preserved', () {
      final Uri result = Uri.parse('https://example.com#section').replaceHost('new.com');
      expect(result.fragment, 'section');
    });
  });
}
