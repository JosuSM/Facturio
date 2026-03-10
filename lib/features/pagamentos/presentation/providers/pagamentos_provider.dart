import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/models/pagamento.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import 'package:uuid/uuid.dart';

/// Provider para gerir o estado dos pagamentos.
final pagamentosProvider =
    StateNotifierProvider<PagamentosNotifier, AsyncValue<Map<String, List<Pagamento>>>>(
  (ref) => PagamentosNotifier(ref.read(storageServiceProvider)),
);

/// Notifier para gerir operações CRUD de pagamentos.
class PagamentosNotifier extends StateNotifier<AsyncValue<Map<String, List<Pagamento>>>> {
  final StorageService _storageService;
  final _uuid = const Uuid();

  PagamentosNotifier(this._storageService) : super(const AsyncValue.loading()) {
    carregarPagamentos();
  }

  /// Carrega todos os pagamentos do storage e agrupa por faturaId.
  Future<void> carregarPagamentos() async {
    state = const AsyncValue.loading();
    try {
      final pagamentos = await _storageService.getPagamentos();
      final agrupados = <String, List<Pagamento>>{};

      for (final pagamento in pagamentos) {
        agrupados.putIfAbsent(pagamento.faturaId, () => []).add(pagamento);
      }

      // Ordena cada lista por data decrescente
      for (final lista in agrupados.values) {
        lista.sort((a, b) => b.dataPagamento.compareTo(a.dataPagamento));
      }

      state = AsyncValue.data(agrupados);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Retorna os pagamentos de uma fatura específica.
  List<Pagamento> getPagamentosPorFatura(String faturaId) {
    return state.value?[faturaId] ?? [];
  }

  /// Adiciona um novo pagamento para uma fatura.
  Future<void> adicionarPagamento({
    required String faturaId,
    required double valor,
    required String meioPagamento,
    required DateTime dataPagamento,
    String? referencia,
    String? observacoes,
  }) async {
    final novoPagamento = Pagamento(
      id: _uuid.v4(),
      faturaId: faturaId,
      valor: valor,
      meioPagamento: meioPagamento,
      dataPagamento: dataPagamento,
      referencia: referencia,
      observacoes: observacoes,
      dataCriacao: DateTime.now(),
    );

    // Salva no storage
    await _storageService.savePagamento(novoPagamento);

    // Atualiza o estado local
    state.whenData((pagamentos) {
      final novoMapa = Map<String, List<Pagamento>>.from(pagamentos);
      final listaPagamentos = List<Pagamento>.from(novoMapa[faturaId] ?? []);
      listaPagamentos.add(novoPagamento);
      listaPagamentos.sort((a, b) => b.dataPagamento.compareTo(a.dataPagamento));
      novoMapa[faturaId] = listaPagamentos;
      state = AsyncValue.data(novoMapa);
    });
  }

  /// Atualiza um pagamento existente.
  Future<void> atualizarPagamento(Pagamento pagamento) async {
    await _storageService.updatePagamento(pagamento);

    state.whenData((pagamentos) {
      final novoMapa = Map<String, List<Pagamento>>.from(pagamentos);
      final listaPagamentos = List<Pagamento>.from(novoMapa[pagamento.faturaId] ?? []);
      final index = listaPagamentos.indexWhere((p) => p.id == pagamento.id);
      
      if (index != -1) {
        listaPagamentos[index] = pagamento;
        listaPagamentos.sort((a, b) => b.dataPagamento.compareTo(a.dataPagamento));
        novoMapa[pagamento.faturaId] = listaPagamentos;
        state = AsyncValue.data(novoMapa);
      }
    });
  }

  /// Remove um pagamento.
  Future<void> removerPagamento(String id, String faturaId) async {
    await _storageService.deletePagamento(id);

    state.whenData((pagamentos) {
      final novoMapa = Map<String, List<Pagamento>>.from(pagamentos);
      final listaPagamentos = List<Pagamento>.from(novoMapa[faturaId] ?? []);
      listaPagamentos.removeWhere((p) => p.id == id);
      
      if (listaPagamentos.isEmpty) {
        novoMapa.remove(faturaId);
      } else {
        novoMapa[faturaId] = listaPagamentos;
      }
      
      state = AsyncValue.data(novoMapa);
    });
  }

  /// Retorna todos os pagamentos (não agrupados).
  List<Pagamento> getTodosPagamentos() {
    final todosOsPagamentos = <Pagamento>[];
    state.value?.forEach((_, listaPagamentos) {
      todosOsPagamentos.addAll(listaPagamentos);
    });
    todosOsPagamentos.sort((a, b) => b.dataPagamento.compareTo(a.dataPagamento));
    return todosOsPagamentos;
  }

  /// Retorna o total de pagamentos registados.
  int getTotalPagamentos() {
    return getTodosPagamentos().length;
  }
}
