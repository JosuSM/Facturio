import 'package:hive/hive.dart';
import '../../../../shared/models/pagamento.dart';

part 'pagamento_model.g.dart';

/// Model Hive para persistência de pagamentos.
/// 
/// TypeId 3 - Certifique-se que não colide com outros adapters
@HiveType(typeId: 3)
class PagamentoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String faturaId;

  @HiveField(2)
  double valor;

  @HiveField(3)
  String meioPagamento;

  @HiveField(4)
  DateTime dataPagamento;

  @HiveField(5)
  String? referencia;

  @HiveField(6)
  String? observacoes;

  @HiveField(7)
  DateTime dataCriacao;

  PagamentoModel({
    required this.id,
    required this.faturaId,
    required this.valor,
    required this.meioPagamento,
    required this.dataPagamento,
    this.referencia,
    this.observacoes,
    required this.dataCriacao,
  });

  /// Converte de entidade domain para model Hive
  factory PagamentoModel.fromEntity(Pagamento pagamento) {
    return PagamentoModel(
      id: pagamento.id,
      faturaId: pagamento.faturaId,
      valor: pagamento.valor,
      meioPagamento: pagamento.meioPagamento,
      dataPagamento: pagamento.dataPagamento,
      referencia: pagamento.referencia,
      observacoes: pagamento.observacoes,
      dataCriacao: pagamento.dataCriacao,
    );
  }

  /// Converte de model Hive para entidade domain
  Pagamento toEntity() {
    return Pagamento(
      id: id,
      faturaId: faturaId,
      valor: valor,
      meioPagamento: meioPagamento,
      dataPagamento: dataPagamento,
      referencia: referencia,
      observacoes: observacoes,
      dataCriacao: dataCriacao,
    );
  }

  /// Converte de JSON
  factory PagamentoModel.fromJson(Map<String, dynamic> json) {
    return PagamentoModel(
      id: json['id'] as String,
      faturaId: json['faturaId'] as String,
      valor: (json['valor'] as num).toDouble(),
      meioPagamento: json['meioPagamento'] as String,
      dataPagamento: DateTime.parse(json['dataPagamento'] as String),
      referencia: json['referencia'] as String?,
      observacoes: json['observacoes'] as String?,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faturaId': faturaId,
      'valor': valor,
      'meioPagamento': meioPagamento,
      'dataPagamento': dataPagamento.toIso8601String(),
      'referencia': referencia,
      'observacoes': observacoes,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }
}
