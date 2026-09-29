/// Validates the small set of QR-code endpoints supported by this package.
class URLStateExtractor {
  final String url;

  URLStateExtractor(this.url);

  static const Map<String, Set<String>> _routes = {
    'www.sefaz.rs.gov.br': {
      '/NFCE/NFCE-COM.aspx',
      '/ASP/AAE_ROOT/NFE/SAT-WEB-NFE-NFC_QRCODE_1.asp',
    },
    'dfe-portal.svrs.rs.gov.br': {'/Dfe/QrCodeNFce'},
  };

  /// Returns whether [uri] uses an explicitly supported HTTPS QR-code route.
  static bool isSupportedUri(Uri uri) {
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && uri.port != 443) ||
        uri.fragment.isNotEmpty) {
      return false;
    }

    final routes = _routes[uri.host.toLowerCase()];
    if (routes == null || !routes.contains(uri.path)) return false;
    final params = uri.queryParametersAll['p'];
    return params != null && params.length == 1 && params.single.isNotEmpty;
  }

  bool get hasNFE => url.contains('NFE');
  bool get hasNFCE => url.contains('NFCE');
  bool get hasNFC => url.contains('NFC');

  String extractState() {
    try {
      return isSupportedUri(Uri.parse(url)) ? 'RS' : 'UNKNOWN';
    } on FormatException {
      return 'UNKNOWN';
    }
  }
}
