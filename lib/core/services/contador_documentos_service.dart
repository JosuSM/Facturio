import 'package:hive_flutter/hive_flutter.dart';

/// Serviço responsável por gerenciar contadores de documentos por série.
/// 
/// Garante que cada série tenha uma sequência contínua de números sem lacunas,
/// conforme exigido pela legislação portuguesa.
class ContadorDocumentosService {
  static const String _boxName = 'contadores_documentos';
  
  /// Obtém o próximo número disponível para uma dada série e ano.
  /// 
  /// Retorna o número atual e incrementa o contador automaticamente.
  /// 
  /// Exemplo:
  /// ```dart
  /// final numero = await ContadorDocumentosService.obterProximoNumero('A', 2024);
  /// // Primeira chamada retorna 1, segunda retorna 2, etc.
  /// ```
  static Future<int> obterProximoNumero(String serie, int ano) async {
    final box = await _getBox();
    final chave = _gerarChave(serie, ano);
    
    // Obter número atual (padrão 0)
    final numeroAtual = box.get(chave, defaultValue: 0) as int;
    
    // Incrementar e guardar
    final proximoNumero = numeroAtual + 1;
    await box.put(chave, proximoNumero);
    
    return proximoNumero;
  }
  
  /// Obtém o último número usado para uma série e ano (sem incrementar).
  /// 
  /// Útil para consultas e relatórios.
  static Future<int> obterUltimoNumero(String serie, int ano) async {
    final box = await _getBox();
    final chave = _gerarChave(serie, ano);
    return box.get(chave, defaultValue: 0) as int;
  }
  
  /// Define manualmente o contador para uma série e ano.
  /// 
  /// **ATENÇÃO**: Use com cuidado! Apenas para migração de dados ou correções.
  static Future<void> definirContador(String serie, int ano, int valor) async {
    final box = await _getBox();
    final chave = _gerarChave(serie, ano);
    await box.put(chave, valor);
  }
  
  /// Lista todas as séries com contadores ativos.
  /// 
  /// Retorna um mapa com chaves no formato "SERIE_ANO" e valores dos contadores.
  static Future<Map<String, int>> listarContadores() async {
    final box = await _getBox();
    final contadores = <String, int>{};
    
    for (var key in box.keys) {
      final valor = box.get(key);
      if (valor is int) {
        contadores[key.toString()] = valor;
      }
    }
    
    return contadores;
  }
  
  /// Reseta o contador de uma série específica (define como 0).
  /// 
  /// **ATENÇÃO**: Esta operação é irreversível e pode causar problemas legais
  /// se houver documentos já emitidos nessa série.
  static Future<void> resetarContador(String serie, int ano) async {
    final box = await _getBox();
    final chave = _gerarChave(serie, ano);
    await box.put(chave, 0);
  }
  
  /// Obtém ou cria a box Hive para armazenar contadores.
  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }
  
  /// Gera uma chave única para série e ano.
  /// 
  /// Formato: "SERIE_ANO" (ex: "A_2024", "FT_2024")
  static String _gerarChave(String serie, int ano) {
    return '${serie.toUpperCase()}_$ano';
  }
  
  /// Fecha a box de contadores (útil para testes).
  static Future<void> fecharBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box(_boxName).close();
    }
  }
  
  /// Limpa todos os contadores (útil para testes).
  /// 
  /// **ATENÇÃO**: Esta operação é irreversível!
  static Future<void> limparTodosContadores() async {
    final box = await _getBox();
    await box.clear();
  }
}
