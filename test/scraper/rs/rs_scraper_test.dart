import 'dart:io';

import 'package:html/dom.dart';
import 'package:nfe_decoder/models/endereco.dart';
import 'package:nfe_decoder/scraper/rs/rs_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RSScraper -> test Gecepel', () {
    late String html;
    setUp(() async {
      return File('test/mock_data/gecepel.html').readAsString().then((value) {
        html = value;
        return value;
      });
    });

    test('should get chave nfe', () async {
      expect(html, isNotNull);
      final document = Document.html(html);
      expect(document, isNotNull);
      final scraper = RSScraper(document);
      expect(scraper, isNotNull);
      final data = scraper.getNfeChave();
      expect(data, '4322 0792 7335 5900 0491 6544 1000 0128 9010 0021 8276');
    });

    // test those:
    //   Estabelecimento getEstabelecimento(); -> Supermercado Gecepel Ltda CNPJ: 92.733.559/0004-91 AV PROTASIO ALVES , 8453 , , MORRO SANTANA , POA , RS
    // String getNfeChave(); -> 4322 0792 7335 5900 0491 6544 1000 0128 9010 0021 8276
    // DateTime getDataEmissao(); -> 08/07/2022 17:38:39
    // double? getValorTotal(); -> null
    // double getValorDesconto(); -> 0,00
    // List<NfeFormaPagamento> getFormasPagamento(); -> [Cartão de Débito(45,75)]
    // double getValorPago(); -> 45,75
    // List<NfeItem> getItems(); -> 9 items
    // double getValorTributos(); -> 0,00

    test('should get estabelecimento', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getEstabelecimento();
      expect(data, isNotNull);
      expect(data.nome, 'Supermercado Gecepel Ltda');
      expect(data.cnpj, '92.733.559/0004-91');
      expect(
        data.endereco,
        Endereco(
          logradouro: 'AV PROTASIO ALVES',
          numero: '8453',
          complemento: '',
          bairro: 'MORRO SANTANA',
          cidade: 'POA',
          estado: 'RS',
        ),
      );
    });

    test('should get data emissao', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getDataEmissao();
      expect(data, isNotNull);
      // 08/07/2022 17:38:39
      expect(data, DateTime(2022, 7, 8, 17, 38, 39));
    });

    test('should get valor total', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorTotal();
      expect(data, isNull);
    });

    test('should get valor desconto', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorDesconto();
      expect(data, isNotNull);
      expect(data, 0.0);
    });

    test('should get formas pagamento', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getFormasPagamento();
      expect(data, isNotNull);
      expect(data.length, 1);
      expect(data[0].formaPagamento.descricao, 'Cartão de Débito');
      expect(data[0].valor, 45.75);
    });

    test('should get valor pago', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorPago();
      expect(data, isNotNull);
      expect(data, 45.75);
    });

    test('should get items', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getItems();
      expect(data, isNotNull);
      expect(data.length, 9);
    });

    test('should get valor tributos', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorTributos();
      expect(data, isNotNull);
      expect(data, 0.0);
    });
  });

  group('RSScraper -> test Irmaos Andreazza Ltda', () {
    late String html = File('test/mock_data/andreazza.html').readAsStringSync();

    test('should get chave nfe', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getNfeChave();
      expect(data, '4322 0701 1324 7800 2858 6510 6000 2225 1811 6440 9967');
    });

    // test those:
    //   Estabelecimento getEstabelecimento(); -> Irmaos Andreazza Ltda CNPJ: 01.132.478/0028-58 Amadio Perini, 375 , 0 , , Diamantino , Caxias Do Sul , RS
    // String getNfeChave(); -> 4322 0701 1324 7800 2858 6510 6000 2225 1811 6440 9967
    // DateTime getDataEmissao(); -> 15/07/2022 10:48:57
    // double? getValorTotal(); -> 455,06
    // double getValorDesconto(); -> 1,52
    // List<NfeFormaPagamento> getFormasPagamento(); -> [NfeFormaPagamento(tipo: Cartão de Débito, valor: 453,54)]
    // double getValorPago(); -> 453,54
    // List<NfeItem> getItems(); -> 53 items
    // double getValorTributos(); -> 102,21

    test('should get estabelecimento', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getEstabelecimento();
      expect(data, isNotNull);
      expect(data.nome, 'Irmaos Andreazza Ltda');
      expect(data.cnpj, '01.132.478/0028-58');
      expect(
        data.endereco,
        Endereco(
          logradouro: 'Amadio Perini',
          numero: '375',
          complemento: '0',
          bairro: 'Diamantino',
          cidade: 'Caxias Do Sul',
          estado: 'RS',
        ),
      );
    });

    test('should get data emissao', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getDataEmissao();
      expect(data, isNotNull);
      // 15/07/2022 10:48:57
      expect(data, DateTime(2022, 7, 15, 10, 48, 57));
    });

    test('should get valor total', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorTotal();
      expect(data, isNotNull);
      expect(data, 455.06);
    });

    test('should get valor desconto', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorDesconto();
      expect(data, isNotNull);
      expect(data, 1.52);
    });

    test('should get formas pagamento', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getFormasPagamento();
      expect(data, isNotNull);
      expect(data.length, 2);
      expect(data[0].formaPagamento.descricao, 'Cartão de Débito');
      expect(data[0].valor, 453.54);
    });

    test('should get valor pago', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorPago();
      expect(data, isNotNull);
      expect(data, 453.54);
    });

    test('should get items', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getItems();
      expect(data, isNotNull);
      expect(data.length, 4);
    });

    test('should get valor tributos', () async {
      final document = Document.html(html);
      final scraper = RSScraper(document);
      final data = scraper.getValorTributos();
      expect(data, isNotNull);
      expect(data, 102.21);
    });
  });
}
