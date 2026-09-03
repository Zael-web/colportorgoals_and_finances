class Planejamento {
  Planejamento({
    required this.id,
    required this.nome,
    required this.meta,
    required this.dataInicio,
    required this.dataFim,
    required this.quantidadeDias,
    this.feriados = const [],
  });

  final String id;
  final String nome;
  final double meta;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int quantidadeDias;
  final List<DateTime> feriados;

  static DateTime calcularDataFim({
    required DateTime dataInicio,
    required int quantidadeDias,
    List<DateTime> feriados = const [],
  }) {
    if (quantidadeDias <= 0) return dataInicio;

    final feriadosNormalizados = feriados
        .map((data) => DateTime(data.year, data.month, data.day))
        .toSet();
    var data = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    var diasContados = 0;

    while (diasContados < quantidadeDias) {
      final fimDeSemana = data.weekday == DateTime.saturday ||
          data.weekday == DateTime.sunday;
      if (!fimDeSemana && !feriadosNormalizados.contains(data)) {
        diasContados++;
      }
      if (diasContados < quantidadeDias) {
        data = data.add(const Duration(days: 1));
      }
    }
    return data;
  }

  static int calcularQuantidadeDias({
    required DateTime dataInicio,
    required DateTime dataFim,
    List<DateTime> feriados = const [],
  }) {
    final feriadosNormalizados = feriados
        .map((data) => DateTime(data.year, data.month, data.day))
        .toSet();
    var data = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    final ultimoDia = DateTime(dataFim.year, dataFim.month, dataFim.day);
    var dias = 0;

    while (!data.isAfter(ultimoDia)) {
      final fimDeSemana = data.weekday == DateTime.saturday ||
          data.weekday == DateTime.sunday;
      if (!fimDeSemana && !feriadosNormalizados.contains(data)) {
        dias++;
      }
      data = data.add(const Duration(days: 1));
    }
    return dias;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'meta': meta,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'quantidadeDias': quantidadeDias,
      'feriados': feriados.map((data) => data.toIso8601String()).toList(),
    };
  }

  factory Planejamento.fromMap(Map<String, dynamic> map) {
    return Planejamento(
      id: map['id'] as String,
      nome: map['nome'] as String,
      meta: (map['meta'] as num).toDouble(),
      dataInicio: DateTime.parse(map['dataInicio'] as String),
      dataFim: DateTime.parse(map['dataFim'] as String),
      quantidadeDias: (map['quantidadeDias'] as num?)?.toInt() ??
          _diasUteisEntre(
            DateTime.parse(map['dataInicio'] as String),
            DateTime.parse(map['dataFim'] as String),
          ),
      feriados: ((map['feriados'] as List<dynamic>?) ?? const [])
          .map((data) => DateTime.parse(data as String))
          .toList(),
    );
  }

  static int _diasUteisEntre(DateTime inicio, DateTime fim) {
    var data = DateTime(inicio.year, inicio.month, inicio.day);
    final ultimoDia = DateTime(fim.year, fim.month, fim.day);
    var dias = 0;
    while (!data.isAfter(ultimoDia)) {
      if (data.weekday != DateTime.saturday &&
          data.weekday != DateTime.sunday) {
        dias++;
      }
      data = data.add(const Duration(days: 1));
    }
    return dias;
  }
}
