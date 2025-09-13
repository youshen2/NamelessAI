import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class AuthenticationService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  static Future<bool> authenticate(AppLocalizations localizations) async {
    try {
      if (!await canAuthenticate()) {
        return false;
      }
      return await _auth.authenticate(
        localizedReason: localizations.authenticateToContinue,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
