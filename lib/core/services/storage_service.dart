import 'package:hive_flutter/hive_flutter.dart';
import '../../features/clientes/data/models/cliente_model.dart';
import '../../features/produtos/data/models/produto_model.dart';
import '../../features/faturas/data/models/fatura_model.dart';
import '../../features/pagamentos/data/models/pagamento_model.dart';
import '../../shared/models/linha_fatura.dart';
import '../../shared/models/pagamento.dart';
import '../constants/app_constants.dart';
import '../models/configuracao_empresa.dart';

class StorageService {
  static late Box<ClienteModel> _clientesBox;
  static late Box<ProdutoModel> _produtosBox;
  static late Box<FaturaModel> _faturasBox;
  static late Box<PagamentoModel> _pagamentosBox;
  static late Box<dynamic> _configBox;

  // Inicializar Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar Adapters
    Hive.registerAdapter(ClienteModelAdapter());
    Hive.registerAdapter(ProdutoModelAdapter());
    Hive.registerAdapter(LinhaFaturaAdapter());
    Hive.registerAdapter(FaturaModelAdapter());
    Hive.registerAdapter(PagamentoModelAdapter());

    // Abrir Boxes
    _clientesBox = await Hive.openBox<ClienteModel>(AppConstants.clientesBox);
    _produtosBox = await Hive.openBox<ProdutoModel>(AppConstants.produtosBox);
    _faturasBox = await Hive.openBox<FaturaModel>(AppConstants.faturasBox);
    _pagamentosBox = await Hive.openBox<PagamentoModel>('pagamentos');
    _configBox = await Hive.openBox<dynamic>(AppConstants.configBox);

    if (!_configBox.containsKey('empresa_config')) {
      await _configBox.put('empresa_config', ConfiguracaoEmpresa.padrao().toJson());
    }
  }

  // ===== CLIENTES =====
  Future<List<ClienteModel>> getClientes() async {
    return _clientesBox.values.toList();
  }

  Future<ClienteModel?> getCliente(String id) async {
    return _clientesBox.get(id);
  }

  Future<void> saveCliente(ClienteModel cliente) async {
    await _clientesBox.put(cliente.id, cliente);
  }

  Future<void> deleteCliente(String id) async {
    await _clientesBox.delete(id);
  }

  // ===== PRODUTOS =====
  Future<List<ProdutoModel>> getProdutos() async {
    return _produtosBox.values.toList();
  }

  Future<ProdutoModel?> getProduto(String id) async {
    return _produtosBox.get(id);
  }

  Future<void> saveProduto(ProdutoModel produto) async {
    await _produtosBox.put(produto.id, produto);
  }

  Future<void> deleteProduto(String id) async {
    await _produtosBox.delete(id);
  }

  // ===== FATURAS =====
  Future<List<FaturaModel>> getFaturas() async {
    return _faturasBox.values.toList();
  }

  Future<FaturaModel?> getFatura(String id) async {
    return _faturasBox.get(id);
  }

  Future<void> saveFatura(FaturaModel fatura) async {
    await _faturasBox.put(fatura.id, fatura);
  }

  Future<void> deleteFatura(String id) async {
    await _faturasBox.delete(id);
  }

  // Obter próximo número de fatura
  Future<String> getProximoNumeroFatura() async {
    final faturas = await getFaturas();
    final ano = DateTime.now().year;
    
    // Filtrar faturas do ano atual
    final faturasAno = faturas.where((f) => f.data.year == ano).toList();
    
    if (faturasAno.isEmpty) {
      return '$ano/001';
    }
    
    // Extrair números e encontrar o maior
    final numeros = faturasAno.map((f) {
      final parts = f.numero.split('/');
      return int.tryParse(parts.last) ?? 0;
    }).toList();
    
    final maiorNumero = numeros.reduce((a, b) => a > b ? a : b);
    final proximoNumero = (maiorNumero + 1).toString().padLeft(3, '0');
    
    return '$ano/$proximoNumero';
  }

  // ===== PAGAMENTOS =====
  Future<List<Pagamento>> getPagamentos() async {
    final models = _pagamentosBox.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<Pagamento>> getPagamentosPorFatura(String faturaId) async {
    final todosPagamentos = await getPagamentos();
    return todosPagamentos.where((p) => p.faturaId == faturaId).toList();
  }

  Future<Pagamento?> getPagamento(String id) async {
    final model = _pagamentosBox.get(id);
    return model?.toEntity();
  }

  Future<void> savePagamento(Pagamento pagamento) async {
    final model = PagamentoModel.fromEntity(pagamento);
    await _pagamentosBox.put(pagamento.id, model);
  }

  Future<void> updatePagamento(Pagamento pagamento) async {
    final model = PagamentoModel.fromEntity(pagamento);
    await _pagamentosBox.put(pagamento.id, model);
  }

  Future<void> deletePagamento(String id) async {
    await _pagamentosBox.delete(id);
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    await _clientesBox.clear();
    await _produtosBox.clear();
    await _faturasBox.clear();
    await _pagamentosBox.clear();
  }

  Future<ConfiguracaoEmpresa> getConfiguracaoEmpresa() async {
    final data = _configBox.get('empresa_config');
    if (data is Map) {
      return ConfiguracaoEmpresa.fromJson(Map<String, dynamic>.from(data));
    }

    final padrao = ConfiguracaoEmpresa.padrao();
    await _configBox.put('empresa_config', padrao.toJson());
    return padrao;
  }

  Future<void> saveConfiguracaoEmpresa(ConfiguracaoEmpresa config) async {
    await _configBox.put('empresa_config', config.toJson());
  }
}
