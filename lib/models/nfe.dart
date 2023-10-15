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

  NFE.fromMap(Map<String, dynamic> map)
      : estabelecimento = Estabelecimento.fromMap(map['estabelecimento']),
        nfeChave = map['nfeChave'],
        dataEmissao = DateTime.parse(map['dataEmissao']),
        valorTotal = map['valorTotal'],
        valorDesconto = map['valorDesconto'],
        formasPagamento = List<NfeFormaPagamento>.from(
            map['formasPagamento']?.map((x) => NfeFormaPagamento.fromMap(x))),
        valorPago = map['valorPago'],
        items =
            List<NfeItem>.from(map['items']?.map((x) => NfeItem.fromMap(x))),
        url = map['url'],
        valorTributos = map['valorTributos'];

  Map<String, dynamic> toMap() {
    return {
      'estabelecimento': estabelecimento.toMap(),
      'nfeChave': nfeChave,
      'dataEmissao': dataEmissao.toIso8601String(),
      'valorTotal': valorTotal,
      'valorDesconto': valorDesconto,
      'formasPagamento':
          List<dynamic>.from(formasPagamento.map((x) => x.toMap())),
      'valorPago': valorPago,
      'items': List<dynamic>.from(items.map((x) => x.toMap())),
      'url': url,
      'valorTributos': valorTributos,
    };
  }
}
