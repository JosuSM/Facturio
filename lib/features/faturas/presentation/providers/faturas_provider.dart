import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/contador_documentos_service.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/fatura_model.dart';
import '../../domain/entities/fatura.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import 'package:uuid/uuid.dart';

// Provider da lista de faturas
final faturasProvider =
    StateNotifierProvider<FaturasNotifier, AsyncValue<List<Fatura>>>((ref) {
  return FaturasNotifier(
    ref.watch(storageServiceProvider),
    ref,
  );
});

class FaturasNotifier extends StateNotifier<AsyncValue<List<Fatura>>> {
  final StorageService _storage;
  final Ref _ref;
  final _uuid = const Uuid();

  FaturasNotifier(this._storage, this._ref) : super(const AsyncValue.loading()) {
    loadFaturas();
  }

  Future<void> loadFaturas() async {
    state = const AsyncValue.loading();
    try {
      final faturas = await _storage.getFaturas();
      // Ordenar por data decrescente
      faturas.sort((a, b) => b.data.compareTo(a.data));
      state = AsyncValue.data(faturas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addFatura(Fatura fatura) async {
    try {
      // Obter configuração da empresa
      final configAsync = _ref.read(configuracoesProvider);
      final config = configAsync.value;
      if (config == null) {
        throw Exception('Configuração da empresa não disponível');
      }

      // Obter próximo número para a série e ano
      final ano = DateTime.now().year;
      final numeroSequencial = await ContadorDocumentosService.obterProximoNumero(
        fatura.serie,
        ano,
      );

      // Gerar número do documento formatado
      final numeroDocumento = FaturaLegalService.gerarNumeroDocumento(
        serie: fatura.serie,
        ano: ano,
        numeroSequencial: numeroSequencial,
      );

      // Gerar código ATCUD (simulado)
      final atcud = FaturaLegalService.gerarATCUDSimulado(
        fatura.serie,
        numeroSequencial,
      );

      // Obter hash do documento anterior (última fatura da mesma série)
      String? hashAnterior;
      final faturasAtuais = state.value ?? [];
      final faturasMessaSerie = faturasAtuais
          .where((f) => f.serie == fatura.serie)
          .toList()
        ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
      
      if (faturasMessaSerie.isNotEmpty) {
        // Último documento da série tem hash? Usar esse
        final ultimaFatura = faturasMessaSerie.first;
        if (ultimaFatura.codigoATCUD != null && ultimaFatura.numero.isNotEmpty) {
          // Hash = SHA256(NumeroDoc + Data + Total + HashAnterior?)
          hashAnterior = FaturaLegalService.gerarHashDocumento(
            numeroDocumento: ultimaFatura.numero,
            data: ultimaFatura.dataCriacao,
            total: ultimaFatura.total,
            hashAnterior: ultimaFatura.hashAnterior,
          );
        }
      }

      // Gerar dados do QR Code
      final qrCodeData = FaturaLegalService.gerarDadosQRCode(
        nifEmissor: config.nif,
        nifAdquirente: fatura.clienteNif,
        tipoDocumento: fatura.tipoDocumento,
        data: DateTime.now(),
        numeroDocumento: numeroDocumento,
        codigoATCUD: atcud,
        subtotal: fatura.subtotal,
        totalIVA: fatura.totalIva,
        total: fatura.total,
        pais: 'PT',
      );
      
      final faturaModel = FaturaModel(
        id: _uuid.v4(),
        numero: numeroDocumento,
        data: DateTime.now(),
        clienteId: fatura.clienteId,
        clienteNome: fatura.clienteNome,
        clienteNif: fatura.clienteNif,
        clienteMorada: fatura.clienteMorada,
        linhas: fatura.linhas,
        estado: fatura.estado,
        tipoDocumento: fatura.tipoDocumento,
        serie: fatura.serie,
        dataCriacao: DateTime.now(),
        // Campos gerados automaticamente
        codigoATCUD: atcud,
        hashAnterior: hashAnterior,
        qrCodeData: qrCodeData,
        // Campos opcionais preservados da fatura original
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
      );
      
      await _storage.saveFatura(faturaModel);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFatura(Fatura fatura) async {
    try {
      final faturaModel = FaturaModel.fromEntity(fatura);
      await _storage.saveFatura(faturaModel);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFatura(String id) async {
    try {
      await _storage.deleteFatura(id);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<Fatura?> getFatura(String id) async {
    return await _storage.getFatura(id);
  }

  Future<void> updateEstado(String id, String novoEstado) async {
    try {
      final fatura = await _storage.getFatura(id);
      if (fatura != null) {
        final faturaAtualizada = fatura.copyWith(estado: novoEstado);
        await _storage.saveFatura(FaturaModel.fromEntity(faturaAtualizada));
        await loadFaturas();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Provider para faturação por período
final faturacaoPorPeriodoProvider = Provider.family<double, DateTime>((ref, data) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) {
      final faturasDoMes = faturas.where((f) {
        return f.data.month == data.month &&
            f.data.year == data.year &&
            f.estado != 'cancelada';
      });
      
      return faturasDoMes.fold(0.0, (sum, f) => sum + f.total);
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

// Provider para total de faturas por estado
final faturasporEstadoProvider = Provider.family<int, String>((ref, estado) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) => faturas.where((f) => f.estado == estado).length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

// Provider para total faturado
final totalFaturadoProvider = Provider<double>((ref) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) {
      final faturasValidas = faturas.where((f) => f.estado != 'cancelada');
      return faturasValidas.fold(0.0, (sum, f) => sum + f.total);
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});
