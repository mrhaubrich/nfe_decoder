import 'package:nfe_decoder/decoder/http_client.dart';
import 'package:test/test.dart';

void main() {
  final url =
      "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1";
  test('test http client redirected URL', () async {
    HTTPClient httpClient = HTTPClient();
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
    HTTPClient httpClient = HTTPClient();
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
