import 'package:nfe_decoder/models/forma_pagamento.dart';

class NfeFormaPagamento {
  FormaPagamento formaPagamento;
  double valor;

  NfeFormaPagamento({required this.formaPagamento, required this.valor});

  NfeFormaPagamento.fromMap(Map<String, dynamic> map)
      : formaPagamento = FormaPagamento.fromMap(map['formaPagamento']),
        valor = map['valor'];

  Map<String, dynamic> toMap() {
    return {
      'formaPagamento': formaPagamento.toMap(),
      'valor': valor,
    };
  }
}
