import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Serviço para funcionalidades legais de faturação em Portugal
/// 
/// IMPORTANTE: Esta é uma implementação SIMULADA para fins educativos e testes.
/// Para uso EM PRODUÇÃO numa empresa REAL, é OBRIGATÓRIO:
/// 1. Certificar o software junto da AT (Autoridade Tributária e Aduaneira)
/// 2. Obter chaves de certificação AT reais
/// 3. Integrar com os webservices da AT para geração de códigos ATCUD oficiais
/// 4. Implementar o sistema de comunicação de documentos à AT
/// 
/// A não certificação do software é uma CONTRAORDENAÇÃO GRAVE segundo a lei portuguesa.
class FaturaLegalService {
  /// Gera um código ATCUD simulado
  /// 
  /// ATENÇÃO: Este código é SIMULADO e NÃO VÁLIDO para uso legal real!
  /// Em produção, deve ser obtido através da AT.
  /// 
  /// Formato ATCUD: [Código de validação AT]-[Número sequencial]
  /// Exemplo: ABCD1234-5678
  static String gerarATCUDSimulado(String serie, int numeroSequencial) {
    // SIMULAÇÃO - Em produção, isto viria da AT
    final codigoValidacao = 'SIM${serie.hashCode.abs() % 10000}';
    return '$codigoValidacao-$numeroSequencial';
  }

  /// Gera hash SHA-256 para validação de sequência de documentos
  /// 
  /// Este hash garante que os documentos não foram alterados ou eliminados
  /// e mantêm a sequência obrigatória por lei.
  static String gerarHashDocumento({
    required String numeroDocumento,
    required DateTime data,
    required double total,
    String? hashAnterior,
  }) {
    final dados = StringBuffer();
    dados.write(numeroDocumento);
    dados.write(data.toIso8601String());
    dados.write(total.toStringAsFixed(2));
    
    if (hashAnterior != null && hashAnterior.isNotEmpty) {
      dados.write(hashAnterior);
    }
    
    final bytes = utf8.encode(dados.toString());
    final hash = sha256.convert(bytes);
    
    return hash.toString().substring(0, 40); // Primeiros 40 caracteres
  }

  /// Gera dados para QR Code segundo especificações da AT
  /// 
  /// Formato: NIF Emissor*NIF Adquirente*País*Tipo Doc*Estado*Data*Nº Doc*ATCUD*Subtotal*IVA*Total*Hash
  /// 
  /// Nota: Este é o formato simplificado. O formato completo da AT pode ter mais campos.
  static String gerarDadosQRCode({
    required String nifEmissor,
    required String? nifAdquirente,
    required String tipoDocumento,
    required DateTime data,
    required String numeroDocumento,
    required String codigoATCUD,
    required double subtotal,
    required double totalIVA,
    required double total,
    String pais = 'PT',
  }) {
    final buffer = StringBuffer();
    
    buffer.write(nifEmissor);
    buffer.write('*');
    buffer.write(nifAdquirente ?? '999999990');
    buffer.write('*');
    buffer.write(pais);
    buffer.write('*');
    buffer.write(_getTipoDocumentoCode(tipoDocumento));
    buffer.write('*');
    buffer.write('N'); // N = Normal, A = Anulado
    buffer.write('*');
    buffer.write(_formatarData(data));
    buffer.write('*');
    buffer.write(numeroDocumento);
    buffer.write('*');
    buffer.write(codigoATCUD);
    buffer.write('*');
    buffer.write(subtotal.toStringAsFixed(2));
    buffer.write('*');
    buffer.write(totalIVA.toStringAsFixed(2));
    buffer.write('*');
    buffer.write(total.toStringAsFixed(2));
    
    return buffer.toString();
  }

  /// Obtém o código do tipo de documento para o QR Code
  static String _getTipoDocumentoCode(String tipoDocumento) {
    switch (tipoDocumento) {
      case 'Fatura':
        return 'FT';
      case 'Fatura Simplificada':
        return 'FS';
      case 'Fatura-Recibo':
        return 'FR';
      case 'Nota de Crédito':
        return 'NC';
      case 'Nota de Débito':
        return 'ND';
      default:
        return 'FT';
    }
  }

  /// Formata data para o QR Code (YYYYMMDD)
  static String _formatarData(DateTime data) {
    return '${data.year}${data.month.toString().padLeft(2, '0')}${data.day.toString().padLeft(2, '0')}';
  }

  /// Gera o próximo número de documento na série
  /// 
  /// Formato: SERIE ANO/NUMERO
  /// Exemplos: A 2024/1, A 2024/2, B 2024/1
  static String gerarNumeroDocumento({
    required String serie,
    required int ano,
    required int numeroSequencial,
  }) {
    return '$serie $ano/$numeroSequencial';
  }

  /// Extrai o número sequencial de um número de documento
  /// Retorna null se o formato for inválido
  static int? extrairNumeroSequencial(String numeroDocumento) {
    try {
      // Formato esperado: "SERIE ANO/NUMERO"
      final partes = numeroDocumento.split('/');
      if (partes.length == 2) {
        return int.tryParse(partes[1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Valida se um NIF português é válido
  /// 
  /// Verifica:
  /// - Tem 9 dígitos
  /// - Primeiro dígito é válido (1, 2, 3, 5, 6, 7, 8, 9)
  /// - Dígito de controlo está correto
  static bool validarNIF(String nif) {
    if (nif.length != 9) return false;
    
    final primeiroDigito = int.tryParse(nif[0]);
    if (primeiroDigito == null) return false;
    
    // Primeiros dígitos válidos
    if (![1, 2, 3, 5, 6, 7, 8, 9].contains(primeiroDigito)) {
      return false;
    }
    
    // Calcular dígito de controlo
    int soma = 0;
    for (int i = 0; i < 8; i++) {
      final digito = int.tryParse(nif[i]);
      if (digito == null) return false;
      soma += digito * (9 - i);
    }
    
    final resto = soma % 11;
    final digitoControlo = resto < 2 ? 0 : 11 - resto;
    
    final ultimoDigito = int.tryParse(nif[8]);
    return ultimoDigito == digitoControlo;
  }

  /// Calcula o valor da retenção na fonte
  /// 
  /// Taxa padrão de retenção (para prestação de serviços): 25%
  /// Outros casos podem ter taxas diferentes
  static double calcularRetencao({
    required double valorBase,
    required double taxaRetencao, // Percentagem (ex: 25.0 para 25%)
  }) {
    return valorBase * (taxaRetencao / 100);
  }

  /// Valida código postal português (XXXX-XXX)
  static bool validarCodigoPostal(String codigoPostal) {
    final regex = RegExp(r'^\d{4}-\d{3}$');
    return regex.hasMatch(codigoPostal);
  }
}
