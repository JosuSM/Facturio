class ProdutoAlteracao {
  final DateTime dataCriacao;
  final int versao;
  final double precoAnterior;
  final double precoNovo;
  final String descricaoAlteracao; // ex: "Atualização de preço", "Alteração de IVA"

  ProdutoAlteracao({
    required this.dataCriacao,
    required this.versao,
    required this.precoAnterior,
    required this.precoNovo,
    required this.descricaoAlteracao,
  });

  static String formatarDescricao(String tipo, double? valorAnterior, double? valorNovo) {
    switch (tipo) {
      case 'preco':
        return 'Alteração de preço: ${valorAnterior?.toStringAsFixed(2)}€ → ${valorNovo?.toStringAsFixed(2)}€';
      case 'iva':
        return 'Alteração de IVA: $valorAnterior% → $valorNovo%';
      case 'descricao':
        return 'Alteração de descrição';
      case 'unidade':
        return 'Alteração de unidade de medida';
      default:
        return 'Alteração do produto';
    }
  }
}
