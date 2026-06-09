class MaterialModel {
  final String? id;
  final String nome;
  final double valorCompra;
  final double valorVenda;

  MaterialModel({
    this.id,
    required this.nome,
    required this.valorCompra,
    required this.valorVenda,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'valorCompra': valorCompra,
      'valorVenda': valorVenda,
    };
  }

  factory MaterialModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return MaterialModel(
      id: id,
      nome: map['nome']?.toString() ?? '',
      valorCompra: _toDouble(map['valorCompra']),
      valorVenda: _toDouble(map['valorVenda']),
    );
  }

  MaterialModel copyWith({
    String? id,
    String? nome,
    double? valorCompra,
    double? valorVenda,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorCompra: valorCompra ?? this.valorCompra,
      valorVenda: valorVenda ?? this.valorVenda,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}