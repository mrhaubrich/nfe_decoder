import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_item_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_items_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RS identifier metadata', () {
    test('distinguishes an absent RCod from an empty RCod', () {
      final absent = RSItemScraper(
        Element.html(_row()),
      ).scrapeItem(sourceOrdinal: 7);
      final empty = RSItemScraper(
        Element.html(_row(codeMarkup: '<span class="RCod"> </span>')),
      ).scrapeItem(sourceOrdinal: 8);
      final labeledEmpty = RSItemScraper(
        Element.html(_row(codeMarkup: '<span class="RCod">(Código: )</span>')),
      ).scrapeItem(sourceOrdinal: 9);

      expect(absent.item.codigo, isEmpty);
      expect(absent.identifiers.single.presence, 'absent');
      expect(absent.identifiers.single.rawValue, isEmpty);
      expect(absent.sourceOrdinal, 7);
      expect(absent.sourceItemNumber, isNull);
      expect(absent.identifierContractVersion, 1);
      expect(absent.sourceMetadata['parser'], 'RSItemScraper');
      expect(absent.sourceMetadata['sourceOrdinalBasis'], 'rs-html-tr-order');

      final restored = absent.toMap();
      expect(restored['identifierContractVersion'], 1);
      expect(restored['sourceOrdinal'], 7);
      expect(restored['identifiers'], hasLength(1));

      expect(empty.item.codigo, isEmpty);
      expect(empty.identifiers.single.presence, 'present-empty');
      expect(empty.identifiers.single.rawValue.trim(), isEmpty);
      expect(empty.sourceOrdinal, 8);

      expect(labeledEmpty.item.codigo, isEmpty);
      expect(labeledEmpty.identifiers.single.rawValue, '(Código: )');
      expect(labeledEmpty.identifiers.single.presence, 'present-empty');
    });

    test('preserves raw parentheses and does not invent a GTIN', () {
      final item = RSItemScraper(
        Element.html(
          _row(
            codeMarkup:
                '<span class="RCod">'
                '(Código: AB(12))</span>',
          ),
        ),
      ).scrapeItem();
      final observation = item.identifiers.single;

      expect(item.item.codigo, 'AB12');
      expect(observation.rawValue, contains('AB(12)'));
      expect(observation.sourceField, 'html.RCod');
      expect(observation.role, 'retailer');
      expect(observation.classification, 'retailer-code');
      expect(observation.gtin14, isNull);
    });

    test(
      'preserves unknown RCod labels as non-actionable retailer evidence',
      () {
        final item = RSItemScraper(
          Element.html(
            _row(
              codeMarkup:
                  '<span class="RCod">'
                  '(Código alternativo: 321)</span>',
            ),
          ),
        ).scrapeItem();
        final observation = item.identifiers.single;

        expect(item.item.codigo, 'Código alternativo: 321');
        expect(observation.rawValue, contains('Código alternativo'));
        expect(observation.normalizedValue, isNull);
        expect(observation.classification, 'unknown');
        expect(observation.gtin14, isNull);
      },
    );

    test('assigns deterministic ordinals while preserving duplicate rows', () {
      final items = RSItemsScraper(
        Element.html('''
<table>
  ${_row(codeMarkup: '<span class="RCod">(Código: 321)</span>')}
  ${_row(codeMarkup: '<span class="RCod">(Código: 321)</span>')}
</table>
'''),
      ).scrapeItems();

      expect(items, hasLength(2));
      expect(items.map((item) => item.sourceOrdinal), [1, 2]);
      expect(items.map((item) => item.item.codigo), ['321', '321']);
    });
  });
}

String _row({String? codeMarkup}) {
  return '''
<tr>
  <td><span class="txtTit">Synthetic item</span>${codeMarkup ?? ''}
    <span class="Rqtd"><strong>Qtde.:</strong>1</span>
    <span class="RUN"><strong>UN:</strong>UN</span>
    <span class="RvlUnit"><strong>Vl. Unit.:</strong>1,00</span>
  </td>
  <td><span class="valor">1,00</span></td>
</tr>
''';
}
