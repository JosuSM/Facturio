/// Entidade que representa um pagamento de uma fatura.
/// 
/// Suporta múltiplos pagamentos parciais para a mesma fatura,
/// permitindo rastreamento completo do histórico de pagamentos.
class Pagamento {
  final String id;
  final String faturaId; // Referência à fatura
  final double valor; // Valor deste pagamento
  final String meioPagamento; // Como foi pago
  final DateTime dataPagamento; // Quando foi realizado
  final String? referencia; // Número do cheque, referência de transferência, etc.
  final String? observacoes; // Notas adicionais
  final DateTime dataCriacao; // Quando foi registado

  const Pagamento({
    required this.id,
    required this.faturaId,
    required this.valor,
    required this.meioPagamento,
    required this.dataPagamento,
    this.referencia,
    this.observacoes,
    required this.dataCriacao,
  });

  /// Cria cópia com campos atualizados
  Pagamento copyWith({
    String? id,
    String? faturaId,
    double? valor,
    String? meioPagamento,
    DateTime? dataPagamento,
    String? referencia,
    String? observacoes,
    DateTime? dataCriacao,
  }) {
    return Pagamento(
      id: id ?? this.id,
      faturaId: faturaId ?? this.faturaId,
      valor: valor ?? this.valor,
      meioPagamento: meioPagamento ?? this.meioPagamento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      referencia: referencia ?? this.referencia,
      observacoes: observacoes ?? this.observacoes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  /// Converte para Map (JSON)
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

  /// Cria a partir de Map (JSON)
  factory Pagamento.fromJson(Map<String, dynamic> json) {
    return Pagamento(
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

  @override
  String toString() {
    return 'Pagamento(id: $id, faturaId: $faturaId, valor: €${valor.toStringAsFixed(2)}, meio: $meioPagamento, data: $dataPagamento)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Pagamento &&
      other.id == id &&
      other.faturaId == faturaId &&
      other.valor == valor &&
      other.meioPagamento == meioPagamento &&
      other.dataPagamento == dataPagamento &&
      other.referencia == referencia &&
      other.observacoes == observacoes &&
      other.dataCriacao == dataCriacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      faturaId.hashCode ^
      valor.hashCode ^
      meioPagamento.hashCode ^
      dataPagamento.hashCode ^
      referencia.hashCode ^
      observacoes.hashCode ^
      dataCriacao.hashCode;
  }
}
