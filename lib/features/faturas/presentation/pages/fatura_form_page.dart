import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/models/linha_fatura.dart';
import '../../domain/entities/fatura.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../providers/faturas_provider.dart';

class FaturaFormPage extends ConsumerStatefulWidget {
  final String? faturaId;

  const FaturaFormPage({super.key, this.faturaId});

  @override
  ConsumerState<FaturaFormPage> createState() => _FaturaFormPageState();
}

class _FaturaFormPageState extends ConsumerState<FaturaFormPage> {
  String? _clienteSelecionadoId;
  String? _clienteSelecionadoNome;
  String _estadoSelecionado = AppConstants.estadoRascunho;
  String _tipoDocumentoSelecionado = 'Fatura';
  String? _meioPagamentoSelecionado;
  String? _motivoIsencaoIVASelecionado;
  bool _aplicarRetencao = false;
  double _percentagemRetencao = 25.0;
  final List<LinhaFatura> _linhas = [];
  final _clienteNifController = TextEditingController();
  final _clienteMoradaController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _clienteNifController.dispose();
    _clienteMoradaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final config = ref.watch(configuracoesProvider).maybeWhen(
          data: (cfg) => cfg,
          orElse: () => null,
        );
    final estados =
        config?.estadosFatura.isNotEmpty == true ? config!.estadosFatura : AppConstants.estadosFatura;
    final estadosDropdown = {...estados, _estadoSelecionado}.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Fatura'),
      ),
      body: SingleChildScrollView(
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
                    'Emissão de Fatura',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Selecione cliente, estado e adicione linhas de produto.',
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
                    clientesAsync.when(
                      data: (clientes) {
                        return DropdownButtonFormField<String>(
                          initialValue: _clienteSelecionadoId,
                          decoration: const InputDecoration(
                            labelText: 'Cliente *',
                            prefixIcon: Icon(Icons.person),
                          ),
                          hint: const Text('Selecione um cliente'),
                          items: clientes.map((cliente) {
                            return DropdownMenuItem(
                              value: cliente.id,
                              child: Text(cliente.nome),
                            );
                          }).toList(),
                          onChanged: (value) {
                            final cliente = clientes.firstWhere((c) => c.id == value);
                            setState(() {
                              _clienteSelecionadoId = value;
                              _clienteSelecionadoNome = cliente.nome;
                            });
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => const Text('Erro ao carregar clientes'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.info),
                      ),
                      items: estadosDropdown.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoSelecionado = value!;
                        });
                      },
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
                    Text(
                      'Dados do Documento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (config != null)
                      DropdownButtonFormField<String>(
                        initialValue: _tipoDocumentoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Documento *',
                          prefixIcon: Icon(Icons.description),
                        ),
                        items: config.tiposDocumento.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoDocumentoSelecionado = value!;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _clienteNifController,
                      decoration: const InputDecoration(
                        labelText: 'NIF do Cliente',
                        prefixIcon: Icon(Icons.badge),
                        helperText: '9 dígitos (opcional)',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _clienteMoradaController,
                      decoration: const InputDecoration(
                        labelText: 'Morada do Cliente',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    if (config != null)
                      DropdownButtonFormField<String>(
                        initialValue: _meioPagamentoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Meio de Pagamento',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        hint: const Text('Selecione um meio de pagamento'),
                        items: config.meiosPagamento.map((meio) {
                          return DropdownMenuItem(
                            value: meio,
                            child: Text(meio),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _meioPagamentoSelecionado = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _aplicarRetencao,
                      title: const Text('Aplicar Retenção na Fonte'),
                      subtitle: _aplicarRetencao
                          ? Text('${_percentagemRetencao.toStringAsFixed(1)}%')
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _aplicarRetencao = value ?? false;
                        });
                      },
                    ),
                    if (_aplicarRetencao)
                      Slider(
                        value: _percentagemRetencao,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label: '${_percentagemRetencao.toStringAsFixed(1)}%',
                        onChanged: (value) {
                          setState(() {
                            _percentagemRetencao = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _motivoIsencaoIVASelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de Isenção de IVA',
                        prefixIcon: Icon(Icons.discount),
                        helperText: 'Apenas se aplicável',
                      ),
                      hint: const Text('Nenhum'),
                      items: AppConstants.motivosIsencaoIVA.map((motivo) {
                        return DropdownMenuItem(
                          value: motivo,
                          child: Text(
                            motivo.length > 60 ? '${motivo.substring(0, 60)}...' : motivo,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _motivoIsencaoIVASelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.note),
                        helperText: 'Informações adicionais para a fatura',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _mostrarDialogoProduto(produtosAsync.value ?? []),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Produto'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Produtos/Serviços',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_linhas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum produto adicionado'),
                ),
              )
            else
              ..._linhas.asMap().entries.map((entry) {
                final index = entry.key;
                final linha = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(linha.produtoNome),
                    subtitle: Text(
                      'Qtd: ${linha.quantidade} | €${linha.total.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _linhas.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _linhas.isEmpty || _clienteSelecionadoId == null
                  ? null
                  : _criarFatura,
              icon: const Icon(Icons.receipt_long),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              label: const Text('Criar Fatura'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProduto(List produtos) {
    String? produtoSelecionadoId;
    final quantidadeController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              hint: const Text('Selecione um produto'),
              items: produtos.map((produto) {
                return DropdownMenuItem(
                  value: produto.id,
                  child: Text('${produto.nome} - €${produto.preco}'),
                );
              }).toList(),
              onChanged: (value) {
                produtoSelecionadoId = value as String?;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (produtoSelecionadoId != null) {
                final produto = produtos.firstWhere((p) => p.id == produtoSelecionadoId);
                final quantidade = double.tryParse(quantidadeController.text) ?? 1;
                
                setState(() {
                  _linhas.add(LinhaFatura.fromProduto(produto, quantidade));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _criarFatura() async {
    if (_clienteSelecionadoId == null || _clienteSelecionadoNome == null) {
      return;
    }

    try {
      // Obter configuração para série e tipo de documento
      final configAsync = ref.read(configuracoesProvider);
      final config = configAsync.value;
      
      if (config == null) {
        throw Exception('Configuração da empresa não disponível');
      }

      // Validar NIF do cliente se foi preenchido
      final clienteNif = _clienteNifController.text.trim();
      if (clienteNif.isNotEmpty && !FaturaLegalService.validarNIF(clienteNif)) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: 'NIF do cliente inválido. Deve ter 9 dígitos válidos.',
          tipo: TipoSnackBar.erro,
        );
        return;
      }

      // Calcular valores
      final subtotal = _linhas.fold<double>(0, (sum, linha) => sum + linha.total);
      double? valorRetencao;
      if (_aplicarRetencao) {
        valorRetencao = FaturaLegalService.calcularRetencao(
          valorBase: subtotal,
          taxaRetencao: _percentagemRetencao,
        );
      }

      final fatura = Fatura(
        id: '',
        numero: '',
        data: DateTime.now(),
        clienteId: _clienteSelecionadoId!,
        clienteNome: _clienteSelecionadoNome!,
        linhas: _linhas,
        estado: _estadoSelecionado,
        tipoDocumento: _tipoDocumentoSelecionado,
        serie: config.serieAtual,
        dataCriacao: DateTime.now(),
        clienteNif: clienteNif.isEmpty ? null : clienteNif,
        clienteMorada: _clienteMoradaController.text.trim().isEmpty 
            ? null 
            : _clienteMoradaController.text.trim(),
        meioPagamento: _meioPagamentoSelecionado,
        retencaoFonte: _aplicarRetencao ? _percentagemRetencao : null,
        valorRetencao: valorRetencao,
        motivoIsencaoIVA: _motivoIsencaoIVASelecionado,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
      );

      await ref.read(faturasProvider.notifier).addFatura(fatura);

      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: 'Fatura criada com sucesso',
          tipo: TipoSnackBar.sucesso,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: 'Erro ao criar fatura: $e',
          tipo: TipoSnackBar.erro,
        );
      }
    }
  }
}
