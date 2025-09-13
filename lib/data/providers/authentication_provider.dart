import 'package:flutter/material.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';

class AuthenticationProvider extends ChangeNotifier {
  AppConfigProvider _appConfigProvider;
  bool _isLocked = false;
  DateTime? _lastPausedTime;

  AuthenticationProvider(this._appConfigProvider) {
    if (_appConfigProvider.appLockEnabled) {
      _isLocked = true;
    }
  }

  bool get isLocked => _isLocked;

  void updateAppConfig(AppConfigProvider newConfig) {
    _appConfigProvider = newConfig;
  }

  void lockApp() {
    if (!_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void unlockApp() {
    if (_isLocked) {
      _isLocked = false;
      _lastPausedTime = null;
      notifyListeners();
    }
  }

  void handleAppLifecycleStateChange(AppLifecycleState state) {
    if (!_appConfigProvider.appLockEnabled) {
      if (_isLocked) {
        unlockApp();
      }
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isLocked) {
        _lastPausedTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null) {
        final timeout = _getTimeoutDuration(_appConfigProvider.appLockTimeout);
        final difference = DateTime.now().difference(_lastPausedTime!);
        if (difference > timeout) {
          lockApp();
        }
      }
      _lastPausedTime = null;
    }
  }

  Duration _getTimeoutDuration(AppLockTimeout timeout) {
    switch (timeout) {
      case AppLockTimeout.immediately:
        return Duration.zero;
      case AppLockTimeout.after1Minute:
        return const Duration(minutes: 1);
      case AppLockTimeout.after5Minutes:
        return const Duration(minutes: 5);
      case AppLockTimeout.after15Minutes:
        return const Duration(minutes: 15);
    }
  }
}
