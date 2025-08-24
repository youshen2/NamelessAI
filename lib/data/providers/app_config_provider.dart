import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';

enum SendKeyOption { enter, ctrlEnter, shiftCtrlEnter }

enum ChatBubbleAlignment { normal, center }

enum FontSize { small, medium, large }

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

  ChatBubbleAlignment _chatBubbleAlignment = ChatBubbleAlignment.normal;
  bool _reverseBubbleAlignment = false;
  FontSize _fontSize = FontSize.medium;
  bool _showTimestamps = true;
  bool _showModelName = true;
  bool _compactMode = false;
  double _chatBubbleWidth = 0.8;

  bool _useFirstSentenceAsTitle = true;
  String _codeTheme = 'github';
  bool _showDebugButton = false;
  bool _checkForUpdatesOnStartup = true;
  int _asyncTaskRefreshInterval = 10;
  bool _isFirstLaunch = true;

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

  ChatBubbleAlignment get chatBubbleAlignment => _chatBubbleAlignment;
  bool get reverseBubbleAlignment => _reverseBubbleAlignment;
  FontSize get fontSize => _fontSize;
  bool get showTimestamps => _showTimestamps;
  bool get showModelName => _showModelName;
  bool get compactMode => _compactMode;
  double get chatBubbleWidth => _chatBubbleWidth;

  bool get useFirstSentenceAsTitle => _useFirstSentenceAsTitle;
  String get codeTheme => _codeTheme;
  bool get showDebugButton => _showDebugButton;
  bool get checkForUpdatesOnStartup => _checkForUpdatesOnStartup;
  int get asyncTaskRefreshInterval => _asyncTaskRefreshInterval;
  bool get isFirstLaunch => _isFirstLaunch;

  void _loadConfig() {
    final box = AppDatabase.appConfigBox;
    _themeMode = ThemeMode
        .values[box.get('themeMode', defaultValue: ThemeMode.system.index)];
    final localeCode = box.get('locale');
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _enableMonet = box.get('enableMonet', defaultValue: true);
    _sendKeyOption = SendKeyOption.values[
        box.get('sendKeyOption', defaultValue: SendKeyOption.ctrlEnter.index)];
    _useSendKeyInEditMode =
        box.get('useSendKeyInEditMode', defaultValue: false);
    _showTotalTime = box.get('showTotalTime', defaultValue: false);
    _showFirstChunkTime = box.get('showFirstChunkTime', defaultValue: false);
    _showTokenUsage = box.get('showTokenUsage', defaultValue: false);
    _showOutputCharacters =
        box.get('showOutputCharacters', defaultValue: false);
    _disableAutoScrollOnUp =
        box.get('disableAutoScrollOnUp', defaultValue: true);
    _resumeAutoScrollOnBottom =
        box.get('resumeAutoScrollOnBottom', defaultValue: true);
    _chatBubbleAlignment = ChatBubbleAlignment.values[box.get(
        'chatBubbleAlignment',
        defaultValue: ChatBubbleAlignment.normal.index)];
    _reverseBubbleAlignment =
        box.get('reverseBubbleAlignment', defaultValue: false);
    _fontSize = FontSize
        .values[box.get('fontSize', defaultValue: FontSize.medium.index)];
    _showTimestamps = box.get('showTimestamps', defaultValue: true);
    _showModelName = box.get('showModelName', defaultValue: true);
    _compactMode = box.get('compactMode', defaultValue: false);
    _chatBubbleWidth = box.get('chatBubbleWidth', defaultValue: 0.8);
    _useFirstSentenceAsTitle =
        box.get('useFirstSentenceAsTitle', defaultValue: true);
    _codeTheme = box.get('codeTheme', defaultValue: 'github');
    _showDebugButton = box.get('showDebugButton', defaultValue: false);
    _checkForUpdatesOnStartup =
        box.get('checkForUpdatesOnStartup', defaultValue: true);
    _asyncTaskRefreshInterval =
        box.get('asyncTaskRefreshInterval', defaultValue: 10);
    _isFirstLaunch = box.get('isFirstLaunch', defaultValue: true);

    notifyListeners();
  }

  Future<void> _updateValue(String key, dynamic value) async {
    await AppDatabase.appConfigBox.put(key, value);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateValue('themeMode', mode.index);
    }
  }

  void setLocale(Locale? newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _updateValue('locale', newLocale?.languageCode);
    }
  }

  void setEnableMonet(bool enable) {
    if (_enableMonet != enable) {
      _enableMonet = enable;
      _updateValue('enableMonet', enable);
    }
  }

  void setSendKeyOption(SendKeyOption option) {
    if (_sendKeyOption != option) {
      _sendKeyOption = option;
      _updateValue('sendKeyOption', option.index);
    }
  }

  void setUseSendKeyInEditMode(bool use) {
    if (_useSendKeyInEditMode != use) {
      _useSendKeyInEditMode = use;
      _updateValue('useSendKeyInEditMode', use);
    }
  }

  void setShowTotalTime(bool show) {
    if (_showTotalTime != show) {
      _showTotalTime = show;
      _updateValue('showTotalTime', show);
    }
  }

  void setShowFirstChunkTime(bool show) {
    if (_showFirstChunkTime != show) {
      _showFirstChunkTime = show;
      _updateValue('showFirstChunkTime', show);
    }
  }

  void setShowTokenUsage(bool show) {
    if (_showTokenUsage != show) {
      _showTokenUsage = show;
      _updateValue('showTokenUsage', show);
    }
  }

  void setShowOutputCharacters(bool show) {
    if (_showOutputCharacters != show) {
      _showOutputCharacters = show;
      _updateValue('showOutputCharacters', show);
    }
  }

  void setDisableAutoScrollOnUp(bool value) {
    if (_disableAutoScrollOnUp != value) {
      _disableAutoScrollOnUp = value;
      _updateValue('disableAutoScrollOnUp', value);
    }
  }

  void setResumeAutoScrollOnBottom(bool value) {
    if (_resumeAutoScrollOnBottom != value) {
      _resumeAutoScrollOnBottom = value;
      _updateValue('resumeAutoScrollOnBottom', value);
    }
  }

  void setChatBubbleAlignment(ChatBubbleAlignment alignment) {
    if (_chatBubbleAlignment != alignment) {
      _chatBubbleAlignment = alignment;
      _updateValue('chatBubbleAlignment', alignment.index);
    }
  }

  void setReverseBubbleAlignment(bool reverse) {
    if (_reverseBubbleAlignment != reverse) {
      _reverseBubbleAlignment = reverse;
      _updateValue('reverseBubbleAlignment', reverse);
    }
  }

  void setFontSize(FontSize size) {
    if (_fontSize != size) {
      _fontSize = size;
      _updateValue('fontSize', size.index);
    }
  }

  void setShowTimestamps(bool show) {
    if (_showTimestamps != show) {
      _showTimestamps = show;
      _updateValue('showTimestamps', show);
    }
  }

  void setShowModelName(bool show) {
    if (_showModelName != show) {
      _showModelName = show;
      _updateValue('showModelName', show);
    }
  }

  void setCompactMode(bool isCompact) {
    if (_compactMode != isCompact) {
      _compactMode = isCompact;
      _updateValue('compactMode', isCompact);
    }
  }

  void setChatBubbleWidth(double width) {
    if (_chatBubbleWidth != width) {
      _chatBubbleWidth = width;
      _updateValue('chatBubbleWidth', width);
    }
  }

  void setUseFirstSentenceAsTitle(bool value) {
    if (_useFirstSentenceAsTitle != value) {
      _useFirstSentenceAsTitle = value;
      _updateValue('useFirstSentenceAsTitle', value);
    }
  }

  void setCodeTheme(String theme) {
    if (_codeTheme != theme) {
      _codeTheme = theme;
      _updateValue('codeTheme', theme);
    }
  }

  void setShowDebugButton(bool show) {
    if (_showDebugButton != show) {
      _showDebugButton = show;
      _updateValue('showDebugButton', show);
    }
  }

  void setCheckForUpdatesOnStartup(bool check) {
    if (_checkForUpdatesOnStartup != check) {
      _checkForUpdatesOnStartup = check;
      _updateValue('checkForUpdatesOnStartup', check);
    }
  }

  void setAsyncTaskRefreshInterval(int interval) {
    if (_asyncTaskRefreshInterval != interval) {
      _asyncTaskRefreshInterval = interval;
      _updateValue('asyncTaskRefreshInterval', interval);
    }
  }

  Future<void> completeOnboarding() async {
    if (_isFirstLaunch) {
      _isFirstLaunch = false;
      await _updateValue('isFirstLaunch', false);
    }
  }

  Future<void> resetOnboarding() async {
    if (!_isFirstLaunch) {
      _isFirstLaunch = true;
      await _updateValue('isFirstLaunch', true);
    }
  }
}
