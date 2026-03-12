import 'package:hive/hive.dart';
import '../../domain/entities/produto.dart';
import '../../domain/entities/produto_alteracao.dart';
import 'produto_alteracao_model.dart';

part 'produto_model.g.dart';

@HiveType(typeId: 1)
class ProdutoModel extends Produto {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String nome;

  @HiveField(2)
  @override
  final String descricao;

  @HiveField(3)
  @override
  final double preco;

  @HiveField(4)
  @override
  final double iva;

  @HiveField(5)
  @override
  final String unidade;

  @HiveField(6)
  @override
  final int stock;

  @HiveField(7)
  @override
  final String serieNumero;

  @HiveField(8)
  @override
  final int versao;

  @HiveField(9)
  @override
  final List<ProdutoAlteracao> historicoAlteracoes;

  @HiveField(10)
  @override
  final DateTime dataCriacao;

  ProdutoModel({
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
  }) : dataCriacao = dataCriacao ?? DateTime.now(),
       super(
          id: id,
          nome: nome,
          descricao: descricao,
          preco: preco,
          iva: iva,
          unidade: unidade,
          stock: stock,
          serieNumero: serieNumero,
          versao: versao,
          historicoAlteracoes: historicoAlteracoes,
          dataCriacao: dataCriacao,
        );

  factory ProdutoModel.fromEntity(Produto produto) {
    return ProdutoModel(
      id: produto.id,
      nome: produto.nome,
      descricao: produto.descricao,
      preco: produto.preco,
      iva: produto.iva,
      unidade: produto.unidade,
      stock: produto.stock,
      serieNumero: produto.serieNumero,
      versao: produto.versao,
      historicoAlteracoes: produto.historicoAlteracoes,
      dataCriacao: produto.dataCriacao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'iva': iva,
      'unidade': unidade,
      'stock': stock,
      'serieNumero': serieNumero,
      'versao': versao,
      'historicoAlteracoes': historicoAlteracoes.map((a) => (a as ProdutoAlteracaoModel).toJson()).toList(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    final alteracoes = (json['historicoAlteracoes'] as List<dynamic>?)
        ?.map((a) => ProdutoAlteracaoModel.fromJson(a as Map<String, dynamic>))
        .toList() ?? [];
    
    return ProdutoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: (json['preco'] as num).toDouble(),
      iva: (json['iva'] as num).toDouble(),
      unidade: json['unidade'],
      stock: json['stock'],
      serieNumero: json['serieNumero'] ?? '',
      versao: json['versao'] ?? 1,
      historicoAlteracoes: alteracoes,
      dataCriacao: json['dataCriacao'] != null ? DateTime.parse(json['dataCriacao']) : null,
    );
  }
}
