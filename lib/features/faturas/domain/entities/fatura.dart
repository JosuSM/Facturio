import '../../../../shared/models/linha_fatura.dart';

class Fatura {
  final String id;
  final String numero;
  final DateTime data;
  final String clienteId;
  final String clienteNome;
  final String? clienteNif; // NIF do cliente (obrigatório em faturas)
  final String? clienteMorada; // Morada do cliente
  final List<LinhaFatura> linhas;
  final String estado; // rascunho, emitida, paga, cancelada
  
  // Tipo de documento (legal requirement)
  final String tipoDocumento; // Fatura, Fatura Simplificada, etc.
  final String serie; // Série do documento (ex: A, B, 2024, etc.)
  
  // Certificação AT (Autoridade Tributária)
  final String? codigoATCUD; // Código único do documento (AT)
  final String? hashAnterior; // Hash do documento anterior (para validação sequencial)
  final String? qrCodeData; // Dados para QR Code da AT
  
  // Pagamento
  final String? meioPagamento; // Como foi pago
  final DateTime? dataPagamento; // Quando foi pago
  final double? valorPago; // Valor efetivamente pago
  
  // Dados financeiros adicionais
  final double? retencaoFonte; // Retenção na fonte (%)
  final double? valorRetencao; // Valor retido
  final String? motivoIsencaoIVA; // Motivo de isenção (se aplicável)
  
  // Observações e notas
  final String? observacoes; // Observações gerais
  final String? notasInternas; // Notas internas (não aparecem no PDF)
  
  // Referências de documentos relacionados
  final String? documentoOrigem; // ID do documento original (para notas de crédito/débito)
  final String? numeroDocumentoOrigem; // Número do documento original
  
  // Metadata
  final DateTime dataCriacao;
  final DateTime? dataUltimaAlteracao;

  Fatura({
    required this.id,
    required this.numero,
    required this.data,
    required this.clienteId,
    required this.clienteNome,
    this.clienteNif,
    this.clienteMorada,
    required this.linhas,
    required this.estado,
    required this.tipoDocumento,
    required this.serie,
    this.codigoATCUD,
    this.hashAnterior,
    this.qrCodeData,
    this.meioPagamento,
    this.dataPagamento,
    this.valorPago,
    this.retencaoFonte,
    this.valorRetencao,
    this.motivoIsencaoIVA,
    this.observacoes,
    this.notasInternas,
    this.documentoOrigem,
    this.numeroDocumentoOrigem,
    required this.dataCriacao,
    this.dataUltimaAlteracao,
  });

  double get subtotal => linhas.fold(0, (sum, linha) => sum + linha.subtotal);
  double get totalIva => linhas.fold(0, (sum, linha) => sum + linha.valorIva);
  double get total => linhas.fold(0, (sum, linha) => sum + linha.total);
  
  // Total com retenção aplicada
  double get totalComRetencao {
    final totalBase = total;
    if (valorRetencao != null && valorRetencao! > 0) {
      return totalBase - valorRetencao!;
    }
    return totalBase;
  }
  
  // Verifica se a fatura está paga
  bool get estaPaga => estado == 'paga';
  
  // Verifica se tem isenção de IVA
  bool get temIsencaoIVA => motivoIsencaoIVA != null && motivoIsencaoIVA!.isNotEmpty;

  Fatura copyWith({
    String? id,
    String? numero,
    DateTime? data,
    String? clienteId,
    String? clienteNome,
    String? clienteNif,
    String? clienteMorada,
    List<LinhaFatura>? linhas,
    String? estado,
    String? tipoDocumento,
    String? serie,
    String? codigoATCUD,
    String? hashAnterior,
    String? qrCodeData,
    String? meioPagamento,
    DateTime? dataPagamento,
    double? valorPago,
    double? retencaoFonte,
    double? valorRetencao,
    String? motivoIsencaoIVA,
    String? observacoes,
    String? notasInternas,
    String? documentoOrigem,
    String? numeroDocumentoOrigem,
    DateTime? dataCriacao,
    DateTime? dataUltimaAlteracao,
  }) {
    return Fatura(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      data: data ?? this.data,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteNif: clienteNif ?? this.clienteNif,
      clienteMorada: clienteMorada ?? this.clienteMorada,
      linhas: linhas ?? this.linhas,
      estado: estado ?? this.estado,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      serie: serie ?? this.serie,
      codigoATCUD: codigoATCUD ?? this.codigoATCUD,
      hashAnterior: hashAnterior ?? this.hashAnterior,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      meioPagamento: meioPagamento ?? this.meioPagamento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      valorPago: valorPago ?? this.valorPago,
      retencaoFonte: retencaoFonte ?? this.retencaoFonte,
      valorRetencao: valorRetencao ?? this.valorRetencao,
      motivoIsencaoIVA: motivoIsencaoIVA ?? this.motivoIsencaoIVA,
      observacoes: observacoes ?? this.observacoes,
      notasInternas: notasInternas ?? this.notasInternas,
      documentoOrigem: documentoOrigem ?? this.documentoOrigem,
      numeroDocumentoOrigem: numeroDocumentoOrigem ?? this.numeroDocumentoOrigem,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
