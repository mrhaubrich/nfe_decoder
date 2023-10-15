import 'package:html/dom.dart';
import 'package:nfe_decoder/models/item.dart';
import 'package:nfe_decoder/models/nfe_item.dart';

class RSItemScraper {
  static final _selectors = {
    'descricao': '.txtTit',
    'codigo': '.RCod',
    'unidade': '.RUN',
    'quantidade': '.Rqtd',
    'valorUnitario': '.RvlUnit',
    'valorTotal': '.valor',
  };

  final Element _element;

  RSItemScraper(this._element);

  NfeItem scrapeItem() {
    String descricao = _extractText('descricao');
    String codigoStr = _extractText('codigo').replaceAll('\n', '').trim();
    String codigo = codigoStr
        .split('Código:')
        .last
        .replaceAll(')', '')
        .replaceAll('(', '')
        .trim();
    String unidade = _extractText('unidade').split('UN:').last.trim();
    String quantidadeStr = _extractText('quantidade');
    double quantidade = double.tryParse(
            quantidadeStr.split('Qtde.:').last.trim().replaceAll(',', '.')) ??
        0.0;
    String valorUnitarioStr = _extractText('valorUnitario');
    double valorUnitario = double.tryParse(valorUnitarioStr
            .split('Vl. Unit.:')
            .last
            .trim()
            .replaceAll(',', '.')) ??
        0.0;
    double valorTotal =
        double.tryParse(_extractText('valorTotal').replaceAll(',', '.')) ?? 0.0;

    return NfeItem(
      item: Item(
        codigo: codigo,
        descricao: descricao,
        unidade: unidade,
      ),
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      valorTotal: valorTotal,
    );
  }

  String _extractText(String key) {
    return _element
            .querySelector(_selectors[key]!)
            ?.text
            .replaceAll('\n', '')
            .trim() ??
        '';
  }
}
