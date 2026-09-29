import 'dart:io';

import 'package:http/io_client.dart';

import 'public_address_policy.dart';

IOClient createRequestClient() {
  final client = HttpClient();
  client.findProxy = (_) => 'DIRECT';
  client.connectionFactory = (uri, proxyHost, proxyPort) async {
    if (proxyHost != null || proxyPort != null) {
      throw const SocketException('Proxy connections are not supported');
    }
    final addresses = await InternetAddress.lookup(uri.host);
    if (addresses.isEmpty ||
        addresses.any((address) => !isPublicAddress(address))) {
      throw const SocketException('Destination address is not public');
    }
    return Socket.startConnect(addresses.first, uri.port);
  };
  return IOClient(client);
}
