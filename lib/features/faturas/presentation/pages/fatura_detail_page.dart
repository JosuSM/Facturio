import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';
import '../../../pagamentos/presentation/widgets/status_pagamento_widget.dart';
import '../../../pagamentos/presentation/pages/registar_pagamento_page.dart';
import '../providers/faturas_provider.dart';

/// Página de detalhe de uma fatura específica com histórico de pagamentos.
class FaturaDetailPage extends ConsumerWidget {
  final String faturaId;

  const FaturaDetailPage({super.key, required this.faturaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final faturasAsync = ref.watch(faturasProvider);
    final pagamentosAsync = ref.watch(pagamentosProvider);
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
    final formatoData = DateFormat('dd/MM/yyyy');

    return faturasAsync.when(
      data: (faturas) {
        final fatura = faturas.firstWhere(
          (f) => f.id == faturaId,
          orElse: () => throw Exception('Fatura não encontrada'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Fatura ${fatura.numero}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Imprimir',
                onPressed: () async {
                  try {
                    final cliente = await ref
                        .read(clientesProvider.notifier)
                        .getCliente(fatura.clienteId);
                    final config = ref.read(configuracoesProvider).value;

                    if (config == null || cliente == null) {
                      throw Exception('Dados insuficientes');
                    }

                    await PdfService.imprimirFatura(fatura, cliente, config);
                  } catch (e) {
                    if (context.mounted) {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: 'Erro ao imprimir: $e',
                        tipo: TipoSnackBar.erro,
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Partilhar',
                onPressed: () async {
                  try {
                    final cliente = await ref
                        .read(clientesProvider.notifier)
                        .getCliente(fatura.clienteId);
                    final config = ref.read(configuracoesProvider).value;

                    if (config == null || cliente == null) {
                      throw Exception('Dados insuficientes');
                    }

                    await PdfService.compartilharFatura(fatura, cliente, config);
                  } catch (e) {
                    if (context.mounted) {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: 'Erro ao partilhar: $e',
                        tipo: TipoSnackBar.erro,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          floatingActionButton: pagamentosAsync.when(
            data: (pagamentosMap) {
              final pagamentos = pagamentosMap[faturaId] ?? [];
              final estaCompleta = PagamentosService.estaCompletamentePaga(fatura, pagamentos);

              if (estaCompleta) {
                return null; // Não mostra botão se já está paga
              }

              return FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistarPagamentoPage(
                        fatura: fatura,
                        pagamentosExistentes: pagamentos,
                      ),
                    ),
                  );
                  ref.invalidate(pagamentosProvider);
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Pagamento'),
              );
            },
            loading: () => null,
            error: (error, stackTrace) => null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho da fatura
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.secondary],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fatura ${fatura.numero}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fatura.clienteNome,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoData.format(fatura.data),
                        style: TextStyle(
                          color: colors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status de Pagamento
                pagamentosAsync.when(
                  data: (pagamentosMap) {
                    final pagamentos = pagamentosMap[faturaId] ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: StatusPagamentoWidget(
                        fatura: fatura,
                        pagamentos: pagamentos,
                        compacto: false,
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Erro ao carregar pagamentos'),
                  ),
                ),

                // Detalhes da Fatura
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumo Financeiro',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        _buildLinhaResumo('Subtotal', formatoMoeda.format(fatura.subtotal)),
                        _buildLinhaResumo('IVA', formatoMoeda.format(fatura.totalIva)),
                        if (fatura.retencaoFonte != null && fatura.retencaoFonte! > 0)
                          _buildLinhaResumo(
                            'Retenção na Fonte',
                            '- ${formatoMoeda.format(fatura.retencaoFonte)}',
                            color: Colors.red,
                          ),
                        const Divider(),
                        _buildLinhaResumo(
                          'Total',
                          formatoMoeda.format(fatura.totalComRetencao),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Produtos/Serviços
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produtos/Serviços',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fatura.linhas.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final linha = fatura.linhas[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(linha.produtoNome),
                              subtitle: Text(
                                '${linha.quantidade} x ${formatoMoeda.format(linha.precoUnitario)} (IVA ${linha.iva}%)',
                              ),
                              trailing: Text(
                                formatoMoeda.format(linha.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Histórico de Pagamentos
                pagamentosAsync.when(
                  data: (pagamentosMap) {
                    final pagamentos = pagamentosMap[faturaId] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Histórico de Pagamentos',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Chip(
                                  label: Text('${pagamentos.length}'),
                                  avatar: const Icon(Icons.payments, size: 18),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (pagamentos.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.payment, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Nenhum pagamento registado',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pagamentos.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final pagamento = pagamentos[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check, color: Colors.white),
                                    ),
                                    title: Text(
                                      formatoMoeda.format(pagamento.valor),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pagamento.meioPagamento),
                                        Text(formatoData.format(pagamento.dataPagamento)),
                                        if (pagamento.referencia != null)
                                          Text(
                                            'Ref: ${pagamento.referencia}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (pagamento.observacoes != null)
                                          Text(
                                            pagamento.observacoes!,
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () async {
                                        final confirma = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar Remoção'),
                                            content: Text(
                                              'Deseja remover o pagamento de ${formatoMoeda.format(pagamento.valor)}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Remover'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirma == true) {
                                          try {
                                            await ref
                                                .read(pagamentosProvider.notifier)
                                                .removerPagamento(pagamento.id, pagamento.faturaId);

                                            if (context.mounted) {
                                              UiHelpers.mostrarSnackBar(
                                                context,
                                                mensagem: 'Pagamento removido com sucesso',
                                                tipo: TipoSnackBar.sucesso,
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              UiHelpers.mostrarSnackBar(
                                                context,
                                                mensagem: 'Erro ao remover pagamento: $e',
                                                tipo: TipoSnackBar.erro,
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stackTrace) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Erro ao carregar histórico'),
                    ),
                  ),
                ),

                const SizedBox(height: 80), // Espaço para o FAB
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Text('Erro ao carregar fatura: $error'),
        ),
      ),
    );
  }

  Widget _buildLinhaResumo(String label, String valor, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
