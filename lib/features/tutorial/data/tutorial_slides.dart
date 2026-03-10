import 'package:flutter/material.dart';

/// Modelo de dados para cada slide do tutorial.
class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? features;

  const TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.features,
  });
}

/// Lista de slides do tutorial.
class TutorialSlides {
  static const List<TutorialSlide> slides = [
    TutorialSlide(
      title: 'Bem-vindo ao Facturio',
      description: 'Sistema completo de faturação empresarial com gestão de clientes, produtos e pagamentos.',
      icon: Icons.receipt_long,
      color: Colors.blue,
      features: [
        'Gestão offline com sincronização automática',
        'Interface moderna e intuitiva',
        'Relatórios financeiros em tempo real',
      ],
    ),
    TutorialSlide(
      title: 'Gestão de Clientes',
      description: 'Cadastre e gerencie seus clientes com informações completas.',
      icon: Icons.people,
      color: Colors.green,
      features: [
        'Cadastro completo com NIF e morada',
        'Histórico de faturas por cliente',
        'Pesquisa rápida e eficiente',
      ],
    ),
    TutorialSlide(
      title: 'Catálogo de Produtos',
      description: 'Organize seu inventário com controlo de stock e preços.',
      icon: Icons.inventory,
      color: Colors.orange,
      features: [
        'Gestão de stock com alertas',
        'Múltiplas taxas de IVA',
        'Preços personalizáveis',
      ],
    ),
    TutorialSlide(
      title: 'Faturação Profissional',
      description: 'Emita faturas legais com QR Code e cumprimento da lei portuguesa.',
      icon: Icons.description,
      color: Colors.purple,
      features: [
        'Faturas com conformidade legal',
        'QR Code automático (AT)',
        'Cálculo de IVA e retenção na fonte',
      ],
    ),
    TutorialSlide(
      title: 'Sistema de Pagamentos',
      description: 'Controle pagamentos parciais e múltiplos meios de pagamento.',
      icon: Icons.payments,
      color: Colors.teal,
      features: [
        'Múltiplos pagamentos parciais',
        '10 meios de pagamento',
        'Status visual com progresso',
      ],
    ),
    TutorialSlide(
      title: 'Impressão e Partilha',
      description: 'Gere PDFs profissionais e exporte para Excel.',
      icon: Icons.print,
      color: Colors.indigo,
      features: [
        'PDF de alta qualidade',
        'Partilha direta por email/WhatsApp',
        'Exportação para Excel (CSV)',
      ],
    ),
    TutorialSlide(
      title: 'Dashboard Inteligente',
      description: 'Acompanhe seu negócio com indicadores e resumos financeiros.',
      icon: Icons.dashboard,
      color: Colors.pink,
      features: [
        'Total faturado e recebido',
        'Faturas pendentes',
        'Alertas de stock baixo',
      ],
    ),
    TutorialSlide(
      title: 'Configurações Personalizadas',
      description: 'Adapte o sistema às necessidades da sua empresa.',
      icon: Icons.settings,
      color: Colors.amber,
      features: [
        'Dados da empresa editáveis',
        'Taxas de IVA personalizadas',
        'Meios de pagamento configuráveis',
        'Backup e restauro de dados',
      ],
    ),
  ];
}
