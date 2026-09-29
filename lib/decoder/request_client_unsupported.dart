import 'package:http/http.dart' as http;

http.Client createRequestClient() => _UnsupportedRequestClient();

class _UnsupportedRequestClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnsupportedError(
      'Secure QR-code requests are unavailable on this platform',
    );
  }
}
