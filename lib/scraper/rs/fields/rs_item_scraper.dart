import 'package:html/dom.dart';
import 'package:nfe_decoder/models/identifier_observation.dart';
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

  NfeItem scrapeItem({int? sourceOrdinal}) {
    String descricao = _extractText('descricao');
    final rawCodigo = _element.querySelector(_selectors['codigo']!)?.text;
    String codigoStr = rawCodigo?.replaceAll('\n', '').trim() ?? '';
    String codigo = codigoStr
        .split('Código:')
        .last
        .replaceAll(')', '')
        .replaceAll('(', '')
        .trim();
    String unidade = _extractText('unidade').split('UN:').last.trim();
    String quantidadeStr = _extractText('quantidade');
    double quantidade =
        double.tryParse(
          quantidadeStr.split('Qtde.:').last.trim().replaceAll(',', '.'),
        ) ??
        0.0;
    String valorUnitarioStr = _extractText('valorUnitario');
    double valorUnitario =
        double.tryParse(
          valorUnitarioStr.split('Vl. Unit.:').last.trim().replaceAll(',', '.'),
        ) ??
        0.0;
    double valorTotal =
        double.tryParse(_extractText('valorTotal').replaceAll(',', '.')) ?? 0.0;

    return NfeItem(
      item: Item(codigo: codigo, descricao: descricao, unidade: unidade),
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      valorTotal: valorTotal,
      identifierContractVersion: 1,
      identifiers: [_retailerCodeObservation(rawCodigo, codigo)],
      sourceOrdinal: sourceOrdinal,
      sourceMetadata: const {
        'layout': 'rs-html-item',
        'captureMethod': 'html.RCod',
        'parser': 'RSItemScraper',
        'parserVersion': 'nfe_decoder-0.3.0',
        'sourceOrdinalBasis': 'rs-html-tr-order',
      },
    );
  }

  IdentifierObservation _retailerCodeObservation(
    String? rawCodigo,
    String codigo,
  ) {
    final labelIndex = rawCodigo?.indexOf('Código:') ?? -1;
    final hasRecognizedLabel = labelIndex >= 0;
    final labeledValue = hasRecognizedLabel
        ? rawCodigo!
              .substring(labelIndex + 'Código:'.length)
              .replaceAll(')', '')
              .replaceAll('(', '')
              .trim()
        : '';
    final presence = rawCodigo == null
        ? 'absent'
        : rawCodigo.trim().isEmpty ||
              (hasRecognizedLabel && labeledValue.isEmpty)
        ? 'present-empty'
        : 'present-value';
    return IdentifierObservation(
      rawValue: rawCodigo ?? '',
      normalizedValue: !hasRecognizedLabel || codigo.isEmpty ? null : codigo,
      representationLength:
          hasRecognizedLabel && RegExp(r'^\d+$').hasMatch(codigo)
          ? codigo.length
          : null,
      sourceField: 'html.RCod',
      role: 'retailer',
      presence: presence,
      validation: 'unchecked',
      classification: hasRecognizedLabel ? 'retailer-code' : 'unknown',
      evidenceBasis: 'html-label',
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
