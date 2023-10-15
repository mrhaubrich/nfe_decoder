import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

// 2. HTTP Client
class HTTPClient {
  Dio dio = Dio(BaseOptions(
    followRedirects: true,
  ));

  Future<Response> get(String url) async {
    return await dio.get(url);
  }

  Future<Document> fetchDocumentFromLink(String link) async {
    final response = await get(link);
    return parse(response.data);
  }
}
