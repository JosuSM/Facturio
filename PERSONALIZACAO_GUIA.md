# Sistema de Personalização do Facturio 🎨

## Funcionalidades Implementadas

### ✨ Personalização Completa

A nova seção de **Personalização** permite customizar completamente a aparência da aplicação:

---

## 🌓 Modo de Exibição

Escolha entre três modos de visualização:

- **☀️ Modo Claro** - Interface clara e brilhante
- **🌙 Modo Escuro** - Interface escura para ambientes com pouca luz
- **🔄 Sistema** - Segue automaticamente o tema do sistema operativo

---

## 🎨 Temas Predefinidos

10 temas profissionais prontos para uso:

1. **Azul Profissional** 💼 - Tema padrão azul elegante
2. **Verde Natureza** 🌿 - Tons de verde suaves e relaxantes
3. **Roxo Criativo** 🎨 - Roxo vibrante e moderno
4. **Laranja Energia** ⚡ - Laranja energético e dinâmico
5. **Teal Moderno** 🌊 - Teal contemporâneo e sofisticado
6. **Rosa Elegante** 💕 - Rosa suave e elegante
7. **Índigo Tecnológico** 💻 - Índigo tech e inovador
8. **Âmbar Quente** ☀️ - Âmbar acolhedor e caloroso
9. **Ciano Fresco** 💧 - Ciano fresco e limpo
10. **Vermelho Intenso** 🔥 - Vermelho intenso e impactante

### Como usar:
- Navegue horizontalmente pelos cards dos temas
- Clique no tema desejado
- A mudança é aplicada instantaneamente em toda a aplicação

---

## 🎨 Cores Personalizadas

Crie seu próprio tema exclusivo:

### Opções disponíveis:
- **Cor Primária** - Define a cor principal da aplicação
- **Cor Secundária** - Define a cor de destaque/acento

### Como personalizar:
1. Clique no círculo de cor (Primária ou Secundária)
2. Selecione a cor desejada no seletor avançado
3. Confirme e veja a mudança em tempo real
4. O tema personalizado substitui automaticamente os temas predefinidos

### Indicador:
Quando um tema personalizado está ativo, aparece um badge verde com ✅ "Tema personalizado ativo"

---

## 📱 Ícone da Aplicação

Personalize o visual do ícone entre 6 opções:

1. **Padrão** 📄 - Ícone oficial do Facturio (azul)
2. **Calculadora** 🧮 - Ícone com calculadora (verde)
3. **Dinheiro** 💰 - Ícone com cifrão (laranja)
4. **Documentos** 📋 - Ícone com documentos (roxo)
5. **Gráfico** 📈 - Ícone com gráfico (ciano)
6. **Negócios** 💼 - Ícone corporativo (índigo)

*Nota: Esta opção altera a representação visual do ícone no UI, não o ícone nativo do sistema operativo.*

---

## 📏 Tamanho do Texto

Ajuste o tamanho do texto para melhor legibilidade:

### Escala disponível:
- **80%** - Texto menor (para telas pequenas)
- **90%** - Texto um pouco menor
- **100%** - Tamanho padrão ✅
- **110%** - Texto um pouco maior
- **120%** - Texto maior
- **130%** - Texto muito maior
- **140%** - Texto extra grande (máxima legibilidade)

### Como ajustar:
- Use o slider para selecionar o tamanho desejado
- Veja a prévia em tempo real abaixo do slider
- A escala é aplicada em toda a aplicação

---

## ⚙️ Opções Avançadas

### 🤖 Material You (Experimental)
- **Disponível**: Android 12+ 
- **Descrição**: Tema dinâmico que se adapta automaticamente às cores do papel de parede do sistema
- **Status**: Experimental (pode não funcionar em todas as versões)

*Quando ativado, o Material You sobrescreve as cores personalizadas e usa as cores do sistema.*

---

## 🔄 Resetar Personalização

### Botão de reset (ícone 🔄 no canto superior direito):
- Reseta **todas** as configurações de personalização
- Retorna aos valores padrão:
  - Tema: Azul Profissional
  - Modo: Sistema
  - Ícone: Padrão
  - Tamanho de texto: 100%
  - Material You: Desativado

---

## 🚀 Como Aceder

### Opção 1: Via Dashboard (Menu Lateral)
1. Abrir menu lateral (☰)
2. Clicar em **"Personalização"**
3. Subtítulo: "Tema, cores e aparência"

### Opção 2: Via Configurações
1. Abrir **"Configurações da Empresa"**
2. Aba **"Dados Básicos"**
3. Seção **"Personalização"** (card roxo)
4. Clicar em **"Personalizar"**

---

## 💾 Armazenamento e Persistência

### Tecnologia:
- Todas as preferências são salvas localmente usando **Hive**
- Box: `theme_prefs`
- As configurações persistem entre sessões
- Sincronização automática em tempo real

### Dados armazenados:
```
- theme_mode: Modo de tema (0=light, 1=dark, 2=system)
- primary_color: Valor int da cor primária (se personalizada)
- accent_color: Valor int da cor secundária (se personalizada)
- use_predefined_theme: Boolean (true=predefinido, false=personalizado)
- predefined_theme_index: Índice do tema predefinido (0-9)
- app_icon: Índice do ícone selecionado (0-5)
- use_material_you: Boolean (experimental)
- font_size: Double (0.8 a 1.4)
```

---

## 🏗️ Arquitetura Técnica

### Arquivos criados:

#### 1. Serviço
- `lib/core/services/theme_service.dart`
  - Gestão de preferências com Hive
  - Métodos getter/setter para cada configuração
  - Método reset para valores padrão

#### 2. Modelos
- `lib/core/models/app_theme.dart`
  - **AppTheme**: Modelo de tema com cores e ícone
  - **PredefinedThemes**: Lista de 10 temas predefinidos
  - **AppIcon**: Modelo de ícone da app
  - **PredefinedIcons**: Lista de 6 ícones disponíveis

#### 3. Provider
- `lib/core/providers/theme_provider.dart`
  - **ThemeNotifier**: ChangeNotifier para estado do tema
  - Métodos: setThemeMode, setPredefinedTheme, setCustomColors, etc.
  - Gera ThemeData dinâmico para light e dark mode
  - Aplica escala de fonte ao TextTheme

#### 4. UI
- `lib/features/personalizacao/presentation/pages/personalizacao_page.dart`
  - Interface completa de personalização
  - Seções: Modo, Temas, Cores, Ícone, Fonte, Avançado
  - Integração com flutter_colorpicker

### Integrações:

#### main.dart
```dart
await ThemeService.init(); // Inicializa serviço antes do runApp
```

#### app/app.dart
```dart
final themeNotifier = ref.watch(themeProvider);
return MaterialApp.router(
  theme: themeNotifier.getLightTheme(),
  darkTheme: themeNotifier.getDarkTheme(),
  themeMode: themeNotifier.themeMode,
  // ...
);
```

#### routes.dart
```dart
static const String personalizacao = '/personalizacao';
GoRoute(
  path: personalizacao,
  builder: (context, state) => const PersonalizacaoPage(),
),
```

---

## 🧪 Como Testar

### Teste 1: Trocar tema predefinido
1. Ir para Personalização
2. Navegar pelos temas horizontalmente
3. Clicar em **"Verde Natureza"**
4. ✅ Verificar que todas as cores mudaram imediatamente

### Teste 2: Criar tema personalizado
1. Na seção **"Cores Personalizadas"**
2. Clicar no círculo da **Cor Primária**
3. Escolher uma cor (ex: vermelho #FF0000)
4. Clicar **"Selecionar"**
5. ✅ Verificar que o tema mudou e aparece "Tema personalizado ativo"

### Teste 3: Modo escuro/claro
1. Alternar entre **Claro**, **Escuro** e **Sistema**
2. ✅ Verificar que a interface muda de acordo

### Teste 4: Tamanho de texto
1. Mover o slider para **120%**
2. ✅ Verificar que todos os textos ficaram maiores

### Teste 5: Persistência
1. Fazer alguma personalização
2. Fechar a aplicação completamente
3. Reabrir
4. ✅ Verificar que as configurações foram mantidas

### Teste 6: Reset
1. Fazer várias personalizações
2. Clicar no botão de reset (🔄)
3. Confirmar
4. ✅ Verificar que voltou ao tema azul padrão

---

## 📱 Capturas de Ecrã Esperadas

### Tela de Personalização:
```
┌─────────────────────────────────┐
│ Personalização            🔄    │
├─────────────────────────────────┤
│                                 │
│ 🌓 Modo de Exibição            │
│ ┌─────┬─────┬─────┐            │
│ │Claro│Escuro│Sistema│          │
│ └─────┴─────┴─────┘            │
│                                 │
│ 🎨 Temas Predefinidos           │
│ ┌───┐ ┌───┐ ┌───┐             │
│ │ 💼│ │ 🌿│ │ 🎨│ ➡️          │
│ └───┘ └───┘ └───┘             │
│                                 │
│ 🎨 Cores Personalizadas         │
│ ┌─────┐  ┌─────┐               │
│ │  🔵  │  │  🟣  │              │
│ │Prim. │  │Secun.│              │
│ └─────┘  └─────┘               │
│                                 │
│ 📱 Ícone da Aplicação           │
│ ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐      │
│ │📄││🧮││💰││📋││📈││💼│      │
│ └──┘└──┘└──┘└──┘└──┘└──┘      │
│                                 │
│ 📏 Tamanho do Texto             │
│ │─────────●────────│ 100%      │
│                                 │
│ ⚙️ Opções Avançadas             │
│ 🤖 Material You      [ OFF ]    │
│                                 │
└─────────────────────────────────┘
```

---

## ✅ Checklist de Funcionalidades

- [x] Modo claro/escuro/sistema
- [x] 10 temas predefinidos
- [x] Cores personalizadas (primária + secundária)
- [x] Seletor de cores avançado (flutter_colorpicker)
- [x] 6 ícones diferentes
- [x] Ajuste de tamanho de texto (80%-140%)
- [x] Material You (experimental)
- [x] Persistência com Hive
- [x] Reset para padrão
- [x] Aplicação em tempo real
- [x] Acessível via Dashboard e Configurações
- [x] Interface responsiva
- [x] Preview em tempo real
- [x] Indicador de tema personalizado ativo

---

## 🎯 Próximas Melhorias Possíveis

- [ ] Mais temas predefinidos (gradientes, temas de negócio)
- [ ] Preview antes de aplicar
- [ ] Exportar/importar temas personalizados
- [ ] Galeria de temas da comunidade
- [ ] Tema por agendamento (ex: escuro à noite automaticamente)
- [ ] Customização de bordas (arredondadas vs quadradas)
- [ ] Customização de espaçamentos
- [ ] Efeitos de animação personalizáveis
- [ ] Fonte personalizada (além do tamanho)
- [ ] Mudança real do ícone nativo da app (requer rebuild)

---

## 🐛 Troubleshooting

### Tema não está mudando
- Verificar se o ThemeService foi inicializado no main.dart
- Verificar se o themeProvider está sendo usado no app.dart
- Limpar cache: `flutter clean && flutter pub get`

### Cores não persistem
- Verificar se Hive foi inicializado
- Verificar permissões de escrita no dispositivo
- Consultar logs: `flutter run --verbose`

### Material You não funciona
- Requer Android 12+ (API 31+)
- Pode não funcionar em todos os dispositivos
- Verificar se as permissões de tema dinâmico estão concedidas

---

## 📚 Dependências Adicionadas

```yaml
dependencies:
  flutter_colorpicker: ^1.1.0  # Seletor de cores avançado
```

---

## 🎉 Conclusão

O sistema de personalização está **100% funcional** e pronto para uso! 

Agora os usuários podem:
- ✅ Escolher entre 10 temas profissionais
- ✅ Criar temas totalmente personalizados
- ✅ Alternar entre modo claro e escuro
- ✅ Ajustar tamanho de texto para acessibilidade
- ✅ Mudar o visual do ícone
- ✅ Ter todas as preferências salvas automaticamente

**Tudo isto com uma interface bonita, intuitiva e responsiva!** 🚀
