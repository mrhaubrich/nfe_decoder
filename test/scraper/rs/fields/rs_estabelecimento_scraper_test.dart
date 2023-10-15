import 'dart:io';

import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_estabelecimento_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RSEstabelecimentoScraper -> test Irmaos Andreazza Ltda', () {
    final html = File('test/mock_data/andreazza_estabelecimento.html')
        .readAsStringSync();
    final element = Element.html(html);
    final estabelecimentoScraper = RSEstabelecimentoScraper(element);
    final estabelecimento = estabelecimentoScraper.getEstabelecimento();

    test('should extract name correctly', () {
      expect(estabelecimento.nome, 'Irmaos Andreazza Ltda');
    });

    test('should extract CNPJ correctly', () {
      expect(estabelecimento.cnpj, '01.132.478/0028-58');
    });

    test('should extract logradouro correctly', () {
      expect(estabelecimento.endereco.logradouro, 'Amadio Perini');
    });

    test('should extract numero correctly', () {
      expect(estabelecimento.endereco.numero, '375');
    });

    test('should extract complemento correctly', () {
      expect(estabelecimento.endereco.complemento, '0');
    });

    test('should extract bairro correctly', () {
      expect(estabelecimento.endereco.bairro, 'Diamantino');
    });

    test('should extract cidade correctly', () {
      expect(estabelecimento.endereco.cidade, 'Caxias Do Sul');
    });

    test('should extract estado correctly', () {
      expect(estabelecimento.endereco.estado, 'RS');
    });
  });

  group('RSEstabelecimentoScraper -> test Supermercado Gecepel Ltda', () {
    final html =
        File('test/mock_data/gecepel_estabelecimento.html').readAsStringSync();
    final element = Element.html(html);
    final estabelecimentoScraper = RSEstabelecimentoScraper(element);
    final estabelecimento = estabelecimentoScraper.getEstabelecimento();

    test('should extract name correctly', () {
      expect(estabelecimento.nome, 'Supermercado Gecepel Ltda');
    });

    test('should extract CNPJ correctly', () {
      expect(estabelecimento.cnpj, '92.733.559/0004-91');
    });

    test('should extract logradouro correctly', () {
      expect(estabelecimento.endereco.logradouro, 'AV PROTASIO ALVES');
    });

    test('should extract numero correctly', () {
      expect(estabelecimento.endereco.numero, '8453');
    });

    test('should extract complemento correctly', () {
      expect(estabelecimento.endereco.complemento, '');
    });

    test('should extract bairro correctly', () {
      expect(estabelecimento.endereco.bairro, 'MORRO SANTANA');
    });

    test('should extract cidade correctly', () {
      expect(estabelecimento.endereco.cidade, 'POA');
    });

    test('should extract estado correctly', () {
      expect(estabelecimento.endereco.estado, 'RS');
    });
  });
}
