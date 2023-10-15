class URLStateExtractor {
  final String url;

  URLStateExtractor(this.url);

  String extractState() {
    Uri uri = Uri.parse(url);

    if (uri.host.contains('rs.gov.br')) {
      return 'RS';
    }

    // Add more conditions for other states' URLs
    // ...

    return 'UNKNOWN';
  }
}
