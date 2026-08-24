class Planejamento {
  Planejamento({
    required this.id,
    required this.nome,
    required this.meta,
    required this.dataInicio,
    required this.dataFim,
  });

  final String id;
  final String nome;
  final double meta;
  final DateTime dataInicio;
  final DateTime dataFim;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'meta': meta,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
    };
  }

  factory Planejamento.fromMap(Map<String, dynamic> map) {
    return Planejamento(
      id: map['id'] as String,
      nome: map['nome'] as String,
      meta: (map['meta'] as num).toDouble(),
      dataInicio: DateTime.parse(map['dataInicio'] as String),
      dataFim: DateTime.parse(map['dataFim'] as String),
    );
  }
}
