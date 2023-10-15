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
}
