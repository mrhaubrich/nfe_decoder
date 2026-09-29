import 'package:nfe_decoder/decoder/url_state_extractor.dart';
import 'package:test/test.dart';

void main() {
  test('accepts only enumerated RS HTTPS QR-code variants', () {
    const supported = [
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=synthetic',
      'https://www.sefaz.rs.gov.br/ASP/AAE_ROOT/NFE/SAT-WEB-NFE-NFC_QRCODE_1.asp?p=synthetic',
      'https://dfe-portal.svrs.rs.gov.br/Dfe/QrCodeNFce?p=synthetic',
    ];
    for (final url in supported) {
      expect(URLStateExtractor(url).extractState(), 'RS');
    }
  });

  test('rejects spoofed, unsafe and unsupported URL variants', () {
    const rejected = [
      'http://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x',
      'https://www.sefaz.rs.gov.br.attacker.invalid/NFCE/NFCE-COM.aspx?p=x',
      'https://sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x',
      'https://user@www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x',
      'https://www.sefaz.rs.gov.br:8443/NFCE/NFCE-COM.aspx?p=x',
      'https://www.sefaz.rs.gov.br/other?p=x',
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx',
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=',
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x&p=y',
      'not a URL',
    ];
    for (final url in rejected) {
      expect(URLStateExtractor(url).extractState(), 'UNKNOWN', reason: url);
    }
  });
}
