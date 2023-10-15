import 'package:html/dom.dart';
import 'package:nfe_decoder/models/nfe_item.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_item_scraper.dart';

class RSItemsScraper {
  final Element _element;

  RSItemsScraper(this._element);

  List<NfeItem> scrapeItems() {
    final itemElements = _element.querySelectorAll('tr');
    return itemElements
        .map((element) => RSItemScraper(element).scrapeItem())
        .toList();
  }
}
