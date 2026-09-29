import 'http_client.dart';
import 'url_builder.dart';
import 'url_state_extractor.dart';
import '../models/nfe.dart';
import '../scraper/base_scraper.dart';
import '../scraper/scraper_factory.dart';

/// Orchestrates fetching and scraping a supported NFe/NFC-e page.
class Decoder {
  final URLBuilder urlBuilder;
  final HTTPClient httpClient;
  BaseScraper? scraper;

  /// Creates a decoder for the provided QR-code URL.
  Decoder(String url) : urlBuilder = URLBuilder(url), httpClient = HTTPClient();

  /// Fetches, identifies and parses the supported fiscal document.
  Future<NFE> scrapeNfe() async {
    final url = urlBuilder.getLink();
    final document = await httpClient.fetchDocumentFromLink(url);
    final state = URLStateExtractor(url).extractState();
    scraper = ScraperFactory.getScraper(state, document);

    return scraper!.getNfe()..url = url;
  }

  /// Releases the HTTP transport owned by this decoder.
  void close() => httpClient.close();

  /// Returns whether [url] is an explicitly supported fiscal QR-code URL.
  static bool isNfeUrl(String url) {
    return URLStateExtractor(url).extractState() != 'UNKNOWN';
  }
}
