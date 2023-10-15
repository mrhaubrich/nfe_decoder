import 'package:nfe_decoder/models/item.dart';

class NfeItem {
  final Item item;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  NfeItem({
    required this.item,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
  });

  NfeItem.fromMap(Map<String, dynamic> map)
      : item = Item.fromMap(map['item']),
        quantidade = map['quantidade'],
        valorUnitario = map['valorUnitario'],
        valorTotal = map['valorTotal'];

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
    };
  }
}
