class URLStateExtractor {
  final String url;

  URLStateExtractor(this.url);

  bool get hasNFE => url.contains('NFE');
  bool get hasNFCE => url.contains('NFCE');
  bool get hasNFC => url.contains('NFC');

  String extractState() {
    Uri uri = Uri.parse(url);

    if (uri.host.contains('rs.gov.br') && (hasNFE || hasNFCE || hasNFC)) {
      return 'RS';
    }

    // Add more conditions for other states' URLs
    // ...

    return 'UNKNOWN';
  }
}
