class ProdutoModel {
  String nome;
  double valor;

  ProdutoModel({
    required this.nome,
    required this.valor,
  });

  // Converte o objeto ProdutoModel em um Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'valor': valor,
    };
  }

  // Cria um objeto ProdutoModel a partir de um Map (JSON)
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      nome: map['nome'] ?? '',
      valor: (map['valor'] is num) ? (map['valor'] as num).toDouble() : 0.0,
    );
  }
}