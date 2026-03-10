import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/configuracao_empresa.dart';
import '../../../../core/services/admin_auth_service.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/services/tutorial_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../app/routes.dart';
import '../providers/configuracoes_provider.dart';

class ConfiguracoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends ConsumerState<ConfiguracoesPage> 
    with SingleTickerProviderStateMixin {
  final _nomeEmpresaController = TextEditingController();
  final _itemController = TextEditingController();
  final _nifController = TextEditingController();
  final _moradaController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _paisController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _caeController = TextEditingController();
  final _capitalSocialController = TextEditingController();
  final _conservatoriaController = TextEditingController();
  final _numeroRegistoComercialController = TextEditingController();
  final _numeroChaveCertificacaoATController = TextEditingController();
  final _codigoValidacaoSoftwareATController = TextEditingController();
  final _serieAtualController = TextEditingController();

  late TabController _tabController;
  List<double> _ivaOptions = [];
  List<String> _unidades = [];
  List<String> _estadosFatura = [];
  List<String> _meiosPagamento = [];
  List<String> _tiposDocumento = [];
  String _adminPinHash = AdminAuthService.defaultPinHash;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeEmpresaController.dispose();
    _itemController.dispose();
    _nifController.dispose();
    _moradaController.dispose();
    _codigoPostalController.dispose();
    _localidadeController.dispose();
    _paisController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _caeController.dispose();
    _capitalSocialController.dispose();
    _conservatoriaController.dispose();
    _numeroRegistoComercialController.dispose();
    _numeroChaveCertificacaoATController.dispose();
    _codigoValidacaoSoftwareATController.dispose();
    _serieAtualController.dispose();
    super.dispose();
  }

  void _carregarEmMemoria(ConfiguracaoEmpresa cfg) {
    if (_inicializado) return;
    _nomeEmpresaController.text = cfg.nomeEmpresa;
    _nifController.text = cfg.nif;
    _moradaController.text = cfg.morada;
    _codigoPostalController.text = cfg.codigoPostal;
    _localidadeController.text = cfg.localidade;
    _paisController.text = cfg.pais;
    _emailController.text = cfg.email ?? '';
    _telefoneController.text = cfg.telefone ?? '';
    _caeController.text = cfg.cae ?? '';
    _capitalSocialController.text = cfg.capitalSocial ?? '';
    _conservatoriaController.text = cfg.conservatoria ?? '';
    _numeroRegistoComercialController.text = cfg.numeroRegistoComercial ?? '';
    _numeroChaveCertificacaoATController.text = cfg.numeroChaveCertificacaoAT ?? '';
    _codigoValidacaoSoftwareATController.text = cfg.codigoValidacaoSoftwareAT ?? '';
    _serieAtualController.text = cfg.serieAtual;
    _ivaOptions = [...cfg.ivaOptions]..sort();
    _unidades = [...cfg.unidades];
    _estadosFatura = [...cfg.estadosFatura];
    _meiosPagamento = [...cfg.meiosPagamento];
    _tiposDocumento = [...cfg.tiposDocumento];
    _adminPinHash = cfg.adminPinHash;
    _inicializado = true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final configAsync = ref.watch(configuracoesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações da Empresa'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Dados Básicos'),
            Tab(icon: Icon(Icons.location_on), text: 'Dados Fiscais'),
            Tab(icon: Icon(Icons.verified_user), text: 'Certificação AT'),
            Tab(icon: Icon(Icons.description), text: 'Documentos'),
          ],
        ),
      ),
      body: configAsync.when(
        data: (cfg) {
          _carregarEmMemoria(cfg);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDadosBasicosTab(context, colors, cfg),
              _buildDadosFiscaisTab(context, colors),
              _buildCertificacaoATTab(context, colors),
              _buildDocumentosTab(context, colors, cfg),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar configurações: $e')),
      ),
    );
  }

  // Aba 1: Dados Básicos
  Widget _buildDadosBasicosTab(BuildContext context, ColorScheme colors, ConfiguracaoEmpresa cfg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  'Personalização da aplicação',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Defina as opções visíveis em produtos e faturas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nome da empresa',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomeEmpresaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome exibido na aplicação',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: 'Taxas de IVA disponíveis',
                    dica: 'Exemplo: 23 ou 6',
                    chips: _ivaOptions.map((e) => '${e.toStringAsFixed(0)}%').toList(),
                    onAdicionar: _adicionarIva,
                    onRemover: (index) {
                      if (_ivaOptions.length <= 1) return;
                      setState(() => _ivaOptions.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: 'Unidades disponíveis',
                    dica: 'Exemplo: un, kg, h',
                    chips: _unidades,
                    onAdicionar: _adicionarTextoUnidade,
                    onRemover: (index) {
                      if (_unidades.length <= 1) return;
                      setState(() => _unidades.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: 'Estados de fatura disponíveis',
                    dica: 'Exemplo: emitida, paga',
                    chips: _estadosFatura,
                    onAdicionar: _adicionarTextoEstado,
                    onRemover: (index) {
                      if (_estadosFatura.length <= 1) return;
                      setState(() => _estadosFatura.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ajuda e Tutorial',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.help_outline, color: colors.primary),
                      title: const Text('Tutorial de boas-vindas'),
                      subtitle: Text(
                        TutorialService.isTutorialCompleted()
                            ? 'Tutorial já visualizado'
                            : 'Tutorial não visualizado',
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () async {
                          await TutorialService.resetTutorial();
                          if (context.mounted) {
                            UiHelpers.mostrarSnackBar(
                              context,
                              mensagem: 'Tutorial reiniciado! Redirecionando...',
                              tipo: TipoSnackBar.sucesso,
                            );
                            await Future.delayed(const Duration(milliseconds: 500));
                            if (context.mounted) {
                              Navigator.pushNamed(context, AppRoutes.tutorial);
                            }
                          }
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Ver Tutorial'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Personalização',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.purple.shade50,
                    child: ListTile(
                      leading: Icon(Icons.palette, color: colors.primary),
                      title: const Text('Tema e Aparência'),
                      subtitle: const Text('Personalize cores, ícones e muito mais'),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.personalizacao);
                        },
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Personalizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Segurança',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Alterar PIN de administrador'),
                    subtitle: const Text('Este PIN protege o acesso às configurações.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _alterarPin,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _salvar(cfg),
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar alterações'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 2: Dados Fiscais
  Widget _buildDadosFiscaisTab(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  'Dados Fiscais da Empresa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Informação obrigatória para faturas legais.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nifController,
                    decoration: const InputDecoration(
                      labelText: 'NIF *',
                      prefixIcon: Icon(Icons.badge),
                      helperText: 'Número de Identificação Fiscal (9 dígitos)',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _moradaController,
                    decoration: const InputDecoration(
                      labelText: 'Morada *',
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codigoPostalController,
                    decoration: const InputDecoration(
                      labelText: 'Código Postal *',
                      prefixIcon: Icon(Icons.markunread_mailbox),
                      helperText: 'Formato: XXXX-XXX',
                    ),
                    maxLength: 8,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _localidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Localidade *',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _paisController,
                    decoration: const InputDecoration(
                      labelText: 'País *',
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _caeController,
                    decoration: const InputDecoration(
                      labelText: 'CAE (Código de Atividade Económica)',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _capitalSocialController,
                    decoration: const InputDecoration(
                      labelText: 'Capital Social',
                      prefixIcon: Icon(Icons.euro),
                      helperText: 'Exemplo: 5000,00 EUR',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _conservatoriaController,
                    decoration: const InputDecoration(
                      labelText: 'Conservatória do Registo Comercial',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _numeroRegistoComercialController,
                    decoration: const InputDecoration(
                      labelText: 'Número do Registo Comercial',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 3: Certificação AT
  Widget _buildCertificacaoATTab(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  'Certificação AT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chaves de certificação da Autoridade Tributária.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ AVISO: Para uso em produção, é obrigatório obter certificação oficial da AT. Os códigos ATCUD gerados atualmente são simulados.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _numeroChaveCertificacaoATController,
                    decoration: const InputDecoration(
                      labelText: 'Número da Chave de Certificação AT',
                      prefixIcon: Icon(Icons.vpn_key),
                      helperText: 'Fornecido pela Autoridade Tributária',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codigoValidacaoSoftwareATController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Validação do Software AT',
                      prefixIcon: Icon(Icons.security),
                      helperText: 'Código obtido após certificação do software',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Como obter certificação?'),
                    subtitle: const Text('Contacte a AT em www.portaldasfinancas.gov.pt'),
                    onTap: () {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: 'Aceda ao Portal das Finanças para informações sobre certificação de software.',
                        tipo: TipoSnackBar.info,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 4: Documentos
  Widget _buildDocumentosTab(BuildContext context, ColorScheme colors, ConfiguracaoEmpresa cfg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                  'Documentos e Séries',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Configure tipos de documento, meios de pagamento e séries.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _secaoLista(
                    titulo: 'Meios de Pagamento',
                    dica: 'Exemplo: Numerário, MB Way',
                    chips: _meiosPagamento,
                    onAdicionar: _adicionarMeioPagamento,
                    onRemover: (index) {
                      if (_meiosPagamento.length <= 1) return;
                      setState(() => _meiosPagamento.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: 'Tipos de Documento',
                    dica: 'Exemplo: Fatura, Nota de Crédito',
                    chips: _tiposDocumento,
                    onAdicionar: _adicionarTipoDocumento,
                    onRemover: (index) {
                      if (_tiposDocumento.length <= 1) return;
                      setState(() => _tiposDocumento.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serieAtualController,
                    decoration: const InputDecoration(
                      labelText: 'Série Atual *',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      helperText: 'Série a usar nos novos documentos (ex: A, 2024, FT)',
                    ),
                    maxLength: 10,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _salvar(cfg),
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar alterações'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoLista({
    required String titulo,
    required String dica,
    required List<String> chips,
    required Future<void> Function() onAdicionar,
    required void Function(int index) onRemover,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < chips.length; i++)
              InputChip(
                label: Text(chips[i]),
                onDeleted: () => onRemover(i),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text('Adicionar ($dica)'),
              onPressed: onAdicionar,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _adicionarIva() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: 'Adicionar taxa de IVA',
      label: 'Taxa (ex.: 23)',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (valor == null) return;

    final parsed = double.tryParse(valor.replaceAll(',', '.'));
    if (parsed == null || parsed < 0 || parsed > 100) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: 'Valor de IVA inválido. Use um número entre 0 e 100.',
          tipo: TipoSnackBar.aviso,
        );
      }
      return;
    }

    if (_ivaOptions.contains(parsed)) return;
    setState(() {
      _ivaOptions.add(parsed);
      _ivaOptions.sort();
    });
  }

  Future<void> _adicionarTextoUnidade() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: 'Adicionar unidade',
      label: 'Unidade (ex.: un, kg, h)',
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _unidades.contains(texto)) return;
    setState(() => _unidades.add(texto));
  }

  Future<void> _adicionarTextoEstado() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: 'Adicionar estado de fatura',
      label: 'Estado (ex.: emitida)',
    );
    if (valor == null) return;
    final texto = valor.trim().toLowerCase();
    if (texto.isEmpty || _estadosFatura.contains(texto)) return;
    setState(() => _estadosFatura.add(texto));
  }

  Future<void> _adicionarMeioPagamento() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: 'Adicionar meio de pagamento',
      label: 'Meio de pagamento (ex.: MB Way)',
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _meiosPagamento.contains(texto)) return;
    setState(() => _meiosPagamento.add(texto));
  }

  Future<void> _adicionarTipoDocumento() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: 'Adicionar tipo de documento',
      label: 'Tipo (ex.: Fatura Proforma)',
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _tiposDocumento.contains(texto)) return;
    setState(() => _tiposDocumento.add(texto));
  }

  Future<String?> _mostrarDialogoInput({
    required String titulo,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: _itemController,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_itemController.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvar(ConfiguracaoEmpresa cfg) async {
    final nome = _nomeEmpresaController.text.trim();
    final nif = _nifController.text.trim();
    final morada = _moradaController.text.trim();
    final codigoPostal = _codigoPostalController.text.trim();
    final localidade = _localidadeController.text.trim();
    final pais = _paisController.text.trim();
    final serie = _serieAtualController.text.trim();

    // Validações
    if (nome.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Indique o nome da empresa.',
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(0); // Ir para aba de dados básicos
      return;
    }

    if (nif.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'NIF é obrigatório.',
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(1); // Ir para aba de dados fiscais
      return;
    }

    if (!FaturaLegalService.validarNIF(nif)) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'NIF inválido. Deve ter 9 dígitos válidos.',
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    if (morada.isEmpty || codigoPostal.isEmpty || localidade.isEmpty || pais.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Morada, código postal, localidade e país são obrigatórios.',
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(1);
      return;
    }

    if (!FaturaLegalService.validarCodigoPostal(codigoPostal)) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Código postal inválido. Use o formato XXXX-XXX.',
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    if (serie.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Série atual é obrigatória.',
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(3); // Ir para aba de documentos
      return;
    }

    final config = ConfiguracaoEmpresa(
      nomeEmpresa: nome,
      nif: nif,
      morada: morada,
      codigoPostal: codigoPostal,
      localidade: localidade,
      pais: pais,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      telefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
      cae: _caeController.text.trim().isEmpty ? null : _caeController.text.trim(),
      capitalSocial: _capitalSocialController.text.trim().isEmpty ? null : _capitalSocialController.text.trim(),
      conservatoria: _conservatoriaController.text.trim().isEmpty ? null : _conservatoriaController.text.trim(),
      numeroRegistoComercial: _numeroRegistoComercialController.text.trim().isEmpty ? null : _numeroRegistoComercialController.text.trim(),
      numeroChaveCertificacaoAT: _numeroChaveCertificacaoATController.text.trim().isEmpty ? null : _numeroChaveCertificacaoATController.text.trim(),
      codigoValidacaoSoftwareAT: _codigoValidacaoSoftwareATController.text.trim().isEmpty ? null : _codigoValidacaoSoftwareATController.text.trim(),
      ivaOptions: _ivaOptions,
      unidades: _unidades,
      estadosFatura: _estadosFatura,
      meiosPagamento: _meiosPagamento,
      tiposDocumento: _tiposDocumento,
      serieAtual: serie,
      adminPinHash: _adminPinHash,
    );

    try {
      await ref.read(configuracoesProvider.notifier).salvarConfiguracoes(config);
      if (!mounted) return;
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Configurações guardadas com sucesso.',
        tipo: TipoSnackBar.sucesso,
      );
    } catch (e) {
      if (!mounted) return;
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Erro ao guardar configurações: $e',
        tipo: TipoSnackBar.erro,
      );
    }
  }

  Future<void> _alterarPin() async {
    final atualController = TextEditingController();
    final novoController = TextEditingController();
    final confirmarController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar PIN de administrador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: atualController,
              decoration: const InputDecoration(labelText: 'PIN atual'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: novoController,
              decoration: const InputDecoration(labelText: 'Novo PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmarController,
              decoration: const InputDecoration(labelText: 'Confirmar novo PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (!mounted) return;

    final atual = atualController.text.trim();
    final novo = novoController.text.trim();
    final confirmarNovo = confirmarController.text.trim();

    if (!AdminAuthService.validarPin(atual, _adminPinHash)) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'PIN atual inválido.',
        tipo: TipoSnackBar.erro,
      );
      return;
    }

    if (novo.length < 4 || novo.length > 12) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'O novo PIN deve ter entre 4 e 12 dígitos.',
        tipo: TipoSnackBar.aviso,
      );
      return;
    }

    if (novo != confirmarNovo) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'A confirmação do PIN não coincide.',
        tipo: TipoSnackBar.aviso,
      );
      return;
    }

    setState(() {
      _adminPinHash = AdminAuthService.hashPin(novo);
    });

    if (!mounted) return;
    UiHelpers.mostrarSnackBar(
      context,
      mensagem: 'PIN de administrador atualizado. Não se esqueça de guardar alterações.',
      tipo: TipoSnackBar.sucesso,
    );
  }
}
