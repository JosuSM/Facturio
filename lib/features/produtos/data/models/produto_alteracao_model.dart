import 'package:hive/hive.dart';
import '../../domain/entities/produto_alteracao.dart';

part 'produto_alteracao_model.g.dart';

@HiveType(typeId: 13)
class ProdutoAlteracaoModel extends ProdutoAlteracao {
  @HiveField(0)
  @override
  final DateTime dataCriacao;

  @HiveField(1)
  @override
  final int versao;

  @HiveField(2)
  @override
  final double precoAnterior;

  @HiveField(3)
  @override
  final double precoNovo;

  @HiveField(4)
  @override
  final String descricaoAlteracao;

  ProdutoAlteracaoModel({
    required this.dataCriacao,
    required this.versao,
    required this.precoAnterior,
    required this.precoNovo,
    required this.descricaoAlteracao,
  }) : super(
          dataCriacao: dataCriacao,
          versao: versao,
          precoAnterior: precoAnterior,
          precoNovo: precoNovo,
          descricaoAlteracao: descricaoAlteracao,
        );

  factory ProdutoAlteracaoModel.fromEntity(ProdutoAlteracao alteracao) {
    return ProdutoAlteracaoModel(
      dataCriacao: alteracao.dataCriacao,
      versao: alteracao.versao,
      precoAnterior: alteracao.precoAnterior,
      precoNovo: alteracao.precoNovo,
      descricaoAlteracao: alteracao.descricaoAlteracao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataCriacao': dataCriacao.toIso8601String(),
      'versao': versao,
      'precoAnterior': precoAnterior,
      'precoNovo': precoNovo,
      'descricaoAlteracao': descricaoAlteracao,
    };
  }

  factory ProdutoAlteracaoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoAlteracaoModel(
      dataCriacao: DateTime.parse(json['dataCriacao']),
      versao: json['versao'],
      precoAnterior: (json['precoAnterior'] as num).toDouble(),
      precoNovo: (json['precoNovo'] as num).toDouble(),
      descricaoAlteracao: json['descricaoAlteracao'],
    );
  }
}
