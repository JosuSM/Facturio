import 'package:flutter/material.dart';

class AppText {
  static bool isEnglish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en';
  }

  static String tr(
    BuildContext context, {
    required String pt,
    required String en,
  }) {
    return isEnglish(context) ? en : pt;
  }
}
