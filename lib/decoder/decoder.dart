import 'package:nfe_decoder/decoder/http_client.dart';
import 'package:nfe_decoder/decoder/url_builder.dart';
import 'package:nfe_decoder/decoder/url_state_extractor.dart';
import 'package:nfe_decoder/models/nfe.dart';
import 'package:nfe_decoder/scraper/base_scraper.dart';
import 'package:nfe_decoder/scraper/scraper_factory.dart';

/// The [Decoder] class is responsible for orchestrating the entire scraping process for an NFE.
///
/// It performs the following tasks in sequence:
/// 1. Constructs the actual URL to be scraped using the [URLBuilder].
/// 2. Fetches the HTML content of the constructed URL using the [HTTPClient].
/// 3. Determines the state from the provided URL using the [URLStateExtractor].
/// 4. Delegates the scraping process to the appropriate scraper via [ScraperFactory].
/// 5. Returns the scraped [NFE] object.
///
/// Example usage:
///
/// ```dart
/// var decoder = Decoder('some_nfe_url');
/// var nfe = await decoder.scrapeNfe();
/// print(nfe);
/// ```
///
/// Note: The URLs provided in the example at the bottom are typical NFE URLs from the RS state.
class Decoder {
  final URLBuilder urlBuilder;
  final HTTPClient httpClient;
  BaseScraper? scraper;

  /// Creates a [Decoder] instance with the given [url].
  ///
  /// Internally, it initializes the [URLBuilder] and [HTTPClient] to work with the given URL.
  Decoder(String url)
      : urlBuilder = URLBuilder(url),
        httpClient = HTTPClient();

  /// Initiates the NFE scraping process.
  ///
  /// Returns a [Future] that completes with the scraped [NFE] object.
  Future<NFE> scrapeNfe() async {
    final url = urlBuilder.getLink();
    final document = await httpClient.fetchDocumentFromLink(url);
    final state = URLStateExtractor(url).extractState();
    scraper = ScraperFactory.getScraper(state, document);

    return scraper!.getNfe()..url = url;
  }
}

// Sample URLs for reference:
// https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=43220792733559000491654410000128901000218276|2|1|1|01c42d461f722df6ecd81ff9d1fab770aa98b313
// https://www.sefaz.rs.gov.br/ASP/AAE_ROOT/NFE/SAT-WEB-NFE-NFC_QRCODE_1.asp?p=43220792733559000491654410000128901000218276%7C2%7C1%7C1%7C01c42d461f722df6ecd81ff9d1fab770aa98b313
