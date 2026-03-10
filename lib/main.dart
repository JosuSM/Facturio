import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/tutorial_service.dart';
import 'core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await StorageService.init();
  
  // Inicializar Tutorial Service
  await TutorialService.init();
  
  // Inicializar Theme Service
  await ThemeService.init();
  
  runApp(
    const ProviderScope(
      child: FaturacaoApp(),
    ),
  );
}
