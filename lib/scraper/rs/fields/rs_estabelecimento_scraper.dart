import 'package:html/dom.dart';
import 'package:nfe_decoder/models/endereco.dart';
import 'package:nfe_decoder/models/estabelecimento.dart';

class RSEstabelecimentoScraper {
  final Element _element;

  RSEstabelecimentoScraper(this._element);

  String _getNome() {
    return _element.querySelector('#u20')?.text.trim() ?? 'Não informado';
  }

  String _getCnpj() {
    final nomeDiv = _element.querySelector('#u20');

    // If the 'nomeDiv' is found, try to get the next div which contains the CNPJ
    if (nomeDiv != null) {
      final cnpjDiv = nomeDiv.nextElementSibling;
      if (cnpjDiv != null) {
        return cnpjDiv.text.replaceAll('CNPJ:', '').trim();
      }
    }

    return 'Não informado';
  }

  Endereco _getEndereco() {
    // Get the div that contains the CNPJ to identify the address div
    final cnpjDiv = _element.querySelector('#u20')?.nextElementSibling;

    // If the 'cnpjDiv' is found, try to get the next div which contains the address
    if (cnpjDiv != null) {
      final addressDiv = cnpjDiv.nextElementSibling;
      if (addressDiv != null) {
        String rawAddress = addressDiv.text;

        // Process the raw address
        final split = rawAddress.split(',');
        final logradouro = split[0].trim();
        final numero = split.length > 1 ? split[1].trim() : '';
        final complemento = split.length > 2 ? split[2].trim() : '';
        final bairro = split.length > 3 ? split[split.length - 3].trim() : '';
        final cidade = split.length > 4 ? split[split.length - 2].trim() : '';
        final estado = split.length > 5 ? split[split.length - 1].trim() : '';

        return Endereco(
          logradouro: logradouro,
          numero: numero,
          complemento: complemento,
          bairro: bairro,
          cidade: cidade,
          estado: estado,
        );
      }
    }

    // Return default if unable to extract
    return Endereco(
      logradouro: 'Não informado',
      numero: '',
      complemento: '',
      bairro: '',
      cidade: '',
      estado: '',
    );
  }

  Estabelecimento getEstabelecimento() {
    return Estabelecimento(
      nome: _getNome(),
      cnpj: _getCnpj(),
      endereco: _getEndereco(),
    );
  }
}
