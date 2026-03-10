import 'package:hive/hive.dart';
import '../../../../shared/models/linha_fatura.dart';
import '../../domain/entities/fatura.dart';

part 'fatura_model.g.dart';

@HiveType(typeId: 2)
class FaturaModel extends Fatura {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String numero;

  @HiveField(2)
  @override
  final DateTime data;

  @HiveField(3)
  @override
  final String clienteId;

  @HiveField(4)
  @override
  final String clienteNome;

  @HiveField(5)
  @override
  final List<LinhaFatura> linhas;

  @HiveField(6)
  @override
  final String estado;

  // Novos campos (HiveField 7+)
  @HiveField(7)
  @override
  final String? clienteNif;

  @HiveField(8)
  @override
  final String? clienteMorada;

  @HiveField(9)
  @override
  final String tipoDocumento;

  @HiveField(10)
  @override
  final String serie;

  @HiveField(11)
  @override
  final String? codigoATCUD;

  @HiveField(12)
  @override
  final String? hashAnterior;

  @HiveField(13)
  @override
  final String? qrCodeData;

  @HiveField(14)
  @override
  final String? meioPagamento;

  @HiveField(15)
  @override
  final DateTime? dataPagamento;

  @HiveField(16)
  @override
  final double? valorPago;

  @HiveField(17)
  @override
  final double? retencaoFonte;

  @HiveField(18)
  @override
  final double? valorRetencao;

  @HiveField(19)
  @override
  final String? motivoIsencaoIVA;

  @HiveField(20)
  @override
  final String? observacoes;

  @HiveField(21)
  @override
  final String? notasInternas;

  @HiveField(22)
  @override
  final String? documentoOrigem;

  @HiveField(23)
  @override
  final String? numeroDocumentoOrigem;

  @HiveField(24)
  @override
  final DateTime dataCriacao;

  @HiveField(25)
  @override
  final DateTime? dataUltimaAlteracao;

  FaturaModel({
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
  }) : super(
          id: id,
          numero: numero,
          data: data,
          clienteId: clienteId,
          clienteNome: clienteNome,
          clienteNif: clienteNif,
          clienteMorada: clienteMorada,
          linhas: linhas,
          estado: estado,
          tipoDocumento: tipoDocumento,
          serie: serie,
          codigoATCUD: codigoATCUD,
          hashAnterior: hashAnterior,
          qrCodeData: qrCodeData,
          meioPagamento: meioPagamento,
          dataPagamento: dataPagamento,
          valorPago: valorPago,
          retencaoFonte: retencaoFonte,
          valorRetencao: valorRetencao,
          motivoIsencaoIVA: motivoIsencaoIVA,
          observacoes: observacoes,
          notasInternas: notasInternas,
          documentoOrigem: documentoOrigem,
          numeroDocumentoOrigem: numeroDocumentoOrigem,
          dataCriacao: dataCriacao,
          dataUltimaAlteracao: dataUltimaAlteracao,
        );

  factory FaturaModel.fromEntity(Fatura fatura) {
    return FaturaModel(
      id: fatura.id,
      numero: fatura.numero,
      data: fatura.data,
      clienteId: fatura.clienteId,
      clienteNome: fatura.clienteNome,
      clienteNif: fatura.clienteNif,
      clienteMorada: fatura.clienteMorada,
      linhas: fatura.linhas,
      estado: fatura.estado,
      tipoDocumento: fatura.tipoDocumento,
      serie: fatura.serie,
      codigoATCUD: fatura.codigoATCUD,
      hashAnterior: fatura.hashAnterior,
      qrCodeData: fatura.qrCodeData,
      meioPagamento: fatura.meioPagamento,
      dataPagamento: fatura.dataPagamento,
      valorPago: fatura.valorPago,
      retencaoFonte: fatura.retencaoFonte,
      valorRetencao: fatura.valorRetencao,
      motivoIsencaoIVA: fatura.motivoIsencaoIVA,
      observacoes: fatura.observacoes,
      notasInternas: fatura.notasInternas,
      documentoOrigem: fatura.documentoOrigem,
      numeroDocumentoOrigem: fatura.numeroDocumentoOrigem,
      dataCriacao: fatura.dataCriacao,
      dataUltimaAlteracao: fatura.dataUltimaAlteracao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'data': data.toIso8601String(),
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteNif': clienteNif,
      'clienteMorada': clienteMorada,
      'linhas': linhas.map((l) => l.toJson()).toList(),
      'estado': estado,
      'tipoDocumento': tipoDocumento,
      'serie': serie,
      'codigoATCUD': codigoATCUD,
      'hashAnterior': hashAnterior,
      'qrCodeData': qrCodeData,
      'meioPagamento': meioPagamento,
      'dataPagamento': dataPagamento?.toIso8601String(),
      'valorPago': valorPago,
      'retencaoFonte': retencaoFonte,
      'valorRetencao': valorRetencao,
      'motivoIsencaoIVA': motivoIsencaoIVA,
      'observacoes': observacoes,
      'notasInternas': notasInternas,
      'documentoOrigem': documentoOrigem,
      'numeroDocumentoOrigem': numeroDocumentoOrigem,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataUltimaAlteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  factory FaturaModel.fromJson(Map<String, dynamic> json) {
    return FaturaModel(
      id: json['id'],
      numero: json['numero'],
      data: DateTime.parse(json['data']),
      clienteId: json['clienteId'],
      clienteNome: json['clienteNome'],
      clienteNif: json['clienteNif'],
      clienteMorada: json['clienteMorada'],
      linhas: (json['linhas'] as List)
          .map((l) => LinhaFatura.fromJson(l))
          .toList(),
      estado: json['estado'],
      tipoDocumento: json['tipoDocumento'] ?? 'Fatura',
      serie: json['serie'] ?? 'A',
      codigoATCUD: json['codigoATCUD'],
      hashAnterior: json['hashAnterior'],
      qrCodeData: json['qrCodeData'],
      meioPagamento: json['meioPagamento'],
      dataPagamento: json['dataPagamento'] != null
          ? DateTime.parse(json['dataPagamento'])
          : null,
      valorPago: json['valorPago']?.toDouble(),
      retencaoFonte: json['retencaoFonte']?.toDouble(),
      valorRetencao: json['valorRetencao']?.toDouble(),
      motivoIsencaoIVA: json['motivoIsencaoIVA'],
      observacoes: json['observacoes'],
      notasInternas: json['notasInternas'],
      documentoOrigem: json['documentoOrigem'],
      numeroDocumentoOrigem: json['numeroDocumentoOrigem'],
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : DateTime.now(),
      dataUltimaAlteracao: json['dataUltimaAlteracao'] != null
          ? DateTime.parse(json['dataUltimaAlteracao'])
          : null,
    );
  }
}
