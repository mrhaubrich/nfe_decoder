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
}
