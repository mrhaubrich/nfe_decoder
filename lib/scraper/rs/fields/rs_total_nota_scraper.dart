import 'package:html/dom.dart';
import 'package:nfe_decoder/models/forma_pagamento.dart';
import 'package:nfe_decoder/models/nfe_forma_pagamento.dart';

class RSTotalNotaScraper {
  final Element _element;

  // Defining the selectors as constants for better readability and maintainability
  static const String _totalItemsSelector =
      '#linhaTotal:nth-child(1) > .totalNumb';
  static const String _linhaTotalSelector = '#linhaTotal';
  static const String _valorPagoSelector =
      '#linhaTotal.linhaShade .totalNumb.txtMax';
  static const String _tributosSelector =
      '#linhaTotal.spcTop > .totalNumb.txtObs';
  static const String _formaPagamentoSelector = '#linhaTotal .tx';

  RSTotalNotaScraper(this._element);

  int _getTotalItens() {
    return _parseIntFromElement(_element.querySelector(_totalItemsSelector),
        fallback: 0);
  }

  double? _getValorTotal() {
    final elements = _element.querySelectorAll(_linhaTotalSelector);
    if (elements.length > 1 && elements[1].text.contains('Valor total R\$')) {
      return _parseDoubleFromElement(elements[1].querySelector('.totalNumb'));
    }
    return null;
  }

  double _getValorDesconto() {
    final elements = _element.querySelectorAll(_linhaTotalSelector);
    for (var element in elements) {
      if (element.text.contains("Descontos R\$")) {
        return _parseDoubleFromElement(element.querySelector('.totalNumb'),
            fallback: 0.0);
      }
    }
    return 0.0; // Default value if no matching element is found
  }

  double _getValorPago() {
    return _parseDoubleFromElement(_element.querySelector(_valorPagoSelector),
        fallback: 0.0);
  }

  List<NfeFormaPagamento> _getFormasPagamento() {
    return _element.querySelectorAll(_formaPagamentoSelector).map((txElement) {
      final parentElement = txElement.parent;
      return NfeFormaPagamento(
        formaPagamento: FormaPagamento(
            descricao: parentElement?.querySelector('label.tx')?.text.trim() ??
                'Não informado'),
        valor: _parseDoubleFromElement(
            parentElement?.querySelector('.totalNumb'),
            fallback: 0.0),
      );
    }).toList();
  }

  double _getTributos() {
    return _parseDoubleFromElement(_element.querySelector(_tributosSelector),
        fallback: 0.0);
  }

  RSTotalNotaData scrapeTotalNota() {
    return RSTotalNotaData(
      totalItens: _getTotalItens(),
      valorTotal: _getValorTotal(),
      valorDesconto: _getValorDesconto(),
      valorPago: _getValorPago(),
      formasPagamento: _getFormasPagamento(),
      tributos: _getTributos(),
    );
  }

  int _parseIntFromElement(Element? element, {int fallback = 0}) {
    final text = element?.text.trim();
    return int.tryParse(text ?? '') ?? fallback;
  }

  double _parseDoubleFromElement(Element? element, {double fallback = 0.0}) {
    if (element == null) return fallback;
    final processedText = element.text.trim().replaceAll(',', '.');
    return double.tryParse(processedText) ?? fallback;
  }
}

// ... [rest of the code remains unchanged]

class RSTotalNotaData {
  // 'totalItens': '#linhaTotal > .totalNumb:nth-child(2)', // '53'
  // 'valorTotal': '#linhaTotal:nth-child(2) > .totalNumb', // '455,06'
  // 'valorDesconto': '#linhaTotal:nth-child(3) > .totalNumb', // '1,52'
  // 'valorPago': '#linhaTotal:nth-child(4) > .totalNumb.txtMax', // '453,54'
  // 'formaPagamentoDescricao': '#linhaForma > .tx', // 'Cartão de Débito'
  // 'formaPagamentoValor': '#linhaTotal:nth-child(6) > .totalNumb', // '453,54'
  // 'tributos': '#linhaTotal.spcTop > .totalNumb.txtObs', // '102,21'
  final int totalItens;
  final double? valorTotal;
  final double valorDesconto;
  final double valorPago;
  final List<NfeFormaPagamento> formasPagamento;
  final double tributos;

  RSTotalNotaData({
    required this.totalItens,
    required this.valorTotal,
    required this.valorDesconto,
    required this.valorPago,
    required this.formasPagamento,
    required this.tributos,
  });
}
