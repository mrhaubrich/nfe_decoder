import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_item_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_items_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RS identifier evidence', () {
    test('keeps missing and empty RCod as an empty legacy code', () {
      final missing = Element.html(_row(code: null));
      final empty = Element.html(_row(code: ''));

      expect(RSItemScraper(missing).scrapeItem().item.codigo, isEmpty);
      expect(RSItemScraper(empty).scrapeItem().item.codigo, isEmpty);
    });

    test('keeps a numeric-looking RCod as legacy retailer code only', () {
      final item = RSItemScraper(
        Element.html(_row(code: '123456')),
      ).scrapeItem();

      expect(item.item.codigo, '123456');
    });

    test('preserves repeated rows and source order', () {
      final html =
          '''
<table>
  ${_row(code: '123456', description: 'First')}
  ${_row(code: '123456', description: 'Second')}
</table>
''';

      final items = RSItemsScraper(Element.html(html)).scrapeItems();

      expect(items, hasLength(2));
      expect(items.map((item) => item.item.descricao), ['First', 'Second']);
      expect(items.map((item) => item.item.codigo), ['123456', '123456']);
    });

    test(
      'does not manufacture an item for unsupported or malformed layout',
      () {
        expect(
          RSItemsScraper(
            Element.html('<div>unsupported layout</div>'),
          ).scrapeItems(),
          isEmpty,
        );
        expect(
          RSItemsScraper(Element.html('<table><tr><td>broken')).scrapeItems(),
          hasLength(1),
        );
        expect(
          RSItemsScraper(
            Element.html('<table><tr><td>broken'),
          ).scrapeItems().single.item.codigo,
          isEmpty,
        );
      },
    );
  });
}

String _row({required String? code, String description = 'Synthetic item'}) {
  final codeMarkup = code == null
      ? ''
      : '<span class="RCod">(Código: $code)</span>';
  return '''
<tr>
  <td><span class="txtTit">$description</span>$codeMarkup
    <span class="Rqtd"><strong>Qtde.:</strong>1</span>
    <span class="RUN"><strong>UN:</strong>UN</span>
    <span class="RvlUnit"><strong>Vl. Unit.:</strong>1,00</span>
  </td>
  <td><span class="valor">1,00</span></td>
</tr>
''';
}
