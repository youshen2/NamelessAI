import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';

enum SendKeyOption { enter, ctrlEnter, shiftCtrlEnter }

enum ChatBubbleAlignment { normal, center }

enum BubbleAlignmentOption { standard, reversed, allLeft, allRight }

enum FontSize { small, medium, large }

enum HapticIntensity { none, light, medium, heavy, selection }

enum PageTransitionType { system, slide, fade, scale }

enum AppLockTimeout { immediately, after1Minute, after5Minutes, after15Minutes }

class AppConfigProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _enableMonet = true;
  SendKeyOption _sendKeyOption = SendKeyOption.ctrlEnter;
  bool _useSendKeyInEditMode = false;
  Color _seedColor = Colors.blue;

  bool _showTotalTime = false;
  bool _showFirstChunkTime = false;
  bool _showTokenUsage = false;
  bool _showOutputCharacters = false;

  bool _disableAutoScrollOnUp = true;
  bool _resumeAutoScrollOnBottom = true;

  ChatBubbleAlignment _chatBubbleAlignment = ChatBubbleAlignment.normal;
  BubbleAlignmentOption _bubbleAlignmentOption = BubbleAlignmentOption.standard;
  FontSize _fontSize = FontSize.medium;
  bool _showTimestamps = true;
  bool _showModelName = true;
  bool _compactMode = false;
  double _chatBubbleWidth = 0.8;
  bool _distinguishAssistantBubble = true;
  bool _reserveActionSpace = true;
  bool _plainTextMode = false;

  bool _useFirstSentenceAsTitle = true;
  String _codeTheme = 'github';
  bool _showDebugButton = false;
  bool _checkForUpdatesOnStartup = true;
  int _asyncTaskRefreshInterval = 10;
  bool _isFirstLaunch = true;

  bool _hapticsEnabled = true;

  HapticIntensity _buttonPressIntensity = HapticIntensity.light;

  HapticIntensity _switchToggleIntensity = HapticIntensity.selection;

  HapticIntensity _longPressIntensity = HapticIntensity.medium;

  HapticIntensity _sliderChangeIntensity = HapticIntensity.selection;

  HapticIntensity _streamOutputIntensity = HapticIntensity.none;

  HapticIntensity _thinkingIntensity = HapticIntensity.none;

  String _defaultScreen = '/';
  bool _restoreLastSession = true;
  double _cornerRadius = 16.0;
  bool _enableBlurEffect = true;
  PageTransitionType _pageTransitionType = PageTransitionType.system;

  double _scrollButtonBottomOffset = 110.0;
  double _scrollButtonRightOffset = 16.0;

  bool _notificationsEnabled = true;
  bool _showThinkingNotification = true;
  bool _showCompletionNotification = true;
  bool _showErrorNotification = true;

  bool _appLockEnabled = false;
  AppLockTimeout _appLockTimeout = AppLockTimeout.immediately;

  AppConfigProvider() {
    _loadConfig();
  }

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get enableMonet => _enableMonet;
  SendKeyOption get sendKeyOption => _sendKeyOption;
  bool get useSendKeyInEditMode => _useSendKeyInEditMode;
  Color get seedColor => _seedColor;

  bool get showTotalTime => _showTotalTime;
  bool get showFirstChunkTime => _showFirstChunkTime;
  bool get showTokenUsage => _showTokenUsage;
  bool get showOutputCharacters => _showOutputCharacters;

  bool get disableAutoScrollOnUp => _disableAutoScrollOnUp;
  bool get resumeAutoScrollOnBottom => _resumeAutoScrollOnBottom;

  ChatBubbleAlignment get chatBubbleAlignment => _chatBubbleAlignment;
  BubbleAlignmentOption get bubbleAlignmentOption => _bubbleAlignmentOption;
  FontSize get fontSize => _fontSize;
  bool get showTimestamps => _showTimestamps;
  bool get showModelName => _showModelName;
  bool get compactMode => _compactMode;
  double get chatBubbleWidth => _chatBubbleWidth;
  bool get distinguishAssistantBubble => _distinguishAssistantBubble;
  bool get reserveActionSpace => _reserveActionSpace;
  bool get plainTextMode => _plainTextMode;

  bool get useFirstSentenceAsTitle => _useFirstSentenceAsTitle;
  String get codeTheme => _codeTheme;
  bool get showDebugButton => _showDebugButton;
  bool get checkForUpdatesOnStartup => _checkForUpdatesOnStartup;
  int get asyncTaskRefreshInterval => _asyncTaskRefreshInterval;
  bool get isFirstLaunch => _isFirstLaunch;

  bool get hapticsEnabled => _hapticsEnabled;

  HapticIntensity get buttonPressIntensity => _buttonPressIntensity;

  HapticIntensity get switchToggleIntensity => _switchToggleIntensity;

  HapticIntensity get longPressIntensity => _longPressIntensity;

  HapticIntensity get sliderChangeIntensity => _sliderChangeIntensity;

  HapticIntensity get streamOutputIntensity => _streamOutputIntensity;

  HapticIntensity get thinkingIntensity => _thinkingIntensity;

  String get defaultScreen => _defaultScreen;
  bool get restoreLastSession => _restoreLastSession;
  double get cornerRadius => _cornerRadius;
  bool get enableBlurEffect => _enableBlurEffect;
  PageTransitionType get pageTransitionType => _pageTransitionType;

  double get scrollButtonBottomOffset => _scrollButtonBottomOffset;
  double get scrollButtonRightOffset => _scrollButtonRightOffset;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get showThinkingNotification => _showThinkingNotification;
  bool get showCompletionNotification => _showCompletionNotification;
  bool get showErrorNotification => _showErrorNotification;

  bool get appLockEnabled => _appLockEnabled;
  AppLockTimeout get appLockTimeout => _appLockTimeout;

  void _loadConfig() {
    final box = AppDatabase.appConfigBox;
    _themeMode = ThemeMode
        .values[box.get('themeMode', defaultValue: ThemeMode.system.index)];
    final localeCode = box.get('locale');
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _enableMonet = box.get('enableMonet', defaultValue: true);
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
    if (isDesktop) {
      _enableMonet = false;
    }

    _sendKeyOption = SendKeyOption.values[
        box.get('sendKeyOption', defaultValue: SendKeyOption.ctrlEnter.index)];
    _useSendKeyInEditMode =
        box.get('useSendKeyInEditMode', defaultValue: false);
    _seedColor = Color(box.get('seedColor', defaultValue: Colors.blue.value));

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

    final oldReverse = box.get('reverseBubbleAlignment');
    if (oldReverse != null) {
      _bubbleAlignmentOption = oldReverse
          ? BubbleAlignmentOption.reversed
          : BubbleAlignmentOption.standard;
    } else {
      _bubbleAlignmentOption = BubbleAlignmentOption.values[box.get(
          'bubbleAlignmentOption',
          defaultValue: BubbleAlignmentOption.standard.index)];
    }

    _fontSize = FontSize
        .values[box.get('fontSize', defaultValue: FontSize.medium.index)];
    _showTimestamps = box.get('showTimestamps', defaultValue: true);
    _showModelName = box.get('showModelName', defaultValue: true);
    _compactMode = box.get('compactMode', defaultValue: false);
    _chatBubbleWidth = box.get('chatBubbleWidth', defaultValue: 0.8);
    _distinguishAssistantBubble =
        box.get('distinguishAssistantBubble', defaultValue: true);
    _reserveActionSpace = box.get('reserveActionSpace', defaultValue: true);
    _plainTextMode = box.get('plainTextMode', defaultValue: false);
    _useFirstSentenceAsTitle =
        box.get('useFirstSentenceAsTitle', defaultValue: true);
    _codeTheme = box.get('codeTheme', defaultValue: 'github');
    _showDebugButton = box.get('showDebugButton', defaultValue: false);
    _checkForUpdatesOnStartup =
        box.get('checkForUpdatesOnStartup', defaultValue: true);
    _asyncTaskRefreshInterval =
        box.get('asyncTaskRefreshInterval', defaultValue: 10);
    _isFirstLaunch = box.get('isFirstLaunch', defaultValue: true);

    _hapticsEnabled = box.get('hapticsEnabled', defaultValue: true);
    _buttonPressIntensity = HapticIntensity.values[box.get(
        'buttonPressIntensity',
        defaultValue: HapticIntensity.light.index)];
    _switchToggleIntensity = HapticIntensity.values[box.get(
        'switchToggleIntensity',
        defaultValue: HapticIntensity.selection.index)];
    _longPressIntensity = HapticIntensity.values[box.get('longPressIntensity',
        defaultValue: HapticIntensity.medium.index)];
    _sliderChangeIntensity = HapticIntensity.values[box.get(
        'sliderChangeIntensity',
        defaultValue: HapticIntensity.selection.index)];
    _streamOutputIntensity = HapticIntensity.values[box.get(
        'streamOutputIntensity',
        defaultValue: HapticIntensity.none.index)];
    _thinkingIntensity = HapticIntensity.values[
        box.get('thinkingIntensity', defaultValue: HapticIntensity.none.index)];

    _defaultScreen = box.get('defaultScreen', defaultValue: '/');
    _restoreLastSession = box.get('restoreLastSession', defaultValue: true);
    _cornerRadius = box.get('cornerRadius', defaultValue: 16.0);
    _enableBlurEffect = box.get('enableBlurEffect', defaultValue: true);
    _pageTransitionType = PageTransitionType.values[box.get(
        'pageTransitionType',
        defaultValue: PageTransitionType.system.index)];

    _scrollButtonBottomOffset =
        box.get('scrollButtonBottomOffset', defaultValue: 110.0);
    _scrollButtonRightOffset =
        box.get('scrollButtonRightOffset', defaultValue: 16.0);

    _notificationsEnabled =
        box.get('notificationsEnabled', defaultValue: !isDesktop);
    _showThinkingNotification =
        box.get('showThinkingNotification', defaultValue: !isDesktop);
    _showCompletionNotification =
        box.get('showCompletionNotification', defaultValue: !isDesktop);
    _showErrorNotification =
        box.get('showErrorNotification', defaultValue: !isDesktop);

    _appLockEnabled = box.get('appLockEnabled', defaultValue: false);
    _appLockTimeout = AppLockTimeout.values[box.get('appLockTimeout',
        defaultValue: AppLockTimeout.immediately.index)];

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

  void setSeedColor(Color color) {
    if (_seedColor.value != color.value) {
      _seedColor = color;
      _updateValue('seedColor', color.value);
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

  void setBubbleAlignmentOption(BubbleAlignmentOption option) {
    if (_bubbleAlignmentOption != option) {
      _bubbleAlignmentOption = option;
      _updateValue('bubbleAlignmentOption', option.index);
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

  void setDistinguishAssistantBubble(bool value) {
    if (_distinguishAssistantBubble != value) {
      _distinguishAssistantBubble = value;
      _updateValue('distinguishAssistantBubble', value);
    }
  }

  void setReserveActionSpace(bool value) {
    if (_reserveActionSpace != value) {
      _reserveActionSpace = value;
      _updateValue('reserveActionSpace', value);
    }
  }

  void setPlainTextMode(bool enabled) {
    if (_plainTextMode != enabled) {
      _plainTextMode = enabled;
      _updateValue('plainTextMode', enabled);
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

  void setHapticsEnabled(bool enabled) {
    if (_hapticsEnabled != enabled) {
      _hapticsEnabled = enabled;
      _updateValue('hapticsEnabled', enabled);
    }
  }

  void setButtonPressIntensity(HapticIntensity intensity) {
    if (_buttonPressIntensity != intensity) {
      _buttonPressIntensity = intensity;
      _updateValue('buttonPressIntensity', intensity.index);
    }
  }

  void setSwitchToggleIntensity(HapticIntensity intensity) {
    if (_switchToggleIntensity != intensity) {
      _switchToggleIntensity = intensity;
      _updateValue('switchToggleIntensity', intensity.index);
    }
  }

  void setLongPressIntensity(HapticIntensity intensity) {
    if (_longPressIntensity != intensity) {
      _longPressIntensity = intensity;
      _updateValue('longPressIntensity', intensity.index);
    }
  }

  void setSliderChangeIntensity(HapticIntensity intensity) {
    if (_sliderChangeIntensity != intensity) {
      _sliderChangeIntensity = intensity;
      _updateValue('sliderChangeIntensity', intensity.index);
    }
  }

  void setStreamOutputIntensity(HapticIntensity intensity) {
    if (_streamOutputIntensity != intensity) {
      _streamOutputIntensity = intensity;
      _updateValue('streamOutputIntensity', intensity.index);
    }
  }

  void setThinkingIntensity(HapticIntensity intensity) {
    if (_thinkingIntensity != intensity) {
      _thinkingIntensity = intensity;
      _updateValue('thinkingIntensity', intensity.index);
    }
  }

  void setDefaultScreen(String screen) {
    if (_defaultScreen != screen) {
      _defaultScreen = screen;
      _updateValue('defaultScreen', screen);
    }
  }

  void setRestoreLastSession(bool restore) {
    if (_restoreLastSession != restore) {
      _restoreLastSession = restore;
      _updateValue('restoreLastSession', restore);
    }
  }

  void setCornerRadius(double radius) {
    if (_cornerRadius != radius) {
      _cornerRadius = radius;
      _updateValue('cornerRadius', radius);
    }
  }

  void setEnableBlurEffect(bool enable) {
    if (_enableBlurEffect != enable) {
      _enableBlurEffect = enable;
      _updateValue('enableBlurEffect', enable);
    }
  }

  void setPageTransitionType(PageTransitionType type) {
    if (_pageTransitionType != type) {
      _pageTransitionType = type;
      _updateValue('pageTransitionType', type.index);
    }
  }

  void setScrollButtonBottomOffset(double offset) {
    if (_scrollButtonBottomOffset != offset) {
      _scrollButtonBottomOffset = offset;
      _updateValue('scrollButtonBottomOffset', offset);
    }
  }

  void setScrollButtonRightOffset(double offset) {
    if (_scrollButtonRightOffset != offset) {
      _scrollButtonRightOffset = offset;
      _updateValue('scrollButtonRightOffset', offset);
    }
  }

  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      _updateValue('notificationsEnabled', enabled);
    }
  }

  void setShowThinkingNotification(bool show) {
    if (_showThinkingNotification != show) {
      _showThinkingNotification = show;
      _updateValue('showThinkingNotification', show);
    }
  }

  void setShowCompletionNotification(bool show) {
    if (_showCompletionNotification != show) {
      _showCompletionNotification = show;
      _updateValue('showCompletionNotification', show);
    }
  }

  void setShowErrorNotification(bool show) {
    if (_showErrorNotification != show) {
      _showErrorNotification = show;
      _updateValue('showErrorNotification', show);
    }
  }

  void setAppLockEnabled(bool enabled) {
    if (_appLockEnabled != enabled) {
      _appLockEnabled = enabled;
      _updateValue('appLockEnabled', enabled);
    }
  }

  void setAppLockTimeout(AppLockTimeout timeout) {
    if (_appLockTimeout != timeout) {
      _appLockTimeout = timeout;
      _updateValue('appLockTimeout', timeout.index);
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
