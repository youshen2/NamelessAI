import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';

enum SendKeyOption { enter, ctrlEnter, shiftCtrlEnter }

class AppConfigProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _enableMonet = true;
  SendKeyOption _sendKeyOption = SendKeyOption.ctrlEnter;
  bool _useSendKeyInEditMode = false;

  bool _showTotalTime = false;
  bool _showFirstChunkTime = false;
  bool _showTokenUsage = false;
  bool _showOutputCharacters = false;

  bool _disableAutoScrollOnUp = true;
  bool _resumeAutoScrollOnBottom = true;

  AppConfigProvider() {
    _loadConfig();
  }

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get enableMonet => _enableMonet;
  SendKeyOption get sendKeyOption => _sendKeyOption;
  bool get useSendKeyInEditMode => _useSendKeyInEditMode;

  bool get showTotalTime => _showTotalTime;
  bool get showFirstChunkTime => _showFirstChunkTime;
  bool get showTokenUsage => _showTokenUsage;
  bool get showOutputCharacters => _showOutputCharacters;

  bool get disableAutoScrollOnUp => _disableAutoScrollOnUp;
  bool get resumeAutoScrollOnBottom => _resumeAutoScrollOnBottom;

  void _loadConfig() {
    final themeModeIndex = AppDatabase.appConfigBox
        .get('themeMode', defaultValue: ThemeMode.system.index);
    _themeMode = ThemeMode.values[themeModeIndex];

    final localeCode =
        AppDatabase.appConfigBox.get('locale', defaultValue: null);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }

    _enableMonet =
        AppDatabase.appConfigBox.get('enableMonet', defaultValue: true);

    final sendKeyIndex = AppDatabase.appConfigBox
        .get('sendKeyOption', defaultValue: SendKeyOption.ctrlEnter.index);
    _sendKeyOption = SendKeyOption.values[sendKeyIndex];

    _useSendKeyInEditMode = AppDatabase.appConfigBox
        .get('useSendKeyInEditMode', defaultValue: false);

    _showTotalTime =
        AppDatabase.appConfigBox.get('showTotalTime', defaultValue: false);
    _showFirstChunkTime =
        AppDatabase.appConfigBox.get('showFirstChunkTime', defaultValue: false);
    _showTokenUsage =
        AppDatabase.appConfigBox.get('showTokenUsage', defaultValue: false);
    _showOutputCharacters = AppDatabase.appConfigBox
        .get('showOutputCharacters', defaultValue: false);

    _disableAutoScrollOnUp = AppDatabase.appConfigBox
        .get('disableAutoScrollOnUp', defaultValue: true);
    _resumeAutoScrollOnBottom = AppDatabase.appConfigBox
        .get('resumeAutoScrollOnBottom', defaultValue: true);

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      AppDatabase.appConfigBox.put('themeMode', mode.index);
      notifyListeners();
    }
  }

  void setLocale(Locale? newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      AppDatabase.appConfigBox.put('locale', newLocale?.languageCode);
      notifyListeners();
    }
  }

  void setEnableMonet(bool enable) {
    if (_enableMonet != enable) {
      _enableMonet = enable;
      AppDatabase.appConfigBox.put('enableMonet', enable);
      notifyListeners();
    }
  }

  void setSendKeyOption(SendKeyOption option) {
    if (_sendKeyOption != option) {
      _sendKeyOption = option;
      AppDatabase.appConfigBox.put('sendKeyOption', option.index);
      notifyListeners();
    }
  }

  void setUseSendKeyInEditMode(bool use) {
    if (_useSendKeyInEditMode != use) {
      _useSendKeyInEditMode = use;
      AppDatabase.appConfigBox.put('useSendKeyInEditMode', use);
      notifyListeners();
    }
  }

  void setShowTotalTime(bool show) {
    if (_showTotalTime != show) {
      _showTotalTime = show;
      AppDatabase.appConfigBox.put('showTotalTime', show);
      notifyListeners();
    }
  }

  void setShowFirstChunkTime(bool show) {
    if (_showFirstChunkTime != show) {
      _showFirstChunkTime = show;
      AppDatabase.appConfigBox.put('showFirstChunkTime', show);
      notifyListeners();
    }
  }

  void setShowTokenUsage(bool show) {
    if (_showTokenUsage != show) {
      _showTokenUsage = show;
      AppDatabase.appConfigBox.put('showTokenUsage', show);
      notifyListeners();
    }
  }

  void setShowOutputCharacters(bool show) {
    if (_showOutputCharacters != show) {
      _showOutputCharacters = show;
      AppDatabase.appConfigBox.put('showOutputCharacters', show);
      notifyListeners();
    }
  }

  void setDisableAutoScrollOnUp(bool value) {
    if (_disableAutoScrollOnUp != value) {
      _disableAutoScrollOnUp = value;
      AppDatabase.appConfigBox.put('disableAutoScrollOnUp', value);
      notifyListeners();
    }
  }

  void setResumeAutoScrollOnBottom(bool value) {
    if (_resumeAutoScrollOnBottom != value) {
      _resumeAutoScrollOnBottom = value;
      AppDatabase.appConfigBox.put('resumeAutoScrollOnBottom', value);
      notifyListeners();
    }
  }
}
