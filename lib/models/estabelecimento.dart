import 'package:nfe_decoder/models/endereco.dart';

class Estabelecimento {
//   Supermercado Gecepel Ltda
// CNPJ: 92.733.559/0004-91
// AV PROTASIO ALVES , 8453 , , MORRO SANTANA , POA , RS

  String nome;
  String cnpj;
  Endereco endereco;

  Estabelecimento({
    required this.nome,
    required this.cnpj,
    required this.endereco,
  });

  Estabelecimento.fromMap(Map<String, dynamic> map)
      : nome = map['nome'],
        cnpj = map['cnpj'],
        endereco = Endereco.fromMap(map['endereco']);

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'endereco': endereco.toMap(),
    };
  }
}
