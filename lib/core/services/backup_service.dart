import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/clientes/data/models/cliente_model.dart';
import '../../features/faturas/data/models/fatura_model.dart';
import '../../features/produtos/data/models/produto_model.dart';
import '../models/configuracao_empresa.dart';
import 'storage_service.dart';

class BackupResultado {
  final int clientes;
  final int produtos;
  final int faturas;

  const BackupResultado({
    required this.clientes,
    required this.produtos,
    required this.faturas,
  });
}

class BackupService {
  static Future<File> criarFicheiroBackup(StorageService storage) async {
    final clientes = await storage.getClientes();
    final produtos = await storage.getProdutos();
    final faturas = await storage.getFaturas();
    final configEmpresa = await storage.getConfiguracaoEmpresa();

    final payload = {
      'versao': 1,
      'geradoEm': DateTime.now().toIso8601String(),
      'clientes': clientes.map((c) => c.toJson()).toList(),
      'produtos': produtos.map((p) => p.toJson()).toList(),
      'faturas': faturas.map((f) => f.toJson()).toList(),
      'configEmpresa': configEmpresa.toJson(),
    };

    final nome = 'facturio_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final ficheiro = File('${Directory.systemTemp.path}/$nome');
    await ficheiro.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return ficheiro;
  }

  static Future<void> partilharBackup(StorageService storage) async {
    final ficheiro = await criarFicheiroBackup(storage);
    await Share.shareXFiles(
      [XFile(ficheiro.path)],
      text: 'Backup do Facturio. Guarde este ficheiro em segurança (Drive, cloud ou PC).',
      subject: 'Backup Facturio',
    );
  }

  static Future<BackupResultado?> selecionarERestaurar(StorageService storage) async {
    final resultadoPicker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: false,
    );

    final path = resultadoPicker?.files.single.path;
    if (path == null) {
      return null;
    }

    return restaurarFicheiro(storage, path);
  }

  static Future<BackupResultado> restaurarFicheiro(StorageService storage, String path) async {
    final ficheiro = File(path);
    if (!await ficheiro.exists()) {
      throw Exception('O ficheiro de backup não foi encontrado.');
    }

    final conteudo = await ficheiro.readAsString();
    final json = jsonDecode(conteudo);
    if (json is! Map<String, dynamic>) {
      throw Exception('Formato de backup inválido.');
    }

    final clientesJson = (json['clientes'] as List?) ?? const [];
    final produtosJson = (json['produtos'] as List?) ?? const [];
    final faturasJson = (json['faturas'] as List?) ?? const [];
    final configEmpresa = json['configEmpresa'];

    await storage.clearAll();

    for (final item in clientesJson) {
      await storage.saveCliente(ClienteModel.fromJson(Map<String, dynamic>.from(item)));
    }

    for (final item in produtosJson) {
      await storage.saveProduto(ProdutoModel.fromJson(Map<String, dynamic>.from(item)));
    }

    for (final item in faturasJson) {
      await storage.saveFatura(FaturaModel.fromJson(Map<String, dynamic>.from(item)));
    }

    if (configEmpresa is Map) {
      await storage.saveConfiguracaoEmpresa(
        ConfiguracaoEmpresa.fromJson(Map<String, dynamic>.from(configEmpresa)),
      );
    }

    return BackupResultado(
      clientes: clientesJson.length,
      produtos: produtosJson.length,
      faturas: faturasJson.length,
    );
  }
}
