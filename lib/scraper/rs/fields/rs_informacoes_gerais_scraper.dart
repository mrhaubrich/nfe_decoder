import 'package:html/dom.dart';
import 'package:intl/intl.dart';

class RSInformacoesGeraisScraper {
  final Element _element;

  RSInformacoesGeraisScraper(this._element);

  Element? _findEmissaoElement() {
    final strongElements = _element.querySelectorAll('strong');
    for (var element in strongElements) {
      if (element.text.contains("Emissão:")) {
        return element;
      }
    }
    return null;
  }

  String _getSurroundingText(Element? emissaoElement) {
    final surroundingText = emissaoElement?.parent?.text;
    if (surroundingText == null) {
      throw FormatException('No text found around Emissão element');
    }
    return surroundingText;
  }

  String _extractDateFromText(String surroundingText) {
    final datePattern =
        RegExp(r'Emissão: (\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2})');
    final dateMatch = datePattern.firstMatch(surroundingText);

    if (dateMatch == null) {
      throw FormatException('Failed to find Emissão date pattern');
    }

    return dateMatch
        .group(1)!; // The RegExp ensures there's a match, so `!` is safe here.
  }

  DateTime _parseEmissaoDate(String emissaoDateString) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    try {
      return dateFormat.parse(emissaoDateString);
    } catch (e) {
      throw FormatException('Failed to parse Emissão date');
    }
  }

  DateTime _getDataEmissao() {
    final emissaoElement = _findEmissaoElement();
    if (emissaoElement == null) {
      throw FormatException('Emissão element not found');
    }
    final surroundingText = _getSurroundingText(emissaoElement);
    final emissaoDateString = _extractDateFromText(surroundingText);
    return _parseEmissaoDate(emissaoDateString);
  }

  RSInformacoesGeraisData scrapeInformacoesGerais() {
    final dataEmissao = _getDataEmissao();

    return RSInformacoesGeraisData(
      dataEmissao: dataEmissao,
    );
  }
}

class RSInformacoesGeraisData {
  final DateTime dataEmissao;

  RSInformacoesGeraisData({
    required this.dataEmissao,
  });
}
