import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/base_scraper.dart';
import 'package:nfe_decoder/scraper/rs/rs_scraper.dart';

class ScraperFactory {
  static final Map<String, Function> _scrapers = {
    'RS': (Document doc) => RSScraper(doc),
    // 'SP': (Document doc) => SPScraper(doc),
    // ... Add entries for other states
  };

  static BaseScraper getScraper(String state, Document document) {
    if (!_scrapers.containsKey(state)) {
      throw Exception('Scraper for state $state not implemented!');
    }
    return _scrapers[state]!(document);
  }
}
