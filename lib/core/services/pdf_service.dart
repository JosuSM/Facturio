import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:barcode/barcode.dart';
import '../../features/faturas/domain/entities/fatura.dart';
import '../../features/clientes/domain/entities/cliente.dart';
import '../models/configuracao_empresa.dart';
import 'package:intl/intl.dart';

class PdfService {
  static final formatoMoeda = NumberFormat.currency(
    locale: 'pt_PT',
    symbol: '€',
    decimalDigits: 2,
  );

  static final formatoData = DateFormat('dd/MM/yyyy');

  // Gerar PDF da fatura
  static Future<pw.Document> gerarFaturaPdf(
    Fatura fatura,
    Cliente cliente,
    ConfiguracaoEmpresa config,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              _buildCabecalho(fatura, config),
              pw.SizedBox(height: 20),

              // Dados do Cliente
              _buildDadosCliente(fatura, cliente),
              pw.SizedBox(height: 20),

              // Tabela de Produtos/Serviços
              _buildTabelaProdutos(fatura),
              pw.SizedBox(height: 15),

              // Totais
              _buildTotais(fatura),
              
              // Dados legais e observações
              if (fatura.observacoes != null && fatura.observacoes!.isNotEmpty)
                ..._buildObservacoes(fatura),
              
              // Informações de pagamento
              if (fatura.meioPagamento != null)
                ..._buildInfoPagamento(fatura),
              
              pw.Spacer(),

              // Certificação AT e rodapé
              _buildRodapeCompleto(fatura, config),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildCabecalho(Fatura fatura, ConfiguracaoEmpresa config) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Dados do documento
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                fatura.tipoDocumento.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Nº ${fatura.numero}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Data: ${formatoData.format(fatura.data)}', style: const pw.TextStyle(fontSize: 10)),
              if (fatura.codigoATCUD != null)
                pw.Text('ATCUD: ${fatura.codigoATCUD}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ],
          ),
        ),
        // Dados da empresa emissora (OBRIGATÓRIOS POR LEI)
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                config.nomeEmpresa,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
              pw.SizedBox(height: 4),
              pw.Text('NIF: ${config.nif}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(config.morada, style: const pw.TextStyle(fontSize: 9)),
              pw.Text('${config.codigoPostal} ${config.localidade}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text(config.pais, style: const pw.TextStyle(fontSize: 9)),
              if (config.telefone != null) pw.Text('Tel: ${config.telefone}', style: const pw.TextStyle(fontSize: 9)),
              if (config.email != null) pw.Text(config.email!, style: const pw.TextStyle(fontSize: 9)),
              if (config.cae != null) pw.Text('CAE: ${config.cae}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              if (config.capitalSocial != null) 
                pw.Text('Capital Social: ${config.capitalSocial}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDadosCliente(Fatura fatura, Cliente cliente) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CLIENTE / ADQUIRENTE',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(cliente.nome, style: const pw.TextStyle(fontSize: 10)),
          // NIF é obrigatório em faturas (pode vir da fatura ou do cliente)
          pw.Text(
            'NIF: ${fatura.clienteNif ?? cliente.nif}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          // Morada do cliente (obrigatória)
          pw.Text(
            fatura.clienteMorada ?? cliente.morada,
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (cliente.email.isNotEmpty) pw.Text('Email: ${cliente.email}', style: const pw.TextStyle(fontSize: 9)),
          if (cliente.telefone.isNotEmpty) pw.Text('Tel: ${cliente.telefone}', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTabelaProdutos(Fatura fatura) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Cabeçalho
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCelulaCabecalho('Descrição'),
            _buildCelulaCabecalho('Qtd'),
            _buildCelulaCabecalho('Preço Un.'),
            _buildCelulaCabecalho('IVA %'),
            _buildCelulaCabecalho('Total'),
          ],
        ),
        // Linhas
        ...fatura.linhas.map((linha) {
          return pw.TableRow(
            children: [
              _buildCelula(linha.produtoNome),
              _buildCelula(linha.quantidade.toString(), alinhamento: pw.Alignment.centerRight),
              _buildCelula(formatoMoeda.format(linha.precoUnitario), alinhamento: pw.Alignment.centerRight),
              _buildCelula('${linha.iva}%', alinhamento: pw.Alignment.center),
              _buildCelula(formatoMoeda.format(linha.total), alinhamento: pw.Alignment.centerRight),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildCelulaCabecalho(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildCelula(String texto, {pw.Alignment? alinhamento}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Align(
        alignment: alinhamento ?? pw.Alignment.centerLeft,
        child: pw.Text(texto),
      ),
    );
  }

  static pw.Widget _buildTotais(Fatura fatura) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildLinhaTotal('Subtotal:', formatoMoeda.format(fatura.subtotal)),
            _buildLinhaTotal('IVA:', formatoMoeda.format(fatura.totalIva)),
            // Motivo de isenção de IVA (se aplicável)
            if (fatura.motivoIsencaoIVA != null && fatura.motivoIsencaoIVA!.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
                child: pw.Text(
                  'Isento de IVA: ${fatura.motivoIsencaoIVA}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            pw.Divider(),
            _buildLinhaTotal(
              'TOTAL:',
              formatoMoeda.format(fatura.total),
              negrito: true,
              tamanho: 16,
            ),
            // Retenção na fonte (se aplicável)
            if (fatura.valorRetencao != null && fatura.valorRetencao! > 0) ...[
              pw.SizedBox(height: 4),
              _buildLinhaTotal(
                'Retenção na Fonte (${fatura.retencaoFonte?.toStringAsFixed(1)}%):',
                '- ${formatoMoeda.format(fatura.valorRetencao)}',
                tamanho: 10,
              ),
              pw.Divider(color: PdfColors.grey400),
              _buildLinhaTotal(
                'Total a receber:',
                formatoMoeda.format(fatura.totalComRetencao),
                negrito: true,
                tamanho: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static List<pw.Widget> _buildObservacoes(Fatura fatura) {
    return [
      pw.SizedBox(height: 15),
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Observações:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              fatura.observacoes!,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    ];
  }

  static List<pw.Widget> _buildInfoPagamento(Fatura fatura) {
    return [
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: fatura.estaPaga ? PdfColors.green100 : PdfColors.grey100,
              border: pw.Border.all(
                color: fatura.estaPaga ? PdfColors.green700 : PdfColors.grey400,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Pagamento',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Meio: ${fatura.meioPagamento}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                if (fatura.dataPagamento != null)
                  pw.Text(
                    'Data: ${formatoData.format(fatura.dataPagamento!)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                if (fatura.valorPago != null)
                  pw.Text(
                    'Valor: ${formatoMoeda.format(fatura.valorPago)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  static pw.Widget _buildRodapeCompleto(Fatura fatura, ConfiguracaoEmpresa config) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        // Informações de certificação AT
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Coluna esquerda - Info legal
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (fatura.hashAnterior != null)
                    pw.Text(
                      'Hash: ${fatura.hashAnterior!.substring(0, 20)}...',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                    ),
                  if (config.numeroChaveCertificacaoAT != null)
                    pw.Text(
                      'Software certificado n.º ${config.numeroChaveCertificacaoAT}',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                    ),
                  if (config.conservatoria != null && config.numeroRegistoComercial != null)
                    pw.Text(
                      'Registada em ${config.conservatoria} sob o n.º ${config.numeroRegistoComercial}',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                    ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Processado por programa certificado n.º ${config.codigoValidacaoSoftwareAT ?? "SIMULAÇÃO"}',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            // Coluna direita - QR Code
            if (fatura.qrCodeData != null)
              pw.Container(
                width: 70,
                height: 70,
                child: pw.BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: fatura.qrCodeData!,
                  drawText: false,
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Obrigado pela sua preferência!',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildLinhaTotal(
    String label,
    String valor, {
    bool negrito = false,
    double tamanho = 12,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: tamanho,
            fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: tamanho,
            fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Imprimir PDF
  static Future<void> imprimirFatura(
    Fatura fatura,
    Cliente cliente,
    ConfiguracaoEmpresa config,
  ) async {
    final pdf = await gerarFaturaPdf(fatura, cliente, config);
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // Compartilhar PDF
  static Future<void> compartilharFatura(
    Fatura fatura,
    Cliente cliente,
    ConfiguracaoEmpresa config,
  ) async {
    final pdf = await gerarFaturaPdf(fatura, cliente, config);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'fatura_${fatura.numero.replaceAll('/', '_')}.pdf',
    );
  }

  // Exportar fatura em CSV (compatível com Excel)
  static Future<void> exportarFaturaExcel(
    Fatura fatura,
    Cliente cliente,
    ConfiguracaoEmpresa config,
  ) async {
    final csv = _gerarFaturaCsv(fatura, cliente, config);
    final bytes = Uint8List.fromList(utf8.encode('\uFEFF$csv'));
    final nomeFicheiro = 'fatura_${fatura.numero.replaceAll('/', '_')}.csv';

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'text/csv',
          name: nomeFicheiro,
        ),
      ],
      text: 'Exportação Excel (CSV) - ${fatura.numero}',
    );
  }

  static String _gerarFaturaCsv(Fatura fatura, Cliente cliente, ConfiguracaoEmpresa config) {
    final linhas = <String>[
      // Dados da empresa
      'EMPRESA;${_csv(config.nomeEmpresa)}',
      'NIF EMPRESA;${_csv(config.nif)}',
      'MORADA;${_csv(config.morada)}',
      '',
      // Dados documento
      'TIPO DOCUMENTO;${_csv(fatura.tipoDocumento)}',
      'NUMERO;${_csv(fatura.numero)}',
      'SERIE;${_csv(fatura.serie)}',
      'DATA;${formatoData.format(fatura.data)}',
      if (fatura.codigoATCUD != null) 'ATCUD;${_csv(fatura.codigoATCUD!)}',
      '',
      // Dados do cliente
      'CLIENTE;${_csv(cliente.nome)}',
      'NIF CLIENTE;${_csv(fatura.clienteNif ?? cliente.nif)}',
      if (fatura.clienteMorada != null) 'MORADA CLIENTE;${_csv(fatura.clienteMorada!)}',
      '',
      // Produtos/Serviços
      'DESCRICAO;QTD;PRECO UNIT.;IVA %;SUBTOTAL;TOTAL',
      ...fatura.linhas.map(
        (linha) => [
          _csv(linha.produtoNome),
          linha.quantidade.toStringAsFixed(2),
          linha.precoUnitario.toStringAsFixed(2),
          linha.iva.toStringAsFixed(2),
          linha.subtotal.toStringAsFixed(2),
          linha.total.toStringAsFixed(2),
        ].join(';'),
      ),
      '',
      // Totais
      'SUBTOTAL;${fatura.subtotal.toStringAsFixed(2)}',
      'IVA;${fatura.totalIva.toStringAsFixed(2)}',
      if (fatura.motivoIsencaoIVA != null) 'ISENCAO IVA;${_csv(fatura.motivoIsencaoIVA!)}',
      'TOTAL;${fatura.total.toStringAsFixed(2)}',
      if (fatura.valorRetencao != null && fatura.valorRetencao! > 0) ...[
        'RETENCAO (${fatura.retencaoFonte}%);${fatura.valorRetencao!.toStringAsFixed(2)}',
        'TOTAL A RECEBER;${fatura.totalComRetencao.toStringAsFixed(2)}',
      ],
      '',
      // Pagamento
      if (fatura.meioPagamento != null) 'MEIO PAGAMENTO;${_csv(fatura.meioPagamento!)}',
      if (fatura.dataPagamento != null) 'DATA PAGAMENTO;${formatoData.format(fatura.dataPagamento!)}',
      if (fatura.valorPago != null) 'VALOR PAGO;${fatura.valorPago!.toStringAsFixed(2)}',
      '',
      // Observações
      if (fatura.observacoes != null) 'OBSERVACOES;${_csv(fatura.observacoes!)}',
    ];

    return linhas.join('\n');
  }

  static String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
