// 4. Item Extractor

import 'package:html/dom.dart';

class ItemExtractor {
  final Element table;

  ItemExtractor(this.table);

  List<dynamic> extractItems() {
    final rows = table.querySelectorAll('tr');
    rows.removeAt(0);
    return rows.map((element) => _getItem(element)).toList();
  }

  dynamic _getItem(Element item) {
    return {
      'codigo': item.children[0].text.trim(),
      'descricao': item.children[1].text.trim(),
      'quantidade': item.children[2].text.trim().replaceAll(',', '.'),
      'unidade': item.children[3].text.trim(),
      'valorUnitario': item.children[4].text.trim().replaceAll(',', '.'),
      'valorTotal': item.children[5].text.trim().replaceAll(',', '.'),
    };
  }
}
