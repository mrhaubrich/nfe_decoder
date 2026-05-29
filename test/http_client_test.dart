import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nfe_decoder/decoder/http_client.dart';
import 'package:test/test.dart';

void main() {
  const url =
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1';
  final redirectedUrl = Uri.parse(
    'https://dfe-portal.svrs.rs.gov.br/Dfe/QrCodeNFce?p=43220701132478002858651060002225181164409967%7C2%7C1%7C2%7CB4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1',
  );

  test('test http client redirected URL', () async {
    final httpClient = HTTPClient(
      client: _FakeClient(
        body: '<html><body>NFC-e</body></html>',
        realUri: redirectedUrl,
      ),
    );
    final value = await httpClient.get(url);

    expect(value.body, isNotEmpty);

    expect(value.realUri.host, 'dfe-portal.svrs.rs.gov.br');
    expect(value.realUri.path, '/Dfe/QrCodeNFce');
    expect(
      value.realUri.queryParameters['p'],
      '43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1',
    );
  });

  test('test http client document', () async {
    final httpClient = HTTPClient(
      client: _FakeClient(
        body: '''
          <html>
            <body>
              <div>Header</div>
              <div>DOCUMENTO AUXILIAR DA NOTA FISCAL DE CONSUMIDOR ELETRÔNICA</div>
            </body>
          </html>
        ''',
        realUri: redirectedUrl,
      ),
    );
    final value = await httpClient.fetchDocumentFromLink(url);

    expect(value.body?.children, isNotNull);

    expect(value.body?.children, isNotEmpty);

    expect(value.body?.children, hasLength(greaterThanOrEqualTo(2)));

    expect(
      value.body?.text,
      contains('DOCUMENTO AUXILIAR DA NOTA FISCAL DE CONSUMIDOR ELETRÔNICA'),
    );
  });
}

class _FakeClient extends http.BaseClient {
  final String body;
  final Uri realUri;

  _FakeClient({required this.body, required this.realUri});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _FakeStreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: request,
      url: realUri,
      headers: {'content-type': 'text/html; charset=utf-8'},
    );
  }
}

class _FakeStreamedResponse extends http.StreamedResponse
    implements http.BaseResponseWithUrl {
  @override
  final Uri url;

  _FakeStreamedResponse(
    super.stream,
    super.statusCode, {
    required this.url,
    super.request,
    super.headers,
  });
}
