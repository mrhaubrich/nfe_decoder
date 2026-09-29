import 'dart:io';

/// Whether [address] is outside well-known non-public IPv4/IPv6 ranges.
bool isPublicAddress(InternetAddress address) {
  final bytes = address.rawAddress;
  if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
    return false;
  }

  if (address.type == InternetAddressType.IPv4) {
    return _isPublicIpv4(bytes);
  }

  // IPv4-mapped IPv6 addresses inherit the underlying IPv4 policy.
  final mappedIpv4 =
      bytes.length == 16 &&
      bytes.take(10).every((byte) => byte == 0) &&
      bytes[10] == 0xff &&
      bytes[11] == 0xff;
  if (mappedIpv4) return _isPublicIpv4(bytes.sublist(12));

  // Deprecated IPv4-compatible IPv6 addresses are never accepted.
  if (bytes.take(12).every((byte) => byte == 0)) return false;

  // Only global-unicast IPv6 (2000::/3) is eligible for outbound requests.
  if ((bytes[0] & 0xe0) != 0x20) return false;
  // Exclude protocol assignments, documentation, 6to4 and documentation-only
  // 3fff::/20, which are special-use despite falling in 2000::/3.
  if (bytes[0] == 0x20 && bytes[1] == 0x01) {
    final secondWord = (bytes[2] << 8) | bytes[3];
    if (secondWord <= 0x01ff || secondWord == 0x0db8) return false;
  }
  if (bytes[0] == 0x20 && bytes[1] == 0x02) return false;
  if (bytes[0] == 0x3f && (bytes[1] & 0xf0) == 0xf0) return false;

  return true;
}

bool _isPublicIpv4(List<int> bytes) {
  final first = bytes[0];
  final second = bytes[1];
  if (first == 0 || first == 10 || first == 127 || first >= 224) return false;
  if (first == 169 && second == 254) return false;
  if (first == 172 && second >= 16 && second <= 31) return false;
  if (first == 192 && second == 168) return false;
  if (first == 100 && second >= 64 && second <= 127) return false;
  if (first == 192 && second == 0) return false;
  if (first == 192 && second == 2) return false;
  if (first == 198 && (second == 18 || second == 19)) return false;
  if (first == 198 && second == 51 && bytes[2] == 100) return false;
  if (first == 203 && second == 0 && bytes[2] == 113) return false;
  return true;
}
