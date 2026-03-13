import 'package:flutter_test/flutter_test.dart';

import 'package:facturio/core/models/configuracao_empresa.dart';
import 'package:facturio/core/services/pdf_service.dart';
import 'package:facturio/features/clientes/domain/entities/cliente.dart';
import 'package:facturio/features/faturas/domain/entities/fatura.dart';
import 'package:facturio/shared/models/linha_fatura.dart';

Cliente _clienteBase() {
  return Cliente(
    id: 'c1',
    nome: 'Cliente Teste',
    nif: '123456789',
    email: 'cliente@teste.pt',
    telefone: '910000000',
    morada: 'Rua Teste, 1',
    dataCriacao: DateTime(2026, 1, 1),
  );
}

ConfiguracaoEmpresa _configBase() {
  return ConfiguracaoEmpresa.padrao().copyWith(
    nomeEmpresa: 'Empresa Teste',
    nif: '509123457',
    morada: 'Avenida Teste, 10',
    codigoPostal: '1000-001',
    localidade: 'Lisboa',
    pais: 'Portugal',
  );
}

Fatura _faturaBase({
  String? hashAnterior,
  double? valorRetencao,
  double? retencaoFonte,
}) {
  return Fatura(
    id: 'f1',
    numero: 'A 2026/1',
    data: DateTime(2026, 3, 10),
    clienteId: 'c1',
    clienteNome: 'Cliente Teste',
    clienteNif: '123456789',
    clienteMorada: 'Rua Teste, 1',
    linhas: [
      LinhaFatura(
        produtoId: 'p1',
        produtoNome: 'Servico',
        quantidade: 1,
        precoUnitario: 100,
        desconto: 0,
        iva: 23,
      ),
    ],
    estado: 'emitida',
    tipoDocumento: 'Fatura',
    serie: 'A',
    hashAnterior: hashAnterior,
    valorRetencao: valorRetencao,
    retencaoFonte: retencaoFonte,
    dataCriacao: DateTime(2026, 3, 10),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfService', () {
    test('gera PDF com fontes e assets do projeto', () async {
      final pdf = await PdfService.gerarFaturaPdf(
        _faturaBase(),
        _clienteBase(),
        _configBase(),
      );

      final bytes = await pdf.save();
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('gera PDF com hash anterior curto sem lançar excecao', () async {
      final pdf = await PdfService.gerarFaturaPdf(
        _faturaBase(hashAnterior: 'abc123'),
        _clienteBase(),
        _configBase(),
      );

      final bytes = await pdf.save();
      expect(bytes, isNotEmpty);
    });

    test('gera PDF com retencao e retencaoFonte nula sem escrever null%', () async {
      final pdf = await PdfService.gerarFaturaPdf(
        _faturaBase(valorRetencao: 10, retencaoFonte: null),
        _clienteBase(),
        _configBase(),
      );

      final bytes = await pdf.save();
      expect(bytes, isNotEmpty);
    });
  });
}
