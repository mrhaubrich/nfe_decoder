import 'package:nfe_decoder/models/estabelecimento.dart';
import 'package:nfe_decoder/models/nfe_forma_pagamento.dart';
import 'package:nfe_decoder/models/nfe_item.dart';

// for ORM: https://drift.simonbinder.eu/docs/
class NFE {
  final Estabelecimento estabelecimento;
  final String nfeChave;
  final DateTime dataEmissao;
  final double? valorTotal;
  final double valorDesconto;
  final List<NfeFormaPagamento> formasPagamento;
  final double valorPago;
  final List<NfeItem> items;
  String? url;
  final double valorTributos;

  NFE({
    required this.estabelecimento,
    required this.nfeChave,
    required this.dataEmissao,
    required this.valorTotal,
    required this.valorDesconto,
    required this.formasPagamento,
    required this.valorPago,
    required this.items,
    this.url,
    required this.valorTributos,
  });

  @override
  String toString() {
    return 'NFE{estabelecimento: $estabelecimento, nfeChave: $nfeChave, dataEmissao: $dataEmissao, valorTotal: $valorTotal, valorDesconto: $valorDesconto, formasPagamento: $formasPagamento, valorPago: $valorPago, items: $items, valorTributos: $valorTributos}';
  }
}
