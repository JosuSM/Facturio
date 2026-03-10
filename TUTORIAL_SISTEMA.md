# Tutorial Interativo - Guia de Uso

## 🎓 Sistema de Tutorial Implementado

O Facturio agora possui um sistema completo de tutorial/onboarding responsivo que é exibido na primeira vez que o utilizador abre a aplicação.

## ✨ Funcionalidades

### 1. Tutorial Automático na Primeira Execução
- O tutorial é exibido automaticamente quando o usuário abre o app pela primeira vez
- Após visualizar ou pular, não aparece mais automaticamente
- Pode ser reiniciado manualmente nas Configurações

### 2. Interface Responsiva e Moderna
- **8 slides informativos** sobre as principais funcionalidades
- **Ícones grandes e coloridos** para cada funcionalidade
- **Animações suaves** entre os slides
- **Indicadores de progresso** (bolinhas na parte inferior)
- **Design adaptativo** funciona em todos os tamanhos de tela

### 3. Navegação Intuitiva
- **Botão "Pular"** no canto superior direito (visível em todos os slides exceto o último)
- **Botão "Voltar"** para retroceder entre slides
- **Botão "Próximo"** para avançar
- **Botão "Começar"** no último slide para iniciar o uso da aplicação
- **Swipe horizontal** para navegar entre slides (toque e arraste)

### 4. Conteúdo dos Slides

#### Slide 1: Bem-vindo ao Facturio
- Introdução geral ao sistema
- Principais vantagens: offline, interface moderna, relatórios em tempo real

#### Slide 2: Gestão de Clientes
- Cadastro completo com NIF e morada
- Histórico de faturas por cliente
- Pesquisa rápida

#### Slide 3: Catálogo de Produtos
- Gestão de stock com alertas
- Múltiplas taxas de IVA
- Preços personalizáveis

#### Slide 4: Faturação Profissional
- Faturas com conformidade legal portuguesa
- QR Code automático (AT)
- Cálculo de IVA e retenção na fonte

#### Slide 5: Sistema de Pagamentos
- Múltiplos pagamentos parciais
- 10 meios de pagamento
- Status visual com progresso

#### Slide 6: Impressão e Partilha
- PDF de alta qualidade
- Partilha por email/WhatsApp
- Exportação para Excel

#### Slide 7: Dashboard Inteligente
- Total faturado e recebido
- Faturas pendentes
- Alertas de stock baixo

#### Slide 8: Configurações Personalizadas
- Dados da empresa editáveis
- Taxas personalizadas
- Backup e restauro

## 🛠️ Gestão do Tutorial nas Configurações

Foi adicionada uma nova seção **"Ajuda e Tutorial"** na aba **"Dados Básicos"** das Configurações:

### Localização
1. Abrir o menu lateral
2. Ir para **Configurações da Empresa**
3. Aba **"Dados Básicos"** (primeira aba)
4. Rolar até a seção **"Ajuda e Tutorial"**

### Funcionalidades
- **Indicador de status**: Mostra se o tutorial já foi visualizado
- **Botão "Ver Tutorial"**: Reseta e abre o tutorial novamente
- **Design destacado**: Card azul claro para fácil localização

## 📱 Como Funciona (Técnico)

### Serviço de Tutorial (`TutorialService`)
```dart
// Verificar se deve mostrar o tutorial
TutorialService.shouldShowTutorial() // true na primeira vez

// Marcar como completado
await TutorialService.completeTutorial()

// Marcar como pulado
await TutorialService.skipTutorial()

// Resetar (para ver novamente)
await TutorialService.resetTutorial()
```

### Fluxo de Navegação
1. **Splash Screen** (2.5 segundos)
   - Verifica se é a primeira vez
   - Se sim: redireciona para `/tutorial`
   - Se não: redireciona para `/dashboard`

2. **Tutorial Page** (`/tutorial`)
   - Apresenta os 8 slides
   - Permite pular ou avançar
   - Ao completar: marca como visto e vai para dashboard

3. **Configurações**
   - Permite resetar e ver novamente

### Armazenamento
- Utiliza **Hive** (mesmo sistema do resto da app)
- Box: `tutorial_prefs`
- Chaves:
  - `tutorial_completed`: boolean
  - `tutorial_skipped`: boolean

## 🎨 Personalização

### Adicionar Novos Slides
Editar arquivo: `lib/features/tutorial/data/tutorial_slides.dart`

```dart
TutorialSlide(
  title: 'Novo Recurso',
  description: 'Descrição do recurso',
  icon: Icons.novo_icone,
  color: Colors.blue,
  features: [
    'Funcionalidade 1',
    'Funcionalidade 2',
  ],
),
```

### Cores dos Slides
Cada slide tem sua própria cor temática:
- Azul: Boas-vindas
- Verde: Clientes
- Laranja: Produtos
- Roxo: Faturação
- Teal: Pagamentos
- Índigo: Impressão
- Rosa: Dashboard
- Âmbar: Configurações

## 🧪 Testes

### Testar Tutorial pela Primeira Vez
1. **Limpar dados do app** (para simular primeira execução)
2. **Abrir o Facturio**
3. **Verificar** que o tutorial aparece automaticamente após o splash

### Testar Navegação
1. **Clicar em "Próximo"** várias vezes
2. **Clicar em "Voltar"**
3. **Fazer swipe** para a esquerda/direita
4. **Clicar em "Pular"** em qualquer slide
5. **Verificar** que o app vai para o dashboard

### Testar Reset do Tutorial
1. **Ir para Configurações** → Dados Básicos
2. **Encontrar** seção "Ajuda e Tutorial"
3. **Clicar** em "Ver Tutorial"
4. **Verificar** que o tutorial abre novamente

### Testar Responsividade
1. **Testar em diferentes tamanhos** de janela (desktop)
2. **Testar em diferentes dispositivos** (mobile, tablet)
3. **Verificar** que os elementos se ajustam corretamente

## 📊 Estrutura de Arquivos

```
lib/
├── core/
│   └── services/
│       └── tutorial_service.dart         # Serviço de gestão do tutorial
├── features/
│   ├── tutorial/
│   │   ├── data/
│   │   │   └── tutorial_slides.dart      # Conteúdo dos slides
│   │   └── presentation/
│   │       └── pages/
│   │           └── tutorial_page.dart    # Página principal do tutorial
│   ├── configuracoes/
│   │   └── presentation/
│   │       └── pages/
│   │           └── configuracoes_page.dart # Melhorada com seção de tutorial
│   └── splash/
│       └── presentation/
│           └── pages/
│               └── splash_page.dart      # Modificada para verificar tutorial
└── app/
    └── routes.dart                       # Adicionada rota /tutorial
```

## 🚀 Melhorias Futuras Possíveis

- [ ] Tutorial contextual (tooltips nas páginas)
- [ ] Vídeo de apresentação no primeiro slide
- [ ] Quiz no final do tutorial
- [ ] Tutorial específico por seção (ex: tutorial só de pagamentos)
- [ ] Badge "Novo" para features recém-lançadas
- [ ] Analytics de quantos usuários completam o tutorial
- [ ] Tradução para outros idiomas
- [ ] Tutorial em formato de tour guiado (spotlight)

## 💡 Dicas de Uso

### Para Usuários
- **Primeira vez?** Assista ao tutorial completo para conhecer todas as funcionalidades
- **Já conhece?** Pule o tutorial e vá direto para o dashboard
- **Esqueceu algo?** Volte às configurações e veja o tutorial novamente
- **Dúvida específica?** Use o tutorial como referência rápida das funcionalidades

### Para Desenvolvedores
- O tutorial é completamente opcional e não bloqueia o acesso ao app
- Os dados são persistidos localmente com Hive
- Fácil adicionar/remover slides editando um único arquivo
- O layout é 100% responsivo usando MediaQuery e LayoutBuilder

## ✅ Checklist de Implementação

- [x] Criar serviço de tutorial com Hive
- [x] Criar modelo de dados para slides
- [x] Criar página de tutorial com 8 slides
- [x] Adicionar navegação (Pular, Voltar, Próximo)
- [x] Adicionar indicadores de progresso
- [x] Integrar com splash screen
- [x] Adicionar rota no GoRouter
- [x] Inicializar serviço no main.dart
- [x] Adicionar seção nas configurações
- [x] Testar fluxo completo
- [x] Criar documentação

## 🎯 Objetivo Alcançado

✅ Tutorial interativo e responsivo implementado com sucesso!
✅ Melhorias nas configurações da empresa realizadas!
✅ Sistema totalmente integrado e funcional!
