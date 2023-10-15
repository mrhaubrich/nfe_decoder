import 'package:html/dom.dart';
import 'package:nfe_decoder/models/estabelecimento.dart';
import 'package:nfe_decoder/models/nfe.dart';
import 'package:nfe_decoder/models/nfe_forma_pagamento.dart';
import 'package:nfe_decoder/models/nfe_item.dart';

abstract class BaseScraper {
  final Document document;

  BaseScraper(this.document);

  Estabelecimento getEstabelecimento();
  String getNfeChave();
  DateTime getDataEmissao();
  double? getValorTotal();
  double getValorDesconto();
  List<NfeFormaPagamento> getFormasPagamento();
  double getValorPago();
  List<NfeItem> getItems();
  // String getNfeLink();
  double getValorTributos();

  NFE getNfe() {
    return NFE(
      estabelecimento: getEstabelecimento(),
      nfeChave: getNfeChave(),
      dataEmissao: getDataEmissao(),
      valorTotal: getValorTotal(),
      valorDesconto: getValorDesconto(),
      formasPagamento: getFormasPagamento(),
      valorPago: getValorPago(),
      items: getItems(),
      valorTributos: getValorTributos(),
    );
  }
}
