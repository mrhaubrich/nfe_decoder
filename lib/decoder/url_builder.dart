// 1. URL Builder
class URLBuilder {
  final String base;

  URLBuilder(this.base);

  String getLink() {
    return base;
    // return base.replaceFirst(
    //     'NFCE/NFCE-COM.aspx', 'ASP/AAE_ROOT/NFE/SAT-WEB-NFE-NFC_QRCODE_1.asp');
  }

  String getNfeKey() => base.split('?p=')[1].split('|')[0];
}
