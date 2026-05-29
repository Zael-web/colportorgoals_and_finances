class Registro {
  final double vendido;
  final double comprado;
  final int quantidade;
  final String observacao;
  final DateTime data;

  Registro({
    required this.vendido,
    required this.comprado,
    required this.quantidade,
    required this.observacao,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'vendido': vendido,
      'comprado': comprado,
      'quantidade': quantidade,
      'observacao': observacao,
      'data': data.toIso8601String(),
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      vendido: map['vendido'],
      comprado: map['comprado'],
      quantidade: map['quantidade'],
      observacao: map['observacao'],
      data: DateTime.parse(map['data']),
    );
  }
}