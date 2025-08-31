import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class HapticSettingsScreen extends StatelessWidget {
  const HapticSettingsScreen({super.key});

  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);
    final isSupported = HapticService.isSupported();
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.hapticSettings),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            16,
            isDesktop ? 16 : 96),
        children: [
          if (!isSupported)
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.hapticsNotSupported,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              title: Text(localizations.enableHapticFeedback),
              value: appConfig.hapticsEnabled,
              onChanged: isSupported
                  ? (value) {
                      appConfig.setHapticsEnabled(value);
                      HapticService.onSwitchToggle(context);
                    }
                  : null,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: AbsorbPointer(
              absorbing: !appConfig.hapticsEnabled || !isSupported,
              child: Opacity(
                opacity: appConfig.hapticsEnabled && isSupported ? 1.0 : 0.5,
                child: Column(
                  children: [
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticButtonPress,
                      value: appConfig.buttonPressIntensity,
                      onChanged: (intensity) {
                        appConfig.setButtonPressIntensity(intensity);
                        HapticService.onButtonPress(context);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticSwitchToggle,
                      value: appConfig.switchToggleIntensity,
                      onChanged: (intensity) {
                        appConfig.setSwitchToggleIntensity(intensity);
                        HapticService.onSwitchToggle(context);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticLongPress,
                      value: appConfig.longPressIntensity,
                      onChanged: (intensity) {
                        appConfig.setLongPressIntensity(intensity);
                        HapticService.onLongPress(context);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticSliderChanged,
                      value: appConfig.sliderChangeIntensity,
                      onChanged: (intensity) {
                        appConfig.setSliderChangeIntensity(intensity);
                        HapticService.onSliderChange(context);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticStreamOutput,
                      value: appConfig.streamOutputIntensity,
                      onChanged: (intensity) {
                        appConfig.setStreamOutputIntensity(intensity);
                        HapticService.onSliderChange(context);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildIntensitySlider(
                      context: context,
                      title: localizations.hapticThinking,
                      value: appConfig.thinkingIntensity,
                      onChanged: (intensity) {
                        appConfig.setThinkingIntensity(intensity);
                        HapticService.onSliderChange(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider({
    required BuildContext context,
    required String title,
    required HapticIntensity value,
    required ValueChanged<HapticIntensity> onChanged,
  }) {
    final localizations = AppLocalizations.of(context)!;
    final Map<HapticIntensity, String> intensityMap = {
      HapticIntensity.none: localizations.hapticIntensityNone,
      HapticIntensity.light: localizations.hapticIntensityLight,
      HapticIntensity.medium: localizations.hapticIntensityMedium,
      HapticIntensity.heavy: localizations.hapticIntensityHeavy,
      HapticIntensity.selection: localizations.hapticIntensitySelection,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(
                intensityMap[value]!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          Slider(
            value: value.index.toDouble(),
            min: 0,
            max: (HapticIntensity.values.length - 1).toDouble(),
            divisions: HapticIntensity.values.length - 1,
            label: intensityMap[value],
            onChanged: (newValue) {
              final newIntensity = HapticIntensity.values[newValue.round()];
              onChanged(newIntensity);
            },
          ),
        ],
      ),
    );
  }
}
