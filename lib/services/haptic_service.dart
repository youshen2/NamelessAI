import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';

class HapticService {
  static bool isSupported() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static void _vibrate(BuildContext context, HapticIntensity intensity) {
    if (!isSupported()) return;

    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    if (!appConfig.hapticsEnabled || intensity == HapticIntensity.none) return;

    switch (intensity) {
      case HapticIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticIntensity.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticIntensity.none:
        break;
    }
  }

  static void onButtonPress(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .buttonPressIntensity;
    _vibrate(context, intensity);
  }

  static void onSwitchToggle(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .switchToggleIntensity;
    _vibrate(context, intensity);
  }

  static void onLongPress(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .longPressIntensity;
    _vibrate(context, intensity);
  }

  static void onSliderChange(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .sliderChangeIntensity;
    _vibrate(context, intensity);
  }

  static void onStreamOutput(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .streamOutputIntensity;
    _vibrate(context, intensity);
  }

  static void onThinking(BuildContext context) {
    final intensity = Provider.of<AppConfigProvider>(context, listen: false)
        .thinkingIntensity;
    _vibrate(context, intensity);
  }
}
