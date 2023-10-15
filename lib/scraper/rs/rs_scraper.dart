import 'package:html/dom.dart';
import 'package:nfe_decoder/models/estabelecimento.dart';
import 'package:nfe_decoder/models/nfe_forma_pagamento.dart';
import 'package:nfe_decoder/models/nfe_item.dart';
import 'package:nfe_decoder/scraper/base_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_estabelecimento_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_informacoes_gerais_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_items_scraper.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_total_nota_scraper.dart';

class RSScraper extends BaseScraper {
  RSScraper(Document document) : super(document);

  static final _selectors = {
    'estabelecimento': '#conteudo',
    'itemsTbody': '#tabResult',
    'totalNota': '#totalNota',
    'informacoesGeraisNota': '#infos > div:nth-child(1) > ul > li',
    'chaveAcesso': '.chave',
  };

  Element? estabelecimentoElement;
  Element? informacoesGeraisElement;

  RSTotalNotaData? _totalNotaData;
  RSInformacoesGeraisData? _informacoesGeraisData;

  Element _getInformacoesGeraisElement() {
    final elements = document.querySelectorAll('h4');

    final pattern = RegExp(r'Informações\s+gerais\s+da\s+Nota',
        multiLine: true, caseSensitive: false);

    for (var element in elements) {
      if (pattern.hasMatch(element.text)) {
        return element
            .nextElementSibling!; // assuming the data is in the next sibling
      }
    }

    throw Exception('Informações gerais não encontradas');
  }

  RSInformacoesGeraisData _getInformacoesGeraisData() {
    if (_informacoesGeraisData == null) {
      final element = _getInformacoesGeraisElement();
      final scraper = RSInformacoesGeraisScraper(element);
      _informacoesGeraisData = scraper.scrapeInformacoesGerais();
    }

    return _informacoesGeraisData!;
  }

  @override
  DateTime getDataEmissao() {
    return _getInformacoesGeraisData().dataEmissao;
  }

  Element _getEstabelentoElement() {
    // use estabelecimentoElement
    if (estabelecimentoElement != null) {
      return estabelecimentoElement!;
    }

    final element =
        document.querySelector(_selectors['estabelecimento']!)?.children[0];
    if (element == null) {
      throw Exception('Estabelecimento não encontrado');
    }

    return element;
  }

  @override
  Estabelecimento getEstabelecimento() {
    final element = _getEstabelentoElement();

    final scraper = RSEstabelecimentoScraper(element);

    return scraper.getEstabelecimento();
  }

  RSTotalNotaScraper _getTotalNotaScraper() {
    final element = document.querySelector(_selectors['totalNota']!);
    if (element == null) {
      throw Exception('Total da nota não encontrado');
    }

    return RSTotalNotaScraper(element);
  }

  RSTotalNotaData _getTotalNotaData() {
    if (_totalNotaData == null) {
      final scraper = _getTotalNotaScraper();
      _totalNotaData = scraper.scrapeTotalNota();
    }

    return _totalNotaData!;
  }

  @override
  List<NfeFormaPagamento> getFormasPagamento() {
    return _getTotalNotaData().formasPagamento;
  }

  @override
  List<NfeItem> getItems() {
    final element = document.querySelector(_selectors['itemsTbody']!);
    if (element == null) {
      throw Exception('Items não encontrados');
    }

    final scraper = RSItemsScraper(element);

    return scraper.scrapeItems();
  }

  @override
  String getNfeChave() {
    final element = document.querySelector(_selectors['chaveAcesso']!);
    if (element == null) {
      throw Exception('Chave de acesso não encontrada');
    }

    return element.text;
  }

  @override
  double getValorDesconto() {
    return _getTotalNotaData().valorDesconto;
  }

  @override
  double getValorPago() {
    return _getTotalNotaData().valorPago;
  }

  @override
  double? getValorTotal() {
    return _getTotalNotaData().valorTotal;
  }

  @override
  double getValorTributos() {
    return _getTotalNotaData().tributos;
  }
}
