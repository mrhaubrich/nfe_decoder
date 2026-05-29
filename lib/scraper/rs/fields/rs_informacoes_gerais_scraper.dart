import 'package:html/dom.dart';

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
    final datePattern = RegExp(
      r'Emissão: (\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2})',
    );
    final dateMatch = datePattern.firstMatch(surroundingText);

    if (dateMatch == null) {
      throw FormatException('Failed to find Emissão date pattern');
    }

    return dateMatch.group(
      1,
    )!; // The RegExp ensures there's a match, so `!` is safe here.
  }

  DateTime _parseEmissaoDate(String emissaoDateString) {
    final day = int.parse(emissaoDateString.substring(0, 2));
    final month = int.parse(emissaoDateString.substring(3, 5));
    final year = int.parse(emissaoDateString.substring(6, 10));
    final hour = int.parse(emissaoDateString.substring(11, 13));
    final minute = int.parse(emissaoDateString.substring(14, 16));
    final second = int.parse(emissaoDateString.substring(17, 19));
    final date = DateTime(year, month, day, hour, minute, second);

    if (date.year != year ||
        date.month != month ||
        date.day != day ||
        date.hour != hour ||
        date.minute != minute ||
        date.second != second) {
      throw FormatException('Failed to parse Emissão date');
    }

    return date;
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

    return RSInformacoesGeraisData(dataEmissao: dataEmissao);
  }
}

class RSInformacoesGeraisData {
  final DateTime dataEmissao;

  RSInformacoesGeraisData({required this.dataEmissao});
}
