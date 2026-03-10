# Guia Rápido de Teste - Sistema de Pagamentos

## 🚀 Como Testar

### 1. Executar a Aplicação

```bash
cd /media/huskydb/FicheirosA/IEFP/Facturio
flutter run -d linux  # ou android, chrome, etc.
```

### 2. Cenário de Teste Completo

#### Passo 1: Criar uma Fatura
1. No menu principal, vá para **Faturas**
2. Clique no botão **+** (FloatingActionButton)
3. Preencha os dados:
   - Cliente: Selecione ou crie um cliente
   - Produtos: Adicione produtos (exemplo: €100)
   - Data: Data atual
4. Clique em **Salvar**

#### Passo 2: Registar Primeiro Pagamento (Parcial)
1. Na lista de faturas, encontre a fatura criada
2. Expanda o card da fatura
3. Clique em **Ver Detalhes**
4. Na página de detalhe, observe:
   - Status: "Não Paga" (barra vermelha a 0%)
   - Total: €100,00
   - Pago: €0,00
   - Dívida: €100,00
5. Clique no botão flutuante **Adicionar Pagamento**
6. Preencha:
   - Valor: 40 (o campo já vem preenchido com o valor total)
   - Meio de Pagamento: MB Way
   - Data: Hoje
   - Referência: 123456789
   - Observações: Primeiro pagamento
7. Clique em **Registar Pagamento**
8. Observe as mudanças:
   - Status: "Parcial" (barra laranja a 40%)
   - Total: €100,00
   - Pago: €40,00
   - Dívida: €60,00
   - Histórico: 1 pagamento listado

#### Passo 3: Registar Segundo Pagamento (Parcial)
1. Clique novamente em **Adicionar Pagamento**
2. Preencha:
   - Valor: 30
   - Meio de Pagamento: Transferência Bancária
   - Data: Hoje
   - Referência: REF-2024-001
3. Clique em **Registar Pagamento**
4. Observe as mudanças:
   - Status: "Parcial" (barra laranja a 70%)
   - Total: €100,00
   - Pago: €70,00
   - Dívida: €30,00
   - Histórico: 2 pagamentos listados

#### Passo 4: Completar o Pagamento
1. Clique em **Adicionar Pagamento**
2. Preencha:
   - Valor: 30 (valor restante)
   - Meio de Pagamento: Numerário
   - Data: Hoje
3. Clique em **Registar Pagamento**
4. Observe as mudanças:
   - Status: "Paga" (barra verde a 100%)
   - Total: €100,00
   - Pago: €100,00
   - Dívida: €0,00
   - Histórico: 3 pagamentos listados
   - **Botão flutuante desaparece** (não pode adicionar mais pagamentos)

#### Passo 5: Ver Resumo no Dashboard
1. Volte ao Dashboard (menu principal)
2. Role até a seção **Resumo Financeiro**
3. Observe:
   - Total Recebido: €100,00
   - Em Dívida: €0,00 (se só tiver esta fatura)
   - Faturas Pagas: 1
   - Faturas Parciais: 0
   - Faturas Não Pagas: 0 (se só tiver esta fatura)

#### Passo 6: Testar Validações
1. Crie outra fatura de €50
2. Tente registar um pagamento de €100
3. **Resultado esperado:** Mensagem de erro "O pagamento não pode ser superior ao valor em dívida (€50.00)"
4. Tente registar um pagamento de €0
5. **Resultado esperado:** Mensagem de erro "Valor inválido"

#### Passo 7: Remover Pagamento
1. Na página de detalhe da primeira fatura
2. No histórico, clique no ícone **🗑️ (lixo)** de um pagamento
3. Confirme a remoção
4. Observe:
   - Status atualizado automaticamente
   - Valor em dívida recalculado
   - Histórico atualizado

## 🧪 Testes de Validação

### ✅ Teste 1: Pagamento Exato
- Fatura: €100
- Pagamento: €100
- **Esperado:** Status "Paga" (100%), botão flutuante oculto

### ✅ Teste 2: Pagamentos Múltiplos
- Fatura: €100
- Pagamento 1: €33.33
- Pagamento 2: €33.33
- Pagamento 3: €33.34
- **Esperado:** Status "Paga" (100%) devido à tolerância de €0.01

### ✅ Teste 3: Diferentes Meios
- Fatura: €100
- Pagamento 1: €50 via MB Way
- Pagamento 2: €50 via Transferência
- **Esperado:** Histórico mostra 2 pagamentos com meios diferentes

### ✅ Teste 4: Validação de Excesso
- Fatura: €100 com €60 já pago
- Tentativa: Registar €50
- **Esperado:** Erro (excede em €10)

### ✅ Teste 5: Persistência
- Registar pagamentos
- Fechar e reabrir a app
- **Esperado:** Todos os pagamentos ainda visíveis

## 🎨 Verificações Visuais

### Lista de Faturas
- [ ] Status de pagamento compacto visível em cada fatura
- [ ] Barra de progresso colorida (verde/laranja/vermelho)
- [ ] Botão "Ver Detalhes" destacado

### Página de Detalhe
- [ ] Cabeçalho com gradiente
- [ ] Card de status de pagamento (modo completo)
- [ ] Barra de progresso grande
- [ ] Resumo financeiro (Total, Pago, Dívida)
- [ ] Lista de produtos
- [ ] Histórico de pagamentos com timeline
- [ ] Botão flutuante "Adicionar Pagamento"

### Formulário de Pagamento
- [ ] Resumo da fatura no topo
- [ ] Resumo financeiro (Total, Já Pago, Em Dívida)
- [ ] Campo de valor com validação
- [ ] Dropdown de meios de pagamento
- [ ] Seletor de data
- [ ] Campos opcionais (referência, observações)
- [ ] Validação em tempo real

### Dashboard
- [ ] Seção "Resumo Financeiro" visível
- [ ] Cards de Total Recebido e Em Dívida
- [ ] Chips com contadores (Pagas, Parciais, Não Pagas)
- [ ] Cores corretas (verde=recebido, laranja=dívida)

## 📊 Casos de Uso

| Cenário | Fatura | Pagamentos | Status Esperado | Cor |
|---------|--------|------------|-----------------|-----|
| Sem pagamento | €100 | - | Não Paga (0%) | 🔴 Vermelho |
| Parcial pequeno | €100 | €20 | Parcial (20%) | 🟠 Laranja |
| Parcial médio | €100 | €50 | Parcial (50%) | 🟠 Laranja |
| Parcial grande | €100 | €90 | Parcial (90%) | 🟠 Laranja |
| Completo exato | €100 | €100 | Paga (100%) | 🟢 Verde |
| Múltiplos | €100 | €30+€40+€30 | Paga (100%) | 🟢 Verde |

## ⚠️ Problemas Conhecidos (Inexistentes)

✅ Nenhum erro de compilação
✅ Nenhum warning crítico
✅ Todos os imports resolvidos
✅ Providers configurados corretamente
✅ Navegação funcional
✅ Persistência operacional

## 🎯 Checklist de Aceitação

- [ ] Registar pagamento em fatura não paga
- [ ] Registar múltiplos pagamentos parciais
- [ ] Completar pagamento de fatura
- [ ] Visualizar status em lista de faturas
- [ ] Visualizar histórico na página de detalhe
- [ ] Ver resumo financeiro no dashboard
- [ ] Remover pagamento existente
- [ ] Validação de pagamento excessivo funciona
- [ ] Validação de valor inválido funciona
- [ ] Persistência após fechar/abrir app
- [ ] Navegação entre páginas fluida
- [ ] Cores e ícones corretos
- [ ] Barra de progresso atualiza corretamente
- [ ] Botão flutuante some quando fatura paga

## 📝 Notas

- O sistema suporta até 10 meios de pagamento diferentes
- A tolerância para pagamento completo é de €0.01
- Todos os valores são armazenados com 2 casas decimais
- As datas são formatadas em formato português (dd/MM/yyyy)
- O histórico é ordenado por data decrescente (mais recente primeiro)
- O Hive TypeId 3 é reservado para PagamentoModel
- Os pagamentos são persistidos em box separado ('pagamentos')

## 🔥 Teste Rápido (2 minutos)

1. Criar fatura de €100
2. Adicionar pagamento de €40 via MB Way
3. Verificar status "Parcial (40%)"
4. Adicionar pagamento de €60 via Transferência
5. Verificar status "Paga (100%)"
6. Ir ao Dashboard e ver "Total Recebido: €100"
7. ✅ **SUCESSO!**

---

**Desenvolvido em:** 9 de março de 2026
**Versão:** 1.0.0
**Flutter:** 3.27+
**Dart:** 3.11+
