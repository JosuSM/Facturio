import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/i18n/app_text.dart';
import '../../domain/entities/produto.dart';
import '../providers/produtos_provider.dart';
import '../widgets/serialization_info_widget.dart';

class ProdutoDetailPage extends ConsumerWidget {
  final String produtoId;

  const ProdutoDetailPage({
    Key? key,
    required this.produtoId,
  }) : super(key: key);

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtoAsync = ref.watch(
      produtosProvider.select(
        (async) => async.whenData(
          (produtos) => produtos.firstWhere(
            (p) => p.id == produtoId,
            orElse: () => throw Exception('Produto não encontrado'),
          ),
        ),
      ),
    );

    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Detalhe do Produto', en: 'Product Detail')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: produtoAsync.when(
        data: (produto) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações Básicas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nome,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          produto.descricao,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Preço e Stock
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t(context, pt: 'Preço', en: 'Price'),
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatoMoeda.format(produto.preco),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t(context, pt: 'Stock', en: 'Stock'),
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${produto.stock} ${produto.unidade}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // IVA
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IVA',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${produto.iva.toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Informações de Serialização
                SerializationInfoWidget(produto: produto),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro: $error'),
        ),
      ),
    );
  }
}
