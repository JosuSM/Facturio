import 'package:flutter/material.dart';

/// Helpers para componentes de UI com a identidade visual da app
class UiHelpers {
  /// Mostra um SnackBar com estilo consistente
  static void mostrarSnackBar(
    BuildContext context, {
    required String mensagem,
    TipoSnackBar tipo = TipoSnackBar.info,
    Duration duracao = const Duration(seconds: 3),
  }) {
    final colors = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (tipo) {
      case TipoSnackBar.sucesso:
        backgroundColor = colors.primary;
        textColor = colors.onPrimary;
        icon = Icons.check_circle;
        break;
      case TipoSnackBar.erro:
        backgroundColor = colors.error;
        textColor = colors.onError;
        icon = Icons.error;
        break;
      case TipoSnackBar.aviso:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case TipoSnackBar.info:
        backgroundColor = colors.surfaceContainerHighest;
        textColor = colors.onSurface;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensagem,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duracao,
      ),
    );
  }

  /// Mostra um diálogo de confirmação com estilo moderno
  static Future<bool> mostrarDialogoConfirmacao(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String textoBotaoConfirmar = 'Confirmar',
    String textoBotaoCancelar = 'Cancelar',
    bool acaoDestruidora = false,
  }) async {
    final colors = Theme.of(context).colorScheme;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: acaoDestruidora
                  ? [colors.error, colors.error.withValues(alpha: 0.8)]
                  : [colors.primary, colors.secondary],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                acaoDestruidora ? Icons.warning_rounded : Icons.help_rounded,
                color: acaoDestruidora ? colors.onError : colors.onPrimary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: acaoDestruidora ? colors.onError : colors.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            mensagem,
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurface.withValues(alpha: 0.87),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurface.withValues(alpha: 0.6),
            ),
            child: Text(textoBotaoCancelar),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: acaoDestruidora ? colors.error : colors.primary,
              foregroundColor: acaoDestruidora ? colors.onError : colors.onPrimary,
            ),
            child: Text(textoBotaoConfirmar),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );

    return resultado ?? false;
  }

  /// Mostra um diálogo informativo simples
  static Future<void> mostrarDialogoInfo(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String textoBotao = 'OK',
  }) async {
    final colors = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.secondary],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: colors.onPrimary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            mensagem,
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurface.withValues(alpha: 0.87),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: Text(textoBotao),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }
}

enum TipoSnackBar {
  sucesso,
  erro,
  aviso,
  info,
}
