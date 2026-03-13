import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      locale: themeNotifier.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'PT'),
        Locale('en', 'US'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('pt', 'PT');
        }

        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }

        return const Locale('pt', 'PT');
      },
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
