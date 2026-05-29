import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

// 2. HTTP Client
class HTTPClient {
  final http.Client _client;

  HTTPClient({http.Client? client}) : _client = client ?? http.Client();

  Future<HTTPResponse> get(String url) async {
    final uri = Uri.parse(url);
    final request = http.Request('GET', uri);
    final streamedResponse = await _client.send(request);
    final realUri = switch (streamedResponse) {
      http.BaseResponseWithUrl(:final url) => url,
      _ => uri,
    };
    final response = await http.Response.fromStream(streamedResponse);

    return HTTPResponse(response: response, realUri: realUri);
  }

  Future<Document> fetchDocumentFromLink(String link) async {
    final response = await get(link);
    return parse(response.body);
  }
}

class HTTPResponse {
  final http.Response response;
  final Uri realUri;

  HTTPResponse({required this.response, required this.realUri});

  String get body => response.body;

  String get data => body;

  int get statusCode => response.statusCode;

  Map<String, String> get headers => response.headers;
}
