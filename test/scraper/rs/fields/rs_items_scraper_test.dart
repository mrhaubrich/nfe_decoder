import 'dart:io';

import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_items_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RSItemsScraper -> test Gecepel', () {
    final html = File('test/mock_data/gecepel_items.html').readAsStringSync();

    final element = Element.html(html);
    final item = RSItemsScraper(element).scrapeItems();

    test('should extract 9 items', () {
      expect(item.length, 9);
    });

    test('should extract item description', () {
      expect(item[0].item.descricao, 'MINI PQJ TRIGELE KG');
    });

    test('should extract item code', () {
      expect(item[0].item.codigo, '5187');
    });

    test('should extract item unit', () {
      expect(item[0].item.unidade, 'KG');
    });

    test('should extract item quantity', () {
      expect(item[0].quantidade, 0.12);
    });

    test('should extract item unit value', () {
      expect(item[0].valorUnitario, 29.9);
    });

    test('should extract item total value', () {
      expect(item[0].valorTotal, 3.59);
    });
  });
  group('RSItemsScraper -> test Andreazza', () {
    final html = File('test/mock_data/andreazza_items.html').readAsStringSync();

    final element = Element.html(html);
    final item = RSItemsScraper(element).scrapeItems();

    test('should extract 53 items', () {
      expect(item.length, 53);
    });

    test('should extract item description', () {
      expect(item[0].item.descricao, 'Patinho C.B S O Resf Kg');
    });

    test('should extract item code', () {
      expect(item[0].item.codigo, '161063');
    });

    test('should extract item unit', () {
      expect(item[0].item.unidade, 'KG');
    });

    test('should extract item quantity', () {
      expect(item[0].quantidade, 0.69);
    });

    test('should extract item unit value', () {
      expect(item[0].valorUnitario, 44.99);
    });

    test('should extract item total value', () {
      expect(item[0].valorTotal, 31.04);
    });
  });
}
