import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class _SettingsSection extends StatelessWidget {
  final String title;
  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

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

  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);
    final uniqueSortedThemeKeys = themeMap.keys.toSet().toList()..sort();
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.appearanceSettings),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, isDesktop ? 16 : 96),
        children: [
          _SettingsSection(title: localizations.generalSettings),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.language,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8.0),
                  SegmentedButton<Locale?>(
                    segments: [
                      ButtonSegment(
                          value: null,
                          label: Text(localizations.systemDefault)),
                      ButtonSegment(
                          value: const Locale('en'),
                          label: Text(localizations.english)),
                      ButtonSegment(
                          value: const Locale('zh'),
                          label: Text(localizations.chinese)),
                    ],
                    selected: {appConfig.locale},
                    onSelectionChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setLocale(value.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.theme,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(localizations.light),
                          icon: const Icon(Icons.light_mode_outlined)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(localizations.dark),
                          icon: const Icon(Icons.dark_mode_outlined)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(localizations.systemDefault),
                          icon: const Icon(Icons.brightness_auto_outlined)),
                    ],
                    selected: {appConfig.themeMode},
                    onSelectionChanged: (newSelection) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setThemeMode(newSelection.first);
                    },
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    title: Text(localizations.enableMonet),
                    subtitle: Text(localizations.monetTheming),
                    value: appConfig.enableMonet,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setEnableMonet(value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          _SettingsSection(title: 'UI'),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
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
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: Text(localizations.pageTransition),
                    trailing: DropdownButton<PageTransitionType>(
                      value: appConfig.pageTransitionType,
                      underline: const SizedBox.shrink(),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
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
                ],
              ),
            ),
          ),
          _SettingsSection(title: localizations.chatDisplay),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<FontSize>(
                      value: appConfig.fontSize,
                      decoration: InputDecoration(
                        labelText: localizations.fontSize,
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
                    subtitle: Text(localizations.reverseBubbleAlignmentHint),
                    value: appConfig.reverseBubbleAlignment,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setReverseBubbleAlignment(value);
                    },
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
                  ),
                  SwitchListTile(
                    title: Text(localizations.showTimestamps),
                    value: appConfig.showTimestamps,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowTimestamps(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.showModelName),
                    subtitle: Text(localizations.showModelNameHint),
                    value: appConfig.showModelName,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowModelName(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.compactMode),
                    subtitle: Text(localizations.compactModeHint),
                    value: appConfig.compactMode,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setCompactMode(value);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                        '${localizations.chatBubbleWidth}: ${(appConfig.chatBubbleWidth * 100).round()}%'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Slider(
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
                  ),
                ],
              ),
            ),
          ),
          _SettingsSection(title: localizations.codeBlockTheme),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: appConfig.codeTheme,
                      decoration: InputDecoration(
                        labelText: localizations.codeBlockTheme,
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
          _SettingsSection(title: localizations.statisticsSettings),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(localizations.showTotalTime),
                    value: appConfig.showTotalTime,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowTotalTime(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.showFirstChunkTime),
                    value: appConfig.showFirstChunkTime,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowFirstChunkTime(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.showTokenUsage),
                    value: appConfig.showTokenUsage,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowTokenUsage(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.showOutputCharacters),
                    value: appConfig.showOutputCharacters,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowOutputCharacters(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
