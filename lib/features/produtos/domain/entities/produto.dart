import 'produto_alteracao.dart';

class Produto {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final double iva; // 23, 13, 6, 0
  final String unidade; // un, kg, m, etc
  final int stock;
  final String serieNumero; // Número de série único do produto
  final int versao; // Versão do produto para rastreamento
  final List<ProdutoAlteracao> historicoAlteracoes; // Histórico de alterações
  final DateTime dataCriacao; // Data de criação do produto

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.iva,
    required this.unidade,
    required this.stock,
    required this.serieNumero,
    this.versao = 1,
    this.historicoAlteracoes = const [],
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? preco,
    double? iva,
    String? unidade,
    int? stock,
    String? serieNumero,
    int? versao,
    List<ProdutoAlteracao>? historicoAlteracoes,
    DateTime? dataCriacao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      iva: iva ?? this.iva,
      unidade: unidade ?? this.unidade,
      stock: stock ?? this.stock,
      serieNumero: serieNumero ?? this.serieNumero,
      versao: versao ?? this.versao,
      historicoAlteracoes: historicoAlteracoes ?? this.historicoAlteracoes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  double get precoComIva => preco * (1 + iva / 100);
}
