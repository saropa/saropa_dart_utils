import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/ip_cidr_utils.dart';

void main() {
  group('parseIpv4', () {
    test('standard address to big-endian int', () {
      expect(parseIpv4('192.168.0.1'), 0xC0A80001);
    });
    test('all zeros', () => expect(parseIpv4('0.0.0.0'), 0));
    test('broadcast all ones', () => expect(parseIpv4('255.255.255.255'), 0xFFFFFFFF));
    test('loopback', () => expect(parseIpv4('127.0.0.1'), 0x7F000001));
    test('octet over 255 returns null', () => expect(parseIpv4('256.0.0.1'), isNull));
    test('too few parts returns null', () => expect(parseIpv4('1.2.3'), isNull));
    test('too many parts returns null', () => expect(parseIpv4('1.2.3.4.5'), isNull));
    test('non-numeric octet returns null', () => expect(parseIpv4('1.2.x.4'), isNull));
    test('negative octet returns null', () => expect(parseIpv4('1.-2.3.4'), isNull));
    test('empty string returns null', () => expect(parseIpv4(''), isNull));
  });

  group('ipInCidr', () {
    final int net = parseIpv4('192.168.0.0')!;

    test('address inside /24 is contained', () {
      expect(ipInCidr(ip: parseIpv4('192.168.0.1')!, network: net, prefixLen: 24), isTrue);
    });
    test('address outside /24 is not contained', () {
      expect(ipInCidr(ip: parseIpv4('192.168.1.1')!, network: net, prefixLen: 24), isFalse);
    });
    test('prefix 0 contains everything', () {
      expect(ipInCidr(ip: parseIpv4('8.8.8.8')!, network: net, prefixLen: 0), isTrue);
    });
    test('prefix 32 requires exact match', () {
      expect(ipInCidr(ip: net, network: net, prefixLen: 32), isTrue);
      expect(ipInCidr(ip: parseIpv4('192.168.0.1')!, network: net, prefixLen: 32), isFalse);
    });
    test('prefix below 0 returns false', () {
      expect(ipInCidr(ip: net, network: net, prefixLen: -1), isFalse);
    });
    test('prefix above 32 returns false', () {
      expect(ipInCidr(ip: net, network: net, prefixLen: 33), isFalse);
    });
    test('/16 contains differing third octet', () {
      expect(ipInCidr(ip: parseIpv4('192.168.5.9')!, network: net, prefixLen: 16), isTrue);
    });
    test('/16 excludes differing second octet', () {
      expect(ipInCidr(ip: parseIpv4('192.169.0.1')!, network: net, prefixLen: 16), isFalse);
    });
  });
}
