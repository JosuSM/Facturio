import 'dart:convert';

import 'package:crypto/crypto.dart';

class AdminAuthService {
  static const String defaultPin = '1234';
  static final String defaultPinHash = hashPin(defaultPin);

  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static bool validarPin(String pin, String pinHash) {
    return hashPin(pin) == pinHash;
  }
}
