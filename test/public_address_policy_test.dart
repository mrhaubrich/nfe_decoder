import 'dart:io';

import 'package:nfe_decoder/decoder/public_address_policy.dart';
import 'package:test/test.dart';

void main() {
  test('rejects private, local, shared and reserved IPv4 addresses', () {
    for (final value in [
      '0.0.0.0',
      '10.1.2.3',
      '100.64.0.1',
      '127.0.0.1',
      '169.254.169.254',
      '172.16.0.1',
      '192.168.1.1',
      '198.18.0.1',
      '224.0.0.1',
    ]) {
      expect(isPublicAddress(InternetAddress(value)), isFalse, reason: value);
    }
  });

  test('rejects local and IPv4-mapped private IPv6 addresses', () {
    for (final value in [
      '::',
      '::1',
      'fc00::1',
      'fe80::1',
      '2001:db8::1',
      '2001:20::1',
      '2002:c000:0201::1',
      '3fff::1',
      '::8.8.8.8',
      '::ffff:192.168.1.1',
    ]) {
      expect(isPublicAddress(InternetAddress(value)), isFalse, reason: value);
    }
  });

  test('accepts public IPv4 and IPv6 addresses', () {
    for (final value in ['8.8.8.8', '2001:4860:4860::8888', '::ffff:8.8.8.8']) {
      expect(isPublicAddress(InternetAddress(value)), isTrue, reason: value);
    }
  });
}
