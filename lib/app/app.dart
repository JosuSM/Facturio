import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/theme_provider.dart';
import 'routes.dart';

class FaturacaoApp extends ConsumerWidget {
  const FaturacaoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Facturio',
      theme: themeNotifier.getLightTheme(),
      darkTheme: themeNotifier.getDarkTheme(),
      themeMode: themeNotifier.themeMode,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
