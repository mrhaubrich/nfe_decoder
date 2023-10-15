class FormaPagamento {
  String descricao;

  FormaPagamento({required this.descricao});

  FormaPagamento.fromMap(Map<String, dynamic> map)
      : descricao = map['descricao'];

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
    };
  }
}
