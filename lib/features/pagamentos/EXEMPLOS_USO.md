# Exemplos de Uso do Sistema de Pagamentos

## 1. Adicionar Status de Pagamento à Lista de Faturas

No ficheiro `lib/features/faturas/presentation/pages/faturas_list_page.dart`, adicione o widget de status:

```dart
import '../../../pagamentos/presentation/widgets/status_pagamento_widget.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';

// Dentro do Card de cada fatura:
Consumer(
  builder: (context, ref, _) {
    final pagamentos = ref.watch(pagamentosProvider).value?[fatura.id] ?? [];
    
    return StatusPagamentoWidget(
      fatura: fatura,
      pagamentos: pagamentos,
      compacto: true, // Modo compacto para a lista
    );
  },
)
```

## 2. Adicionar Botão para Registar Pagamento

No card da fatura, adicione um botão:

```dart
import '../../../pagamentos/presentation/pages/registar_pagamento_page.dart';

// Botão na lista de faturas:
ElevatedButton.icon(
  onPressed: () async {
    final pagamentos = ref.read(pagamentosProvider).value?[fatura.id] ?? [];
    
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistarPagamentoPage(
          fatura: fatura.toEntity(),
          pagamentosExistentes: pagamentos,
        ),
      ),
    );
    
    if (resultado == true) {
      // Atualizar a lista se necessário
      ref.invalidate(pagamentosProvider);
    }
  },
  icon: const Icon(Icons.add),
  label: const Text('Registar Pagamento'),
)
```

## 3. Página de Detalhe da Fatura com Histórico de Pagamentos

Crie uma página completa mostrando todos os detalhes e pagamentos:

```dart
import '../../../pagamentos/presentation/widgets/status_pagamento_widget.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';
import '../../../pagamentos/presentation/pages/registar_pagamento_page.dart';

class FaturaDetailPage extends ConsumerWidget {
  final Fatura fatura;

  const FaturaDetailPage({Key? key, required this.fatura}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagamentosAsync = ref.watch(pagamentosProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Fatura ${fatura.numero}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pagamentos = pagamentosAsync.value?[fatura.id] ?? [];
          
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Detalhes da fatura
            Card(
              child: ListTile(
                title: Text(fatura.clienteNome),
                subtitle: Text('Total: €${fatura.totalComRetencao.toStringAsFixed(2)}'),
              ),
            ),
            
            // Status de pagamento
            pagamentosAsync.when(
              data: (pagamentosMap) {
                final pagamentos = pagamentosMap[fatura.id] ?? [];
                return StatusPagamentoWidget(
                  fatura: fatura,
                  pagamentos: pagamentos,
                  compacto: false, // Modo completo
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erro ao carregar pagamentos'),
            ),
            
            // Histórico de pagamentos
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Histórico de Pagamentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            pagamentosAsync.when(
              data: (pagamentosMap) {
                final pagamentos = pagamentosMap[fatura.id] ?? [];
                
                if (pagamentos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Nenhum pagamento registado'),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pagamentos.length,
                  itemBuilder: (context, index) {
                    final pagamento = pagamentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text('€${pagamento.valor.toStringAsFixed(2)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pagamento.meioPagamento),
                            Text(
                              '${pagamento.dataPagamento.day}/${pagamento.dataPagamento.month}/${pagamento.dataPagamento.year}',
                            ),
                            if (pagamento.referencia != null)
                              Text('Ref: ${pagamento.referencia}'),
                            if (pagamento.observacoes != null)
                              Text(
                                pagamento.observacoes!,
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            // Confirmar antes de remover
                            final confirma = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar'),
                                content: const Text('Deseja remover este pagamento?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Remover'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirma == true) {
                              await ref.read(pagamentosProvider.notifier).removerPagamento(
                                pagamento.id,
                                pagamento.faturaId,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erro ao carregar histórico'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 4. Dashboard - Estatísticas de Pagamentos

No dashboard, pode adicionar widgets mostrando:

```dart
Consumer(
  builder: (context, ref, _) {
    final pagamentosAsync = ref.watch(pagamentosProvider);
    
    return pagamentosAsync.when(
      data: (pagamentosMap) {
        final todosPagamentos = pagamentosMap.values.expand((p) => p).toList();
        final totalRecebido = todosPagamentos.fold<double>(
          0,
          (sum, p) => sum + p.valor,
        );
        
        return Card(
          child: ListTile(
            leading: const Icon(Icons.payments, color: Colors.green),
            title: const Text('Total Recebido'),
            subtitle: Text('€${totalRecebido.toStringAsFixed(2)}'),
            trailing: Text('${todosPagamentos.length} pagamentos'),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  },
)
```

## 5. Filtrar Faturas por Estado de Pagamento

```dart
final faturasAsync = ref.watch(faturasProvider);
final pagamentosAsync = ref.watch(pagamentosProvider);

// Filtrar apenas faturas não pagas
final faturasNaoPagas = faturasAsync.value?.where((fatura) {
  final pagamentos = pagamentosAsync.value?[fatura.id] ?? [];
  return !PagamentosService.estaCompletamentePaga(fatura.toEntity(), pagamentos);
}).toList() ?? [];

// Filtrar apenas faturas pagas
final faturasPagas = faturasAsync.value?.where((fatura) {
  final pagamentos = pagamentosAsync.value?[fatura.id] ?? [];
  return PagamentosService.estaCompletamentePaga(fatura.toEntity(), pagamentos);
}).toList() ?? [];
```

## 6. Relatório Financeiro

```dart
import '../../../pagamentos/core/services/pagamentos_service.dart';

final relatorio = PagamentosService.gerarResumoFinanceiro(
  faturas: todasFaturas,
  pagamentosPorFatura: pagamentosMap,
);

print('Total Faturado: €${relatorio['totalFaturado']}');
print('Total Recebido: €${relatorio['totalRecebido']}');
print('Total em Dívida: €${relatorio['totalEmDivida']}');
print('Faturas Pagas: ${relatorio['faturasPagas']}');
print('Faturas Parciais: ${relatorio['faturasParciais']}');
print('Faturas Não Pagas: ${relatorio['faturasNaoPagas']}');
```

## 7. Agrupar Pagamentos por Meio

```dart
final pagamentosPorMeio = PagamentosService.agruparPorMeioPagamento(todosPagamentos);

// Resultado:
// {
//   'Numerário': 1500.00,
//   'Transferência': 3200.00,
//   'MB Way': 850.00,
// }
```

## Validações Importantes

O sistema já inclui validações automáticas:
- Não permite registar pagamento maior que o valor em dívida
- Não permite valores negativos ou zero
- Calcula automaticamente o saldo restante
- Suporta múltiplos pagamentos parciais
- Tolerância de €0.01 para arredondamentos

## Próximos Passos

1. Integrar na lista de faturas existente
2. Criar página de detalhe da fatura
3. Adicionar filtros por estado de pagamento
4. Gerar relatórios financeiros
5. Exportar histórico de pagamentos para PDF
