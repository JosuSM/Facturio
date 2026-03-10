# Facturio Flutter

Sistema completo de faturação empresarial desenvolvido em Flutter com arquitetura Clean Architecture.

## 🚀 Funcionalidades

### ✅ Implementadas
- **CRUD Clientes** - Gestão completa de clientes (criar, editar, eliminar, pesquisar)
- **CRUD Produtos** - Gestão de produtos com controlo de stock e IVA
- **CRUD Faturas** - Criação e gestão de faturas
- **Dashboard** - Visão geral com estatísticas e alertas
- **Geração de PDF** - Criação e partilha de faturas em PDF
- **Persistência Local** - Dados guardados localmente com Hive
- **Pesquisa** - Pesquisa inteligente em clientes e produtos
- **Validação** - Formulários com validação completa
- **Tema** - Design Material 3 com suporte para modo escuro
- **Backup/Restore** - Exportar e restaurar todos os dados em JSON
- **Configurações da Empresa** - Base de dados editável sem alterar código (IVA, unidades, estados de fatura)
- **Autenticação por PIN** - Acesso protegido às configurações da empresa (admin)
- **Exportação Multi-plataforma** - Geração automática de pacotes (APK, AAB, Web, Linux)
- **Integração VS Code** - Task para exportar pacotes com um clique

## 📁 Arquitetura

```
lib/
├── app/                      # Configuração da aplicação
│   ├── app.dart              # Widget principal
│   ├── routes.dart           # Navegação (go_router)
│   └── theme.dart            # Tema Material 3
├── core/                     # Funcionalidades centrais
│   ├── constants/            # Constantes (IVA, estados, etc)
│   ├── services/             
│   │   ├── storage_service.dart  # Persistência com Hive
│   │   └── pdf_service.dart      # Geração de PDFs
├── features/                 # Features (Clean Architecture)
│   ├── clientes/
│   │   ├── data/             # Models e Repositories
│   │   ├── domain/           # Entities
│   │   └── presentation/     # Pages, Widgets e Providers
│   ├── produtos/
│   ├── faturas/
│   └── dashboard/
├── shared/                   # Código compartilhado
│   └── models/               # LinhaFatura, etc
└── main.dart                 # Entry point
```

## 🛠️ Tecnologias

- **Flutter** 3.27.x
- **Riverpod** 2.6.1 - Gestão de estado
- **Hive** 2.2.3 - Persistência local NoSQL
- **go_router** 14.8.1 - Navegação declarativa
- **pdf** 3.11.3 - Geração de PDFs
- **printing** 5.14.2 - Preview e impressão
- **intl** - Formatação de datas e moeda
- **uuid** - Geração de IDs únicos
- **crypto** 3.0.6 - Hashing de PIN (SHA-256)
- **file_picker** 8.1.2 - Seleção de ficheiros de backup
- **share_plus** 10.0.2 - Partilha e exportação de ficheiros

## 📦 Instalação

### Pré-requisitos
- Flutter SDK 3.27.x ou superior
- Dart 3.11.x ou superior

### Passos

1. **Instalar dependências**
```bash
flutter pub get
```

2. **Executar a aplicação**
```bash
# Desktop (Linux)
flutter run -d linux

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 🎯 Uso

### Dashboard
- Visão geral com estatísticas
- Alertas de stock baixo
- Últimas faturas registadas

### Clientes
- Adicionar novo cliente (Nome, NIF, Email, Telefone, Morada)
- Editar clientes existentes
- Eliminar clientes
- Pesquisar por nome, NIF ou email

### Produtos
- Adicionar produtos com preço, IVA e stock
- Diferentes taxas de IVA (23%, 13%, 6%, 0%)
- Várias unidades (un, kg, m, l, etc)
- Alerta visual para stock baixo (<10)

### Faturas
- Criar fatura selecionando cliente e produtos
- Estados: rascunho, emitida, paga, cancelada
- Cálculo automático de subtotais e IVA
- Geração e partilha de PDF
- Numeração automática (Ano/Número)

### Backup e Restore
- **Criar Backup**: Exportar todos os dados (clientes, produtos, faturas, configurações) em ficheiro JSON
- **Restaurar**: Importar e restaurar dados de um ficheiro de backup anterior
- Acessível a partir do menu do Dashboard
- Ficheiros guardados com timestamp (backup_YYYY-MM-DD_HH-MM-SS.json)

### Configurações da Empresa
- **Acesso Protegido**: Requer PIN do administrador (padrão: 1234)
- **Taxas de IVA**: Adicionar/remover taxas personalizadas
- **Unidades de Medida**: Personalizar unidades (un, kg, m, l, etc)
- **Estados de Fatura**: Adicionar/remover estados customizados
- **Alterar PIN**: Mudar o PIN de acesso às configurações
- Todos os dados guardados em base de dados Hive (persistência local)

## 📱 Compatibilidade

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Desktop** (Windows, macOS, Linux)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

## 📦 Exportação de Pacotes

### Método 1: Script Bash
```bash
./export_packages.sh
```

O script gera automaticamente:
- **Android**: APK e AAB (release)
- **Web**: Build web completo
- **Linux**: Binary e assets
- **iOS/macOS/Windows**: Ficheiros de configuração

Resultado: `dist/YYYYMMDD_HHMMSS/`

### Método 2: VS Code Task
```
Terminal → Run Task → Facturio: Exportar pacotes
```

Mesmos resultados que o script, executável directo do editor.

## 🔧 Próximos Passos

### Fase 2 - Melhorias
- [ ] Filtros avançados (por data, estado, valor)
- [ ] Gráficos de vendas
- [ ] Exportação de dados (CSV, Excel)
- [ ] Impressão direta
- [ ] Customização do layout de PDF

### Fase 3 - Avançado
- [ ] Multi-empresa
- [ ] Sincronização cloud
- [ ] Autenticação de utilizadores (multi-user)
- [ ] Relatórios avançados
- [ ] Envio de faturas por email

## 📝 Notas

1. **Persistência Local**: Os dados são guardados localmente no dispositivo usando Hive.

2. **Segurança do PIN**: O PIN é armazenado com hash SHA-256. PIN padrão: 1234

3. **Backup Automático**: Considere fazer backups regulares através do Dashboard.

4. **PDF Customização**: Edite `pdf_service.dart` para personalizar o layout.

5. **Taxas de IVA**: Configuradas por defeito para Portugal (23%, 13%, 6%, 0%), mas podem ser customizadas na aplicação.

6. **Exportação Multi-plataforma**: Requer:
   - Android SDK (para APK/AAB)
   - Flutter SDK
   - Node.js (opcional, para web)
   - Linux build tools (para Linux executable)

---

**Desenvolvido com Flutter** 💙
