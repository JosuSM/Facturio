import 'package:flutter/material.dart';
import '../../domain/entities/produto.dart';
import 'package:intl/intl.dart';

class SerializationInfoWidget extends StatelessWidget {
  final Produto produto;

  const SerializationInfoWidget({
    super.key,
    required this.produto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isoDate = DateFormat('dd/MM/yyyy HH:mm').format(produto.dataCriacao);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Série e Versão
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações de Serialização',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Número de Série',
                            style: theme.textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            produto.serieNumero,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Versão',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'v${produto.versao}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Data de Criação',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  isoDate,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        
        // Histórico de Alterações
        if (produto.historicoAlteracoes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Histórico de Alterações',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: produto.historicoAlteracoes.length,
            itemBuilder: (context, index) {
              final alteracao = produto.historicoAlteracoes[index];
              final dataAlteracao = DateFormat('dd/MM/yyyy HH:mm').format(
                alteracao.dataCriacao,
              );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              alteracao.descricaoAlteracao,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'v${alteracao.versao}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataAlteracao,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
