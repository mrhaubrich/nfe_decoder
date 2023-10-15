class Item {
//   MELAO ESPANHOL KG (Código: 9952108 )
// Qtde.:0,785  UN: KG  Vl. Unit.:   7,99 	Vl. Total 6,27

  final String codigo;
  final String descricao;
  final String unidade;

  Item({
    required this.codigo,
    required this.descricao,
    required this.unidade,
  });

  Item.fromMap(Map<String, dynamic> map)
      : codigo = map['codigo'],
        descricao = map['descricao'],
        unidade = map['unidade'];

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'unidade': unidade,
    };
  }
}
