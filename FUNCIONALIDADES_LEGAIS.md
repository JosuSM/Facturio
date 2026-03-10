# Funcionalidades Legais de Faturação - Implementação

## ⚠️ AVISO IMPORTANTE - CERTIFICAÇÃO OBRIGATÓRIA

Este documento descreve funcionalidades legais **SIMULADAS** para fins educativos e de desenvolvimento.

**Para uso REAL em produção numa empresa em Portugal, é OBRIGATÓRIO:**

1. ✅ **Certificar o software** junto da **AT (Autoridade Tributária e Aduaneira)**
2. ✅ **Obter chaves de certificação AT** reais
3. ✅ **Integrar com os webservices da AT** para geração de códigos ATCUD oficiais
4. ✅ **Implementar comunicação de documentos** à AT conforme legislação
5. ✅ **Cumprir portaria n.º 363/2010** e subsequentes actualizações

**A não certificação do software é uma CONTRAORDENAÇÃO GRAVE segundo a lei portuguesa, punível com coimas até €22.500.**

---

## 📋 Funcionalidades Implementadas

### 1. **Dados Obrigatórios da Empresa Emissora**

Implementado em: `lib/core/models/configuracao_empresa.dart`

Campos adicionados segundo requisitos legais:
- ✅ **NIF** (Número de Identificação Fiscal) - OBRIGATÓRIO
- ✅ **Morada completa** - OBRIGATÓRIO
- ✅ **Código Postal** - OBRIGATÓRIO
- ✅ **Localidade** - OBRIGATÓRIO
- ✅ **País** - OBRIGATÓRIO
- ✅ Email e Telefone (recomendados)
- ✅ **CAE** (Classificação de Atividades Económicas)
- ✅ Capital Social (para sociedades)
- ✅ Conservatória de Registo Comercial
- ✅ Número de matrícula na conservatória
- ✅ Chave de certificação AT
- ✅ Código de validação do software AT

### 2. **Tipos de Documentos**

Implementado em: `lib/core/constants/app_constants.dart`

Tipos de documentos suportados:
- ✅ **Fatura** (FT)
- ✅ **Fatura Simplificada** (FS)
- ✅ **Fatura-Recibo** (FR)
- ✅ **Nota de Crédito** (NC) - Para devoluções e anulações
- ✅ **Nota de Débito** (ND) - Para correções de valores

### 3. **Sistema de Séries**

Implementado em: `ConfiguracaoEmpresa`

- ✅ Série configurável por empresa (ex: A, B, 2024, etc.)
- ✅ Numeração sequencial por série
- ✅ Formato: `SERIE ANO/NUMERO` (ex: A 2024/1)

### 4. **Código ATCUD (Código Único do Documento)**

Implementado em: `lib/core/services/fatura_legal_service.dart`

- ✅ Geração de ATCUD **SIMULADO** para testes
- ⚠️ **ATENÇÃO**: Em produção, deve ser obtido via webservice da AT
- ✅ Formato: `[Código de validação AT]-[Número sequencial]`

### 5. **Hash de Documento (Validação de Sequência)**

Implementado em: `FaturaLegalService.gerarHashDocumento()`

- ✅ Hash SHA-256 para garantir integridade e sequência dos documentos
- ✅ Vinculação com documento anterior (hash encadeado)
- ✅ Previne alteração ou eliminação de documentos

### 6. **Dados para QR Code AT**

Implementado em: `FaturaLegalService.gerarDadosQRCode()`

Formato de dados conforme especificações AT:
- ✅ NIF Emissor
- ✅ NIF Adquirente (Cliente)
- ✅ País
- ✅ Tipo de documento
- ✅ Data e número do documento
- ✅ ATCUD
- ✅ Valores (Subtotal, IVA, Total)

### 7. **Meios de Pagamento**

Implementado em: `AppConstants.meiosPagamento`

Lista de meios de pagamento disponíveis:
- Numerário
- Transferência Bancária
- Multibanco
- MB Way
- Débito Direto
- Cartão de Crédito
- Cartão de Débito
- Cheque
- PayPal
- Outro

### 8. **Isenções de IVA com Motivo Legal**

Implementado em: `AppConstants.motivosIsencaoIVA`

Todos os motivos de isenção segundo o CIVA (Código do IVA):
- ✅ M01 a M21 - Todos os artigos do CIVA
- ✅ M99 - Não sujeito/não tributado
- ✅ Integrado nos PDFs gerados

### 9. **Retenção na Fonte**

Implementado em: `Fatura` entity e `PdfService`

- ✅ Percentagem de retenção configurável
- ✅ Cálculo automático do valor retido
- ✅ Total a receber = Total - Retenção
- ✅ Exibição no PDF

### 10. **Dados do Cliente Obrigatórios**

Expandido em: `Fatura` entity

- ✅ NIF do cliente (obrigatório em faturas)
- ✅ Morada do cliente (obrigatória)
- ✅ Campos preservados por fatura (para histórico)

### 11. **Informações de Pagamento**

Implementado em: `Fatura` entity

- ✅ Meio de pagamento utilizado
- ✅ Data de pagamento
- ✅ Valor efetivamente pago
- ✅ Estado da fatura (paga/não paga)

### 12. **Observações e Notas**

Implementado em: `Fatura` entity

- ✅ Observações (aparecem no PDF)
- ✅ Notas internas (não aparecem no PDF)
- ✅ Documentos relacionados (origem para notas de crédito/débito)

### 13. **PDF Conforme com a Lei**

Implementado em: `lib/core/services/pdf_service.dart`

PDF atualizado com todos os elementos legais:
- ✅ Dados completos da empresa emissora
- ✅ NIF e morada da empresa destacados
- ✅ Tipo de documento no cabeçalho
- ✅ NIF e morada do cliente destacados
- ✅ Código ATCUD exibido
- ✅ Hash do documento (primeiros caracteres)
- ✅ Motivo de isenção de IVA (se aplicável)
- ✅ Retenção na fonte (se aplicável)
- ✅ Informações de pagamento
- ✅ Observações
- ✅ Rodapé com certificação AT e dados legais
- ✅ Placeholder para QR Code AT

### 14. **Validações Legais**

Implementado em: `FaturaLegalService`

- ✅ Validação de NIF português (com dígito de controlo)
- ✅ Validação de código postal português (XXXX-XXX)
- ✅ Cálculo de retenção na fonte
- ✅ Extração de número sequencial de documentos

### 15. **Exportação CSV com Todos os Campos**

Implementado em: `PdfService.exportarFaturaExcel()`

CSV estendido inclui:
- ✅ Dados completos da empresa
- ✅ Tipo de documento e série
- ✅ Código ATCUD
- ✅ Dados legais do cliente
- ✅ Totais com IVA e retenções
- ✅ Isenções de IVA
- ✅ Informações de pagamento
- ✅ Observações

---

## 🔧 O Que Falta Fazer

### **CRÍTICO - Necessário para funcionamento**

1. **Atualizar formulário de criação de faturas** (`fatura_form_page.dart`)
   - Adicionar campos: tipo de documento, série, meio de pagamento
   - Adicionar campos opcionais: retenção, isenção IVA, observações
   - Gerar ATCUD e hash ao criar fatura
   - Adicionar campos dataCriacao, tipoDocumento, serie no construtor

2. **Atualizar formulário de configurações** (`configuracoes_page.dart`)
   - Adicionar abas/seções para dados da empresa:
     - Dados fiscais (NIF, morada, CAE, etc.)
     - Certificação AT
     - Meios de pagamento
     - Tipos de documento
   - Corrigir construtor ConfiguracaoEmpresa com novos campos obrigatórios

3. **Atualizar provider de faturas** (`faturas_provider.dart`)
   - Passar tipoDocumento, serie, dataCriacao ao criar FaturaModel
   - Implementar geração de números sequenciais por série
   - Implementar geração de ATCUD e hash

4. **Atualizar lista de faturas** (`faturas_list_page.dart`)
   - Passar ConfiguracaoEmpresa para métodos de PDF
   - Exibir tipo de documento e série nas faturas
   - Adicionar filtros por tipo de documento e série

5. **Atualizar detalhes de fatura**
   - Exibir todos os novos campos
   - Mostrar informações de pagamento
   - Mostrar ATCUD e hash
   - Botão para visualizar QR Code

### **IMPORTANTE - Melhorias**

6. **Implementar geração real de QR Code**
   - Adicionar package qr_flutter
   - Gerar QR Code com dados formatados
   - Integrar no PDF

7. **Implementar contador sequencial de documentos**
   - Criar serviço para gerir numeração por série
   - Garantir que não há quebras de sequência
   - Prevenir duplicação de números

8. **Implementar validações no formulário**
   - Validar NIF do cliente
   - Validar código postal
   - Validar campos obrigatórios segundo o tipo de documento

9. **Migração de dados existentes**
   - Criar script de migração para faturas antigas
   - Adicionar campos em falta (tipoDocumento='Fatura', serie='A', etc.)
   - Preservar compatibilidade

### **OPCIONAL - Funcionalidades Avançadas**

10. **Integração real com AT** (⚠️ **OBRIGATÓRIO PARA PRODUÇÃO**)
    - Registar software na AT
    - Obter chaves de certificação
    - Implementar webservices da AT
    - Comunicar documentos emitidos
    - Obter ATCUD oficiais

11. **Relatórios legais**
    - Listagem de documentos por série
    - Verificação de sequências
    - Exportação para contabilidade
    - Mapa de IVA

12. **Notas de Crédito/Débito**
    - Formulário específico
    - Vinculação com documento original
    - Validações específicas

---

## 📝 Notas de Implementação

### Mudanças nos Models

**`ConfiguracaoEmpresa`**:
- **BREAKING CHANGE**: Novos campos obrigatórios (nif, morada, codigoPostal, localidade, pais)
- **BREAKING CHANGE**: Novos campos obrigatórios (meiosPagamento, tiposDocumento, serieAtual)
- Retrocompatibilidade: `fromJson()` fornece valores padrão

**`Fatura`**:
- **BREAKING CHANGE**: Novos campos obrigatórios (tipoDocumento, serie, dataCriacao)
- 18 novos campos opcionais
- Novos getters: `totalComRetencao`, `estaPaga`, `temIsencaoIVA`

**`FaturaModel`** (Hive):
- 19 novos HiveFields (7-25)
- Compatibilidade: campos opcionais não quebram documentos antigos
- ⚠️ Necessário regenerar com `dart run build_runner build`

### Mudanças nos Services

**`PdfService`**:
- **BREAKING CHANGE**: Todos os métodos agora requerem `ConfiguracaoEmpresa`
- Assinatura alterada:
  - `gerarFaturaPdf(fatura, cliente`, config`)`
  - `imprimirFatura(fatura, cliente, `config`)`
  - `compartilharFatura(fatura, cliente, `config`)`
  - `exportarFaturaExcel(fatura, cliente, `config`)`

**Novo `FaturaLegalService`**:
- Métodos estáticos para funcionalidades legais
- ATENÇÃO: Códigos ATCUD são SIMULADOS
- Validações de NIF e código postal

### Dependências

Nenhuma nova dependência necessária. Usa:
- `crypto` (já estava no projeto)
- Packages Flutter existentes

---

## 🚀 Próximos Passos Recomendados

### ✅ Fase 1: Correção de Erros (CONCLUÍDA)
1. ✅ Corrigir `configuracoes_page.dart` - adicionar campos obrigatórios
2. ✅ Corrigir `fatura_form_page.dart` - adicionar campos obrigatórios
3. ✅ Corrigir `faturas_provider.dart` - passar campos obrigatórios
4. ✅ Corrigir `faturas_list_page.dart` - passar ConfiguracaoEmpresa
5. ✅ Remover método não usado `_buildRodape` do PDF service
6. ✅ Validação com `flutter analyze` - 0 issues

### ✅ Fase 2: UI Completa (CONCLUÍDA)
1. ✅ **Expandir configurações com abas:**
   - Aba "Dados Básicos": Nome, IVA, Unidades, Estados, PIN
   - Aba "Dados Fiscais": NIF, Morada, Email, Telefone, CAE, Capital Social, Registo Comercial
   - Aba "Certificação AT": Chaves de certificação e validação
   - Aba "Documentos": Meios de pagamento, Tipos de documento, Série
2. ✅ **Expandir formulário de faturas:**
   - Dropdown para tipo de documento
   - Campo NIF do cliente com validação
   - Campo morada do cliente
   - Dropdown para meio de pagamento
   - Checkbox e slider para retenção na fonte (0-50%)
   - Dropdown para motivo de isenção de IVA (M01-M99)
   - Textarea para observações
3. ✅ **Validações implementadas:**
   - NIF com algoritmo de validação (9 dígitos + check digit)
   - Código postal formato XXXX-XXX
   - Campos obrigatórios com navegação automática para aba correta
   - Cálculo automático de retenção na fonte

### ✅ Fase 3: Funcionalidades Avançadas (CONCLUÍDA)
1. ✅ **QR Code real integrado no PDF:**
   - Adicionado `qr_flutter ^4.1.0` e `barcode ^2.2.8`
   - QR Code AT gerado com todos os campos obrigatórios
   - Widget QR Code renderizado diretamente no PDF (70x70)
   - Formato conforme especificações AT
2. ✅ **Contador sequencial robusto:**
   - Criado `ContadorDocumentosService` com Hive
   - Contadores por série e ano (ex: A_2024, B_2024)
   - Incremento atómico garantindo sequência sem lacunas
   - APIs: obter próximo, consultar último, definir manual, resetar
3. ✅ **Geração automática em `faturas_provider`:**
   - Número do documento: "SERIE ANO/NUMERO" (ex: A 2024/1)
   - Código ATCUD simulado: gerado automaticamente
   - Hash do documento anterior: cadeia de validação
   - Dados QR Code: gerados com todos os campos AT
4. ✅ **Validação e análise:**
   - `flutter pub get` executado com sucesso
   - `flutter analyze` - 0 issues encontrados

### 📋 Status Geral

**Fases 1, 2 e 3: 100% COMPLETAS** ✅

**Total de ficheiros modificados/criados:**
- 4 ficheiros modificados (configuracoes_page, fatura_form_page, faturas_provider, pdf_service)
- 1 ficheiro criado (contador_documentos_service)
- 1 ficheiro atualizado (pubspec.yaml)

**Novas funcionalidades:**
- Interface com 4 abas para configurações completas
- Formulário de fatura expandido com 7 novos campos
- Contador sequencial por série sem lacunas
- QR Code AT real renderizado no PDF
- Geração automática de ATCUD, hash e número de documento
- Validações legais (NIF, código postal, retenção)

### 🎯 Fase 4: Certificação (PRODUÇÃO)
**Status:** ⏳ PENDENTE (aguarda certificação oficial da AT)

Requisitos para produção:
1. Contactar AT para certificação do software
2. Substituir ATCUD simulado por integração com webservice AT oficial
3. Implementar comunicação de documentos à AT
4. Testes de homologação com AT
5. Obter certificado válido

**⚠️ IMPORTANTE:** Até obter certificação oficial, o software **NÃO DEVE** ser usado para emissão de faturas fiscais reais em Portugal.

---

## 📚 Referências Legais

- **Portaria n.º 363/2010** - Comunicação de elementos de faturas
- **Decreto-Lei n.º 28/2019** - Comunicação de documentos de transporte
- **Código do IVA (CIVA)** - Requisitos de faturação
- **Portal das Finanças** - Certificação de software
- **AT - Documentação Técnica** - Webservices e comunicação

---

## ⚖️ Disclaimer Legal

Este código é fornecido **APENAS PARA FINS EDUCATIVOS E DE DESENVOLVIMENTO**.

O autor/desenvolvedor **NÃO SE RESPONSABILIZA** por:
- Uso do software sem certificação AT
- Incumprimento de obrigações fiscais
- Coimas ou penalizações aplicadas pela AT
- Perda de dados ou problemas operacionais

**É RESPONSABILIDADE DO UTILIZADOR/EMPRESA**:
- Certificar o software antes de uso em produção
- Cumprir toda a legislação fiscal portuguesa
- Manter registos conforme a lei
- Consultar um contabilista certificado

---

**Data de Implementação**: 9 de março de 2026  
**Autor**: Sistema Facturio  
**Versão**: 2.0.0 (com funcionalidades legais)
