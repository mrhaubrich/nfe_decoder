class Endereco {
  // AV PROTASIO ALVES , 8453 , , MORRO SANTANA , POA , RS
  // Amadio Perini, 375 , 0 , , Diamantino , Caxias Do Sul , RS
  late String logradouro;
  late String numero;
  late String complemento;
  late String bairro;
  late String cidade;
  late String estado;

  Endereco({
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Endereco &&
        other.logradouro == logradouro &&
        other.numero == numero &&
        other.complemento == complemento &&
        other.bairro == bairro &&
        other.cidade == cidade &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return logradouro.hashCode ^
        numero.hashCode ^
        complemento.hashCode ^
        bairro.hashCode ^
        cidade.hashCode ^
        estado.hashCode;
  }

  Endereco.fromMap(Map<String, dynamic> map) {
    logradouro = map['logradouro'];
    numero = map['numero'];
    complemento = map['complemento'];
    bairro = map['bairro'];
    cidade = map['cidade'];
    estado = map['estado'];
  }

  Map<String, dynamic> toMap() {
    return {
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}
