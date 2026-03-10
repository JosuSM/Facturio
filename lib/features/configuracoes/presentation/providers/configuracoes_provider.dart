import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/configuracao_empresa.dart';
import '../../../../core/services/storage_service.dart';

final configuracoesProvider =
    StateNotifierProvider<ConfiguracoesNotifier, AsyncValue<ConfiguracaoEmpresa>>((ref) {
  return ConfiguracoesNotifier(StorageService());
});

class ConfiguracoesNotifier extends StateNotifier<AsyncValue<ConfiguracaoEmpresa>> {
  final StorageService _storage;

  ConfiguracoesNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadConfiguracoes();
  }

  Future<void> loadConfiguracoes() async {
    state = const AsyncValue.loading();
    try {
      final config = await _storage.getConfiguracaoEmpresa();
      state = AsyncValue.data(config);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> salvarConfiguracoes(ConfiguracaoEmpresa configuracao) async {
    try {
      await _storage.saveConfiguracaoEmpresa(configuracao);
      state = AsyncValue.data(configuracao);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
