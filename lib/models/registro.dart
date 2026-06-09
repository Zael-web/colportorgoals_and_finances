class Registro {
  final String material;
  final double vendido;
  final double comprado;
  final int quantidade;
  final String observacao;
  final DateTime data;
  final String formaPagamento;
  final double dizimo;
  final double taxaCartao;
  final double valorLiquido;

  Registro({
    required this.material,
    required this.vendido,
    required this.comprado,
    required this.quantidade,
    required this.observacao,
    required this.data,
    required this.formaPagamento,
    required this.dizimo,
    required this.taxaCartao,
    required this.valorLiquido,
  });

  Map<String, dynamic> toMap() {
    return {
      'material': material,
      'vendido': vendido,
      'comprado': comprado,
      'quantidade': quantidade,
      'observacao': observacao,
      'data': data.toIso8601String(),
      'formaPagamento': formaPagamento,
      'dizimo': dizimo,
      'taxaCartao': taxaCartao,
      'valorLiquido': valorLiquido,
    };
  }

  factory Registro.fromMap(
    Map<String, dynamic> map,
  ) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    final vendido = toDouble(map['vendido']);
    final dizimo = toDouble(map['dizimo']);
    final taxaCartao = toDouble(map['taxaCartao']);
    final valorLiquido = toDouble(map['valorLiquido']);

    return Registro(
      material: map['material'] ?? '',
      vendido: vendido,
      comprado: toDouble(map['comprado']),
      quantidade: map['quantidade'] ?? 0,
      observacao: map['observacao'] ?? '',
      data: DateTime.parse(map['data']),
      formaPagamento: map['formaPagamento'] ?? 'Dinheiro',
      dizimo: dizimo,
      taxaCartao: taxaCartao,
      valorLiquido: valorLiquido == 0 && vendido > 0
          ? vendido - dizimo - taxaCartao
          : valorLiquido,
    );
  }
}