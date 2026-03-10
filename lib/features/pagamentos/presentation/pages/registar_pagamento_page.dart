import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/models/pagamento.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../faturas/domain/entities/fatura.dart';
import '../providers/pagamentos_provider.dart';
import 'package:intl/intl.dart';

/// Página para registar um novo pagamento numa fatura.
class RegistarPagamentoPage extends ConsumerStatefulWidget {
  final Fatura fatura;
  final List<Pagamento> pagamentosExistentes;

  const RegistarPagamentoPage({
    super.key,
    required this.fatura,
    required this.pagamentosExistentes,
  });

  @override
  ConsumerState<RegistarPagamentoPage> createState() => _RegistarPagamentoPageState();
}

class _RegistarPagamentoPageState extends ConsumerState<RegistarPagamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _meioPagamentoSelecionado;
  DateTime _dataPagamento = DateTime.now();
  double _valorEmDivida = 0;

  @override
  void initState() {
    super.initState();
    _valorEmDivida = PagamentosService.calcularValorEmDivida(
      widget.fatura,
      widget.pagamentosExistentes,
    );
    _valorController.text = _valorEmDivida.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _referenciaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final config = ref.watch(configuracoesProvider).value;
    final meiosPagamento = config?.meiosPagamento ?? AppConstants.meiosPagamento;

    final totalFatura = widget.fatura.totalComRetencao;
    final totalPago = PagamentosService.calcularTotalPago(widget.pagamentosExistentes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registar Pagamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com info da fatura
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
                      'Fatura ${widget.fatura.numero}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.fatura.clienteNome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Resumo financeiro
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total da Fatura:'),
                          Text(
                            '€${totalFatura.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (widget.pagamentosExistentes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Já Pago (${widget.pagamentosExistentes.length} ${widget.pagamentosExistentes.length == 1 ? "pagamento" : "pagamentos"}):',
                              style: const TextStyle(color: Colors.green),
                            ),
                            Text(
                              '€${totalPago.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Valor em Dívida:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '€${_valorEmDivida.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _valorEmDivida > 0 ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulário
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dados do Pagamento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Valor
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor do Pagamento *',
                          prefixIcon: Icon(Icons.euro),
                          helperText: 'Valor a registar neste pagamento',
                          suffixText: '€',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final valor = double.tryParse(value.replaceAll(',', '.'));
                          if (valor == null || valor <= 0) {
                            return 'Valor inválido';
                          }
                          final erro = PagamentosService.validarPagamento(
                            fatura: widget.fatura,
                            pagamentosExistentes: widget.pagamentosExistentes,
                            valorNovoPagamento: valor,
                          );
                          return erro;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Meio de Pagamento
                      DropdownButtonFormField<String>(
                        initialValue: _meioPagamentoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Meio de Pagamento *',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        hint: const Text('Selecione o meio de pagamento'),
                        items: meiosPagamento.map((meio) {
                          return DropdownMenuItem(
                            value: meio,
                            child: Text(meio),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _meioPagamentoSelecionado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data do Pagamento
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Data do Pagamento'),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(_dataPagamento),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: _dataPagamento,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (data != null) {
                            setState(() {
                              _dataPagamento = data;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Referência
                      TextFormField(
                        controller: _referenciaController,
                        decoration: const InputDecoration(
                          labelText: 'Referência',
                          prefixIcon: Icon(Icons.tag),
                          helperText: 'Nº cheque, referência transferência, etc.',
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      TextFormField(
                        controller: _observacoesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _registarPagamento,
                      icon: const Icon(Icons.check),
                      label: const Text('Registar Pagamento'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registarPagamento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));

      await ref.read(pagamentosProvider.notifier).adicionarPagamento(
            faturaId: widget.fatura.id,
            valor: valor,
            meioPagamento: _meioPagamentoSelecionado!,
            dataPagamento: _dataPagamento,
            referencia: _referenciaController.text.trim().isEmpty
                ? null
                : _referenciaController.text.trim(),
            observacoes: _observacoesController.text.trim().isEmpty
                ? null
                : _observacoesController.text.trim(),
          );

      if (!mounted) return;

      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Pagamento registado com sucesso!',
        tipo: TipoSnackBar.sucesso,
      );

      context.pop(true); // Retorna true para indicar sucesso
    } catch (e) {
      if (!mounted) return;

      UiHelpers.mostrarSnackBar(
        context,
        mensagem: 'Erro ao registar pagamento: $e',
        tipo: TipoSnackBar.erro,
      );
    }
  }
}
