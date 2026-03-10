import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/admin_auth_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../../../faturas/presentation/providers/faturas_provider.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final faturasAsync = ref.watch(faturasProvider);
    final pagamentosAsync = ref.watch(pagamentosProvider);
    final totalFaturado = ref.watch(totalFaturadoProvider);
    final produtosStockBaixo = ref.watch(produtosStockBaixoProvider);

    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: _buildDrawer(context, ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Centro de Faturação',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Resumo rápido de clientes, produtos e faturação.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Clientes',
                    clientesAsync.when(
                      data: (clientes) => clientes.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.people,
                    colors.primary,
                    () => context.push(AppRoutes.clientes),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Produtos',
                    produtosAsync.when(
                      data: (produtos) => produtos.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.inventory,
                    Colors.green.shade700,
                    () => context.push(AppRoutes.produtos),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Faturas',
                    faturasAsync.when(
                      data: (faturas) => faturas.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.receipt_long,
                    Colors.orange.shade700,
                    () => context.push(AppRoutes.faturas),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Faturado',
                    formatoMoeda.format(totalFaturado),
                    Icons.euro,
                    colors.secondary,
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Resumo Financeiro
            Text(
              'Resumo Financeiro',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            faturasAsync.when(
              data: (faturas) {
                return pagamentosAsync.when(
                  data: (pagamentosMap) {
                    // Gerar resumo financeiro
                    final resumo = PagamentosService.gerarResumoFinanceiro(
                      faturas: faturas,
                      pagamentosPorFatura: pagamentosMap,
                    );

                    final totalRecebido = resumo['totalRecebido'] as double;
                    final totalEmDivida = resumo['totalEmDivida'] as double;
                    final faturasPagas = resumo['faturasCompletamentePagas'] as int;
                    final faturasNaoPagas = resumo['faturasNaoPagas'] as int;
                    final faturasParciais = resumo['faturasParcialmentePagas'] as int;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoTile(
                                    context,
                                    'Total Recebido',
                                    formatoMoeda.format(totalRecebido),
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoTile(
                                    context,
                                    'Em Dívida',
                                    formatoMoeda.format(totalEmDivida),
                                    Icons.pending,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildStatusChip(
                                  'Pagas',
                                  faturasPagas,
                                  Colors.green,
                                ),
                                _buildStatusChip(
                                  'Parciais',
                                  faturasParciais,
                                  Colors.orange,
                                ),
                                _buildStatusChip(
                                  'Não Pagas',
                                  faturasNaoPagas,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stackTrace) => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Erro ao carregar pagamentos'),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Erro ao carregar dados'),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Alertas de stock baixo
            if (produtosStockBaixo.isNotEmpty) ...[
              Text(
                'Alertas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text('${produtosStockBaixo.length} produtos com stock baixo'),
                  subtitle: const Text('Clique para ver detalhes'),
                  onTap: () => context.push(AppRoutes.produtos),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Últimas faturas
            Text(
              'Últimas Faturas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            faturasAsync.when(
              data: (faturas) {
                final ultimasFaturas = faturas.take(5).toList();
                if (ultimasFaturas.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhuma fatura registada'),
                    ),
                  );
                }
                return Column(
                  children: ultimasFaturas.map((fatura) {
                    return Card(
                      child: ListTile(
                        title: Text(fatura.numero),
                        subtitle: Text(fatura.clienteNome),
                        trailing: Text(
                          formatoMoeda.format(fatura.total),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => context.push(AppRoutes.faturas),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Erro ao carregar faturas'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Column(
      children: [
        Chip(
          avatar: CircleAvatar(
            backgroundColor: color,
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          label: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          backgroundColor: color.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Facturio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.clientes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.produtos);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Faturas'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.faturas);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Personalização'),
            subtitle: const Text('Tema, cores e aparência'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.personalizacao);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações da Empresa'),
            onTap: () async {
              Navigator.pop(context);
              final cfg = ref.read(configuracoesProvider).maybeWhen(
                    data: (value) => value,
                    orElse: () => null,
                  );

              final pinController = TextEditingController();
              final pin = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Acesso de Administrador'),
                  content: TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN de administrador',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 12,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(pinController.text.trim()),
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              );

              if (pin == null || pin.isEmpty || !context.mounted) {
                return;
              }

              final pinHash = cfg?.adminPinHash ?? AdminAuthService.defaultPinHash;
              if (!AdminAuthService.validarPin(pin, pinHash)) {
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: 'PIN de administrador inválido.',
                  tipo: TipoSnackBar.erro,
                );
                return;
              }

              context.push(AppRoutes.configuracoes);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Criar backup'),
            subtitle: const Text('Guarde em Drive, cloud ou no PC'),
            onTap: () async {
              Navigator.pop(context);
              final storage = StorageService();
              try {
                await BackupService.partilharBackup(storage);
                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: 'Backup criado. Guarde o ficheiro partilhado em local seguro.',
                    tipo: TipoSnackBar.sucesso,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: 'Erro ao criar backup: $e',
                    tipo: TipoSnackBar.erro,
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar backup'),
            subtitle: const Text('Substitui os dados atuais'),
            onTap: () async {
              Navigator.pop(context);

              final confirmar = await UiHelpers.mostrarDialogoConfirmacao(
                context,
                titulo: 'Restaurar backup',
                mensagem: 'Esta ação vai substituir os dados atuais. Deseja continuar?',
                textoBotaoConfirmar: 'Restaurar',
                acaoDestruidora: true,
              );

              if (!confirmar || !context.mounted) return;

              final storage = StorageService();
              try {
                final resultado = await BackupService.selecionarERestaurar(storage);
                if (resultado == null) {
                  if (context.mounted) {
                    UiHelpers.mostrarSnackBar(
                      context,
                      mensagem: 'Restauro cancelado.',
                      tipo: TipoSnackBar.info,
                    );
                  }
                  return;
                }

                await ref.read(clientesProvider.notifier).loadClientes();
                await ref.read(produtosProvider.notifier).loadProdutos();
                await ref.read(faturasProvider.notifier).loadFaturas();

                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem:
                        'Restauro concluído: ${resultado.clientes} clientes, ${resultado.produtos} produtos e ${resultado.faturas} faturas.',
                    tipo: TipoSnackBar.sucesso,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: 'Erro ao restaurar backup: $e',
                    tipo: TipoSnackBar.erro,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
