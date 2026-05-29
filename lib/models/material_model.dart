class MaterialModel {

  final String nome;
  final double valorCompra;
  final double valorVenda;

  MaterialModel({
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
    Map<String, dynamic> map,
  ) {
    return MaterialModel(
      nome: map['nome'],
      valorCompra: map['valorCompra'],
      valorVenda: map['valorVenda'],
    );
  }
}