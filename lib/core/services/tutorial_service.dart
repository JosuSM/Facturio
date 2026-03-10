import 'package:hive_flutter/hive_flutter.dart';

/// Serviço para gerenciar o estado do tutorial/onboarding.
class TutorialService {
  static const String _boxName = 'tutorial_prefs';
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _tutorialSkippedKey = 'tutorial_skipped';
  static late Box<dynamic> _box;

  /// Inicializa o serviço de tutorial.
  static Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  /// Verifica se o tutorial já foi completado ou pulado.
  static bool isTutorialCompleted() {
    return _box.get(_tutorialCompletedKey, defaultValue: false) as bool;
  }

  /// Verifica se o tutorial foi pulado.
  static bool isTutorialSkipped() {
    return _box.get(_tutorialSkippedKey, defaultValue: false) as bool;
  }

  /// Marca o tutorial como completado.
  static Future<void> completeTutorial() async {
    await _box.put(_tutorialCompletedKey, true);
    await _box.put(_tutorialSkippedKey, false);
  }

  /// Marca o tutorial como pulado.
  static Future<void> skipTutorial() async {
    await _box.put(_tutorialSkippedKey, true);
    await _box.put(_tutorialCompletedKey, true);
  }

  /// Reseta o tutorial (útil para testes ou configurações).
  static Future<void> resetTutorial() async {
    await _box.put(_tutorialCompletedKey, false);
    await _box.put(_tutorialSkippedKey, false);
  }

  /// Verifica se deve mostrar o tutorial.
  static bool shouldShowTutorial() {
    return !isTutorialCompleted();
  }
}
