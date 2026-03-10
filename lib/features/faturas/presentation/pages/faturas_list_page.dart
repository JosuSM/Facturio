import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';
import '../../../pagamentos/presentation/widgets/status_pagamento_widget.dart';
import '../providers/faturas_provider.dart';

class FaturasListPage extends ConsumerStatefulWidget {
  const FaturasListPage({super.key});

  @override
  ConsumerState<FaturasListPage> createState() => _FaturasListPageState();
}

class _FaturasListPageState extends ConsumerState<FaturasListPage> {
  String _searchTerm = '';

  bool _matchesSearch(dynamic fatura, String searchTerm) {
    if (searchTerm.isEmpty) return true;
    final normalized = searchTerm.toLowerCase();
    final searchable = '${fatura.numero} ${fatura.clienteNome}'.toLowerCase();
    return searchable.contains(normalized);
  }

  Color _estadoColor(String estado, ColorScheme colors) {
    switch (estado) {
      case 'emitida':
        return colors.primary;
      case 'paga':
        return Colors.green.shade700;
      case 'cancelada':
        return colors.error;
      default:
        return colors.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final faturasAsync = ref.watch(faturasProvider);
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
    final formatoData = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(faturasProvider.notifier).loadFaturas();
            },
          ),
        ],
      ),
      body: faturasAsync.when(
        data: (faturas) {
          final faturasFiltradas = faturas
              .where((fatura) => _matchesSearch(fatura, _searchTerm))
              .toList()
            ..sort((a, b) => b.data.compareTo(a.data));

          if (faturas.isEmpty) {
            return const Center(
              child: Text('Nenhuma fatura registada'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.8),
                        colors.surface,
                      ],
                    ),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchTerm = value.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Pesquisar por número ou cliente',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchTerm.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchTerm = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.receipt_long, size: 18),
                        label: Text('${faturasFiltradas.length}/${faturas.length}'),
                      ),
                    ],
                  ),
                ),
              ),
              if (faturasFiltradas.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Nenhuma fatura para este filtro.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: faturasFiltradas.length,
                    itemBuilder: (context, index) {
                      final fatura = faturasFiltradas[index];
                      final estadoCor = _estadoColor(fatura.estado, colors);
                      IconData estadoIcon;

                      switch (fatura.estado) {
                        case 'emitida':
                          estadoIcon = Icons.description;
                          break;
                        case 'paga':
                          estadoIcon = Icons.check_circle;
                          break;
                        case 'cancelada':
                          estadoIcon = Icons.cancel;
                          break;
                        default:
                          estadoIcon = Icons.description;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          leading: Icon(estadoIcon, color: estadoCor),
                          title: Text('Fatura ${fatura.numero}'),
                          subtitle: Text(
                            'Cliente: ${fatura.clienteNome}\n${formatoData.format(fatura.data)}',
                          ),
                          trailing: Text(
                            formatoMoeda.format(fatura.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: estadoCor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Estado: ${fatura.estado}',
                                      style: TextStyle(
                                        color: estadoCor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Produtos: ${fatura.linhas.length}'),
                                  Text('Subtotal: ${formatoMoeda.format(fatura.subtotal)}'),
                                  Text('IVA: ${formatoMoeda.format(fatura.totalIva)}'),
                                  const SizedBox(height: 12),
                                  
                                  // Status de Pagamento
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final pagamentosAsync = ref.watch(pagamentosProvider);
                                      return pagamentosAsync.when(
                                        data: (pagamentosMap) {
                                          final pagamentos = pagamentosMap[fatura.id] ?? [];
                                          return StatusPagamentoWidget(
                                            fatura: fatura,
                                            pagamentos: pagamentos,
                                            compacto: true,
                                          );
                                        },
                                        loading: () => const SizedBox(
                                          height: 20,
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        ),
                                        error: (error, stackTrace) => const SizedBox(),
                                      );
                                    },
                                  ),
                                  
                                  const Divider(),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      // Botão Ver Detalhes
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          context.push('${AppRoutes.faturaDetail}?id=${fatura.id}');
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: const Text('Ver Detalhes'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors.primary,
                                          foregroundColor: colors.onPrimary,
                                        ),
                                      ),
                                      
                                      TextButton.icon(
                                        onPressed: () async {
                                          try {
                                            final cliente = await ref
                                                .read(clientesProvider.notifier)
                                                .getCliente(fatura.clienteId);
                                            final configAsync = ref.read(configuracoesProvider);
                                            final config = configAsync.value;
                                            
                                            if (config == null) {
                                              throw Exception('Configuração da empresa não disponível');
                                            }
                                            if (cliente != null) {
                                              await PdfService.imprimirFatura(fatura, cliente, config);
                                            }
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
                                        icon: const Icon(Icons.print),
                                        label: const Text('Imprimir'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          try {
                                            final cliente = await ref
                                                .read(clientesProvider.notifier)
                                                .getCliente(fatura.clienteId);
                                            final configAsync = ref.read(configuracoesProvider);
                                            final config = configAsync.value;
                                            
                                            if (config == null) {
                                              throw Exception('Configuração da empresa não disponível');
                                            }
                                            if (cliente != null) {
                                              await PdfService.compartilharFatura(fatura, cliente, config);
                                            }
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
                                        icon: const Icon(Icons.share),
                                        label: const Text('Partilhar PDF'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          try {
                                            final cliente = await ref
                                                .read(clientesProvider.notifier)
                                                .getCliente(fatura.clienteId);
                                            final configAsync = ref.read(configuracoesProvider);
                                            final config = configAsync.value;
                                            
                                            if (config == null) {
                                              throw Exception('Configuração da empresa não disponível');
                                            }
                                            if (cliente != null) {
                                              await PdfService.exportarFaturaExcel(
                                                fatura,
                                                cliente,
                                                config,
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              UiHelpers.mostrarSnackBar(
                                                context,
                                                mensagem: 'Erro ao exportar: $e',
                                                tipo: TipoSnackBar.erro,
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.grid_on),
                                        label: const Text('Excel'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.faturaForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
