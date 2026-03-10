class AppConstants {
  // App Info
  static const String appName = 'Facturio';
  static const String appVersion = '1.0.0';

  // Taxas de IVA em Portugal
  static const double ivaNormal = 23.0;
  static const double ivaIntermedio = 13.0;
  static const double ivaReduzido = 6.0;
  static const double ivaIsento = 0.0;

  static const List<double> ivaOptions = [
    ivaNormal,
    ivaIntermedio,
    ivaReduzido,
    ivaIsento,
  ];

  // Unidades
  static const List<String> unidades = [
    'un',
    'kg',
    'm',
    'm²',
    'm³',
    'l',
    'h',
  ];

  // Estados da Fatura
  static const String estadoRascunho = 'rascunho';
  static const String estadoEmitida = 'emitida';
  static const String estadoPaga = 'paga';
  static const String estadoCancelada = 'cancelada';

  static const List<String> estadosFatura = [
    estadoRascunho,
    estadoEmitida,
    estadoPaga,
    estadoCancelada,
  ];

  // Meios de Pagamento
  static const List<String> meiosPagamento = [
    'Numerário',
    'Transferência Bancária',
    'Multibanco',
    'MB Way',
    'Débito Direto',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Cheque',
    'PayPal',
    'Outro',
  ];

  // Tipos de Documento (segundo a lei portuguesa)
  static const String tipoFatura = 'Fatura';
  static const String tipoFaturaSimplificada = 'Fatura Simplificada';
  static const String tipoFaturaRecibo = 'Fatura-Recibo';
  static const String tipoNotaCredito = 'Nota de Crédito';
  static const String tipoNotaDebito = 'Nota de Débito';

  static const List<String> tiposDocumento = [
    tipoFatura,
    tipoFaturaSimplificada,
    tipoFaturaRecibo,
    tipoNotaCredito,
    tipoNotaDebito,
  ];

  // Motivos de Isenção de IVA (artigos CIVA)
  static const List<String> motivosIsencaoIVA = [
    'M01 - Artigo 16.º n.º 6 do CIVA (Transmissões de bens e serviços isentas)',
    'M02 - Artigo 6.º do Decreto-Lei n.º 198/90 (Vendas à distância)',
    'M03 - Exigibilidade de caixa',
    'M04 - Regime de isenção do IVA (Artigo 53.º)',
    'M05 - Regime de isenção do IVA (Artigo 57.º)',
    'M06 - Regime de não sujeição do IVA (Artigo 3.º)',
    'M07 - Regime especial de IVA das agências de viagens',
    'M08 - Autoliquidação',
    'M09 - IVA - não confere direito a dedução',
    'M10 - Regime de isenção do IVA (Artigo 59.º)',
    'M11 - Regime particular do tabaco',
    'M12 - Regime da margem de lucro – Bens em segunda mão',
    'M13 - Regime da margem de lucro – Objetos de arte',
    'M14 - Regime da margem de lucro – Objetos de coleção e antiguidades',
    'M15 - Prestação de serviços de intermediários em nome e por conta de outrem',
    'M16 - IVA de caixa',
    'M19 - Regime forfetário',
    'M20 - Autoliquidação - Bens',
    'M21 - Autoliquidação - Serviços',
    'M99 - Não sujeito; não tributado',
  ];

  // Hive Box Names
  static const String clientesBox = 'clientes';
  static const String produtosBox = 'produtos';
  static const String faturasBox = 'faturas';
  static const String configBox = 'config';
}
