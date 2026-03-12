# Facturio

Sistema de faturação moderno e intuitivo para empresas. Gestão completa de clientes, produtos e pagamentos com funcionamento offline, personalização por empresa e exportação SAF-T(PT) integrada.

## Índice

- [O que é Facturio](#o-que-é-facturio)
- [Plataformas suportadas](#plataformas-suportadas)
- [Funcionalidades principais](#funcionalidades-principais)
- [Desenvolvimento recente](#desenvolvimento-recente)
- [Começar](#começar)
- [Builds e pacotes](#builds-e-pacotes)
- [Guia funcional](#guia-funcional)
- [Qualidade e validação](#qualidade-e-validação)
- [Licença](#licença)

## O que é Facturio

Aplicação de faturação para PMEs desenvolvida em Flutter. Oferece operações completas de gestão (clientes, produtos, faturas, pagamentos) com armazenamento local, interface personalizável e pronto para compliance fiscal português (SAF-T).

## Plataformas suportadas

- **Linux** (`Facturio.deb`) — desktop completo com instalação nativa
- **Android** (`Facturio.apk`) — mobile com sincronização
- **Web** — acesso via browser, sem instalação

*macOS e iOS não se encontram em desenvolvimento ativo no âmbito atual do projeto.*

## Funcionalidades principais

**Gestão de negócio**
- Cadastro e histórico de clientes, catálogo de produtos com stock.
- Emissão de faturas com IVA automático.
- Sistema completo de pagamentos (múltiplos pagamentos, histórico, 10 meios).
- Dashboard com resumo financeiro e alertas.

**Documentação e conformidade**
- Geração, impressão e partilha de PDF.
- Exportação CSV para Excel.
- Exportação SAF-T(PT) v1.04 pronta para auditoria.

**Experiência e customização**
- Funcionamento offline com sincronização local.
- 10 temas + cores personalizáveis, modo claro/escuro.
- 6 ícones de app alternativos, ajuste de texto (80%–140%).
- Tutorial interativo, acesso administrativo protegido por PIN.
- Backup e restauro de dados.

## Desenvolvimento recente

- **Seriação profissional de produtos** — número de série único, versão automática, histórico de alterações, rastreamento de preços.
- **Exportação SAF-T(PT)** — conformidade fiscal automática com XML v1.04.
- **Sistema de pagamentos** — múltiplos pagamentos por fatura, histórico, validações.
- **Página de licença bilíngue** — MIT em português e inglês.
- **Ícones e temas personalizáveis** — 10 temas + cores próprias.
- **Estabilidade mobile** — importação de backups e acesso administrativo protegido.

## Requisitos de desenvolvimento

- Flutter SDK (estável) + Dart
- Android SDK (para builds Android)
- Linux toolchain (para builds Linux)
- VS Code (recomendado)

## Começar

Guia detalhado: [INSTALACAO_MULTIPLATAFORMA.md](INSTALACAO_MULTIPLATAFORMA.md)

```bash
cd /media/huskydb/FicheirosA2/IEFP/Facturio
flutter pub get
flutter analyze && flutter test
flutter run -d android    # ou: -d linux, -d chrome
```

## Builds e pacotes

### Build rápida

```bash
bash build_linux.sh
```

### Exportação de pacotes

```bash
./export_packages.sh
./create_deb.sh
```

Pacotes gerados em `dist/<timestamp>/`: `Facturio.apk`, `Facturio.aab`, `Facturio.deb`, `Facturio-linux.tar.gz`, `Facturio-web.zip`.

## Guia funcional

**Tutorial** — Exibido automaticamente na primeira execução. Para rever: Configurações → Dados Básicos → Ajuda e Tutorial. Documentação: [TUTORIAL_SISTEMA.md](TUTORIAL_SISTEMA.md)

**Personalização** — Menu lateral ou Configurações → Dados Básicos. Temas, cores, modo claro/escuro, ícones e tamanho de texto. Guia: [PERSONALIZACAO_GUIA.md](PERSONALIZACAO_GUIA.md)

**Gestão de Produtos** — Cadastro profissional com código único, nome, descrição, preço unitário e unidade de medida. 

**Seriação de Produtos:**
- Número de série único gerado automaticamente por produto (formato: `PROD-YYYYMMDD-XXXXXXXX`)
- Versão de produto com rastreamento automático de alterações
- Histórico completo de mudanças: data, versão anterior, preço anterior e novo
- Rastreamento de IVA com registar de todas as alterações
- Stock em tempo real com sincronização entre plataformas
- Importação/exportação CSV para atualização em massa

Acesso através da lista de produtos → Detalhe do produto → "Informações de Serialização" para auditoria, compliance e rastreamento histórico.

**Sistema de ícones no Linux** —
```bash
bash install_icon.sh
```

**Pagamentos** — Detalhe da fatura → "Adicionar Pagamento" → preencher dados → confirmar. O dashboard mostra totais automaticamente.

**Exportação SAF-T** — Menu lateral → "Exportar SAF-T" → selecionar período → confirmar. Exporta XML de conformidade fiscal pronto para auditoria (requer NIF e morada da empresa configurados).

**Acesso administrativo** — PIN predefinido: `1234`. Recomenda-se alterar imediatamente.

## Estrutura do projeto

Arquitetura feature-first:
- `lib/features/` — domínios (clientes, produtos, faturas, pagamentos, dashboard, etc.)
- `lib/core/` — serviços transversais (estado, armazenamento, PDF, SAF-T)
- `lib/shared/` — componentes comuns

Tecnologias: Flutter/Dart, Riverpod (estado), Hive (persistência local), GoRouter (navegação).

## Qualidade e validação

```bash
flutter analyze     # sem issues
flutter test        # cobertura em serviços críticos
```

**Padrões:** Material Design 3, grid de 8dp, feature-first, persistência local, testes unitários e e2e.

**Suporte:** testes para SAF-T, pagamentos, backup e mobile.

## Licença

MIT. Licenças de referência: [LICENSE](LICENSE) (EN) | [LICENCA_MIT_PT.md](LICENCA_MIT_PT.md) (PT)
