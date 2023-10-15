import 'package:test/test.dart';

void main() {
  test('build url', () {
    final url =
        "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1";
    expect(url,
        "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220701132478002858651060002225181164409967|2|1|2|B4C1CE5A575FDEEE31C85F0254A75E98E5E1EEC1");
  });
}
