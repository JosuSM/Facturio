import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../core/models/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Página de personalização visual da aplicação.
class PersonalizacaoPage extends ConsumerStatefulWidget {
  const PersonalizacaoPage({super.key});

  @override
  ConsumerState<PersonalizacaoPage> createState() => _PersonalizacaoPageState();
}

class _PersonalizacaoPageState extends ConsumerState<PersonalizacaoPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar para padrão',
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Modo de tema (claro/escuro)
          _buildThemeModeSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Temas predefinidos
          _buildPredefinedThemesSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Cores personalizadas
          _buildCustomColorsSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Ícone da app
          _buildAppIconSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Tamanho da fonte
          _buildFontSizeSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Opções avançadas
          _buildAdvancedSection(context, themeNotifier, colors),
        ],
      ),
    );
  }

  /// Seção de seleção de modo de tema.
  Widget _buildThemeModeSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Modo de Exibição',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Escuro'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.brightness_auto),
                ),
              ],
              selected: {themeNotifier.themeMode},
              onSelectionChanged: (Set<ThemeMode> selected) {
                themeNotifier.setThemeMode(selected.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de temas predefinidos.
  Widget _buildPredefinedThemesSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Temas Predefinidos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um dos nossos temas profissionais',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: PredefinedThemes.themes.length,
                itemBuilder: (context, index) {
                  final theme = PredefinedThemes.themes[index];
                  final isSelected = themeNotifier.usePredefinedTheme &&
                      themeNotifier.predefinedThemeIndex == index;

                  return GestureDetector(
                    onTap: () => themeNotifier.setPredefinedTheme(index),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withValues(alpha: 0.3),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.secondaryColor,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              theme.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              theme.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de cores personalizadas.
  Widget _buildCustomColorsSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.color_lens, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Cores Personalizadas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu próprio tema com cores exclusivas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildColorPicker(
                    context,
                    'Cor Primária',
                    themeNotifier.customPrimaryColor ?? colors.primary,
                    (color) {
                      final accent = themeNotifier.customAccentColor ?? color;
                      themeNotifier.setCustomColors(color, accent);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColorPicker(
                    context,
                    'Cor Secundária',
                    themeNotifier.customAccentColor ?? colors.secondary,
                    (color) {
                      final primary =
                          themeNotifier.customPrimaryColor ?? colors.primary;
                      themeNotifier.setCustomColors(primary, color);
                    },
                  ),
                ),
              ],
            ),
            if (!themeNotifier.usePredefinedTheme) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tema personalizado ativo',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construtor de seletor de cor.
  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    return InkWell(
      onTap: () => _showColorPickerDialog(
        context,
        label,
        currentColor,
        onColorSelected,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra diálogo de seleção de cor.
  void _showColorPickerDialog(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.pop(context);
            },
            child: const Text('Selecionar'),
          ),
        ],
      ),
    );
  }

  /// Seção de ícone da app.
  Widget _buildAppIconSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apps, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Ícone da Aplicação',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Personalize o visual do ícone',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                PredefinedIcons.icons.length,
                (index) {
                  final appIcon = PredefinedIcons.icons[index];
                  final isSelected = themeNotifier.appIconIndex == index;

                  return InkWell(
                    onTap: () => themeNotifier.setAppIcon(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withValues(alpha: 0.3),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: appIcon.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              appIcon.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              appIcon.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de tamanho de fonte.
  Widget _buildFontSizeSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Tamanho do Texto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajuste o tamanho para melhor legibilidade',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.text_decrease, color: colors.onSurfaceVariant),
                Expanded(
                  child: Slider(
                    value: themeNotifier.fontSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${(themeNotifier.fontSize * 100).toInt()}%',
                    onChanged: (value) => themeNotifier.setFontSize(value),
                  ),
                ),
                Icon(Icons.text_increase, color: colors.onSurfaceVariant),
              ],
            ),
            Center(
              child: Text(
                'Exemplo de texto com ${(themeNotifier.fontSize * 100).toInt()}% de tamanho',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de opções avançadas.
  Widget _buildAdvancedSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Opções Avançadas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Material You (Experimental)'),
              subtitle: const Text('Tema dinâmico do sistema (Android 12+)'),
              value: themeNotifier.useMaterialYou,
              onChanged: (value) => themeNotifier.setMaterialYou(value),
              secondary: const Icon(Icons.auto_awesome),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra diálogo de confirmação para reset.
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Personalização'),
        content: const Text(
          'Tem certeza que deseja resetar todas as configurações de personalização para os valores padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(themeProvider).resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: 'Personalização resetada com sucesso!',
                );
              }
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }
}
