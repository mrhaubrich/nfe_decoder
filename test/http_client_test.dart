import 'package:nfe_decoder/decoder/http_client.dart';
import 'package:test/test.dart';

void main() {
  final url =
      "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1";
  test('test http client redirected URL', () {
    HTTPClient httpClient = HTTPClient();
    httpClient.get(url).then((value) {
      expect(value, isNotNull);

      expect(value, isNotEmpty);

      expect(value.realUri.toString(),
          "https://dfe-portal.svrs.rs.gov.br/Dfe/QrCodeNFce?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1");
    });
  });

  test('test http client document', () {
    HTTPClient httpClient = HTTPClient();
    httpClient.fetchDocumentFromLink(url).then((value) {
      expect(value, isNotNull);

      expect(value, isNotEmpty);

      expect(value.body?.children, isNotNull);

      expect(value.body?.children, isNotEmpty);

      expect(value.body?.children, hasLength(2));

      final selector =
          "body > div.ui-page.ui-page-theme-a.ui-page-active > div.ui-header.ui-bar-inherit > h1 > p:nth-child(2)";

      expect(value.querySelector(selector), isNotNull);

      expect(value.querySelector(selector)?.text, isNotEmpty);

      expect(value.querySelector(selector)?.text,
          "DOCUMENTO AUXILIAR DA NOTA FISCAL DE CONSUMIDOR ELETRÔNICA");
    });
  });
}
