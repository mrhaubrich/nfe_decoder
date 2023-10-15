import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_item_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RSItemScraper -> test Gecepel', () {
    final html = '''<tr id="Item + 1">
	<td valign="top"><span class="txtTit">MINI PQJ TRIGELE KG</span><span class="RCod">
			(Código:
			5187
			)
		</span><br><span class="Rqtd"><strong>Qtde.:</strong>0,12</span><span class="RUN"><strong>UN:
			</strong>KG</span><span class="RvlUnit"><strong>Vl. Unit.:</strong>
			&nbsp;
			29,9</span></td>
	<td align="right" valign="top" class="txtTit noWrap">
		Vl. Total
		<br><span class="valor">3,59</span>
	</td>
</tr>''';

    final element = Element.html(html);
    final item = RSItemScraper(element).scrapeItem();

    test('should extract item description', () {
      expect(item.item.descricao, 'MINI PQJ TRIGELE KG');
    });

    test('should extract item code', () {
      expect(item.item.codigo, '5187');
    });

    test('should extract item unit', () {
      expect(item.item.unidade, 'KG');
    });

    test('should extract item quantity', () {
      expect(item.quantidade, 0.12);
    });

    test('should extract item unit value', () {
      expect(item.valorUnitario, 29.9);
    });

    test('should extract item total value', () {
      expect(item.valorTotal, 3.59);
    });
  });
}
