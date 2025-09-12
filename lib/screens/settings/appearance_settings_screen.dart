import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  Widget _buildRadioGroup<T>({
    required BuildContext context,
    required String title,
    required T groupValue,
    required List<(String, T)> options,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...options.map((option) => RadioListTile<T>(
              title: Text(option.$1),
              value: option.$2,
              groupValue: groupValue,
              onChanged: (value) {
                HapticService.onSwitchToggle(context);
                onChanged(value);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            )),
      ],
    );
  }

  Widget _buildCodeThemePreview(BuildContext context, String themeKey) {
    final theme = themeMap[themeKey] ?? themeMap['github']!;
    const codeSnippet = '''
void main() {
  print('Hello, NamelessAI!');
}
''';
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: CollapsibleCodeBlock(
          language: 'dart',
          code: codeSnippet,
          theme: theme,
          isReadOnly: true,
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, AppLocalizations localizations,
      AppConfigProvider appConfig) {
    final List<Color> presetColors = [
      ...Colors.primaries,
      ...Colors.accents,
    ].toSet().toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.accentColor,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: presetColors.map((color) {
              final bool isSelected = appConfig.seedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  HapticService.onSwitchToggle(context);
                  appConfig.setSeedColor(color);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3)
                        : Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.5),
                            width: 1.5),
                  ),
                  child: isSelected
                      ? Icon(Icons.check,
                          color: ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

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
    final uniqueSortedThemeKeys = themeMap.keys.toSet().toList()..sort();
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.appearanceSettings),
      ),
      body: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final bool monetAvailable =
              lightDynamic != null && darkDynamic != null;

          return ListView(
            padding: EdgeInsets.fromLTRB(
                16,
                kToolbarHeight + MediaQuery.of(context).padding.top + 16,
                16,
                (isDesktop ? 16 : 96)),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    _buildRadioGroup<Locale?>(
                      context: context,
                      title: localizations.language,
                      groupValue: appConfig.locale,
                      options: [
                        (localizations.systemDefault, null),
                        (localizations.english, const Locale('en')),
                        (localizations.chinese, const Locale('zh')),
                      ],
                      onChanged: (value) => appConfig.setLocale(value),
                    ),
                    const Divider(height: 1),
                    _buildRadioGroup<ThemeMode>(
                      context: context,
                      title: localizations.theme,
                      groupValue: appConfig.themeMode,
                      options: [
                        (localizations.systemDefault, ThemeMode.system),
                        (localizations.light, ThemeMode.light),
                        (localizations.dark, ThemeMode.dark),
                      ],
                      onChanged: (value) => appConfig.setThemeMode(value!),
                    ),
                    if (monetAvailable && !isDesktop) ...[
                      const Divider(height: 1),
                      SwitchListTile(
                        title: Text(localizations.enableMonet),
                        subtitle: Text(localizations.monetTheming),
                        value: appConfig.enableMonet,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setEnableMonet(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                    if (!appConfig.enableMonet || !monetAvailable) ...[
                      const Divider(height: 1),
                      _buildColorPicker(context, localizations, appConfig),
                    ],
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(localizations.enableBlurEffect),
                      subtitle: Text(localizations.enableBlurEffectHint),
                      value: appConfig.enableBlurEffect,
                      onChanged: (value) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setEnableBlurEffect(value);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(localizations.pageTransition),
                      trailing: DropdownButton<PageTransitionType>(
                        value: appConfig.pageTransitionType,
                        items: [
                          DropdownMenuItem(
                              value: PageTransitionType.system,
                              child: Text(localizations.pageTransitionSystem)),
                          DropdownMenuItem(
                              value: PageTransitionType.slide,
                              child: Text(localizations.pageTransitionSlide)),
                          DropdownMenuItem(
                              value: PageTransitionType.fade,
                              child: Text(localizations.pageTransitionFade)),
                          DropdownMenuItem(
                              value: PageTransitionType.scale,
                              child: Text(localizations.pageTransitionScale)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            HapticService.onSwitchToggle(context);
                            appConfig.setPageTransitionType(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations.cornerRadius}: ${appConfig.cornerRadius.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        localizations.cornerRadiusHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Slider(
                        value: appConfig.cornerRadius,
                        min: 0.0,
                        max: 32.0,
                        divisions: 32,
                        label: appConfig.cornerRadius.toStringAsFixed(0),
                        onChanged: (value) {
                          HapticService.onSliderChange(context);
                          appConfig.setCornerRadius(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(localizations.chatDisplay,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<FontSize>(
                          value: appConfig.fontSize,
                          decoration: InputDecoration(
                            labelText: localizations.fontSize,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: FontSize.small,
                                child: Text(localizations.small)),
                            DropdownMenuItem(
                                value: FontSize.medium,
                                child: Text(localizations.medium)),
                            DropdownMenuItem(
                                value: FontSize.large,
                                child: Text(localizations.large)),
                          ],
                          onChanged: (value) {
                            HapticService.onSwitchToggle(context);
                            if (value != null) appConfig.setFontSize(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<ChatBubbleAlignment>(
                          value: appConfig.chatBubbleAlignment,
                          decoration: InputDecoration(
                            labelText: localizations.chatBubbleAlignment,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: ChatBubbleAlignment.normal,
                                child: Text(localizations.normal)),
                            DropdownMenuItem(
                                value: ChatBubbleAlignment.center,
                                child: Text(localizations.center)),
                          ],
                          onChanged: (value) {
                            HapticService.onSwitchToggle(context);
                            if (value != null) {
                              appConfig.setChatBubbleAlignment(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(localizations.reverseBubbleAlignment),
                        subtitle:
                            Text(localizations.reverseBubbleAlignmentHint),
                        value: appConfig.reverseBubbleAlignment,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setReverseBubbleAlignment(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.distinguishAssistantBubble),
                        subtitle:
                            Text(localizations.distinguishAssistantBubbleHint),
                        value: appConfig.distinguishAssistantBubble,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setDistinguishAssistantBubble(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.showTimestamps),
                        value: appConfig.showTimestamps,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowTimestamps(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.showModelName),
                        subtitle: Text(localizations.showModelNameHint),
                        value: appConfig.showModelName,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowModelName(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.compactMode),
                        subtitle: Text(localizations.compactModeHint),
                        value: appConfig.compactMode,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setCompactMode(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.reserveActionSpace),
                        subtitle: Text(localizations.reserveActionSpaceHint),
                        value: appConfig.reserveActionSpace,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setReserveActionSpace(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                            '${localizations.chatBubbleWidth}: ${(appConfig.chatBubbleWidth * 100).round()}%'),
                      ),
                      Slider(
                        value: appConfig.chatBubbleWidth,
                        min: 0.5,
                        max: 1.0,
                        divisions: 5,
                        label: '${(appConfig.chatBubbleWidth * 100).round()}%',
                        onChanged: (value) {
                          HapticService.onSliderChange(context);
                          appConfig.setChatBubbleWidth(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(localizations.codeBlockTheme,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<String>(
                          value: appConfig.codeTheme,
                          decoration: InputDecoration(
                            labelText: localizations.codeBlockTheme,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: uniqueSortedThemeKeys
                              .map((String key) => DropdownMenuItem<String>(
                                    value: key,
                                    child: Text(key),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            HapticService.onSwitchToggle(context);
                            if (value != null) appConfig.setCodeTheme(value);
                          },
                        ),
                      ),
                      _buildCodeThemePreview(context, appConfig.codeTheme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(localizations.statisticsSettings,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      SwitchListTile(
                        title: Text(localizations.showTotalTime),
                        value: appConfig.showTotalTime,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowTotalTime(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.showFirstChunkTime),
                        value: appConfig.showFirstChunkTime,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowFirstChunkTime(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.showTokenUsage),
                        value: appConfig.showTokenUsage,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowTokenUsage(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: Text(localizations.showOutputCharacters),
                        value: appConfig.showOutputCharacters,
                        onChanged: (value) {
                          HapticService.onSwitchToggle(context);
                          appConfig.setShowOutputCharacters(value);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
