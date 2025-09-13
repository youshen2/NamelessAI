import 'dart:typed_data';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gal/gal.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';
import 'package:nameless_ai/widgets/responsive_layout.dart';

class ScreenshotOptionsScreen extends StatefulWidget {
  final List<ChatMessage> messages;
  const ScreenshotOptionsScreen({super.key, required this.messages});

  @override
  State<ScreenshotOptionsScreen> createState() =>
      _ScreenshotOptionsScreenState();
}

class _ScreenshotOptionsScreenState extends State<ScreenshotOptionsScreen> {
  final _screenshotController = ScreenshotController();
  late AppLocalizations _localizations;

  ThemeMode? _screenshotTheme;
  ThemeMode? _previousTheme;
  bool _enableWatermark = false;
  late TextEditingController _watermarkController;
  Color? _backgroundColor;
  Color? _userBubbleColor;
  Color? _aiBubbleColor;
  bool _useMonetColors = false;
  late double _bubbleWidth;
  Alignment _watermarkPosition = Alignment.bottomRight;
  double _watermarkFontSize = 12.0;
  Color? _watermarkColor;
  double _watermarkPadding = 8.0;
  bool _isSaving = false;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _watermarkController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _localizations = AppLocalizations.of(context)!;
      _watermarkController.text = _localizations.appName;
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final isDarkMode =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      _screenshotTheme = appConfig.themeMode == ThemeMode.system
          ? (isDarkMode ? ThemeMode.dark : ThemeMode.light)
          : appConfig.themeMode;
      _bubbleWidth = appConfig.chatBubbleWidth;
      _previousTheme = _screenshotTheme;
      _didInit = true;
    }
  }

  @override
  void dispose() {
    _watermarkController.dispose();
    super.dispose();
  }

  Future<void> _saveScreenshot() async {
    if (_isSaving) return;
    HapticService.onButtonPress(context);
    setState(() => _isSaving = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0,
      );
      if (imageBytes != null) {
        await Gal.putImageBytes(
          imageBytes,
          name:
              "namelessai_screenshot_${DateTime.now().millisecondsSinceEpoch}",
        );
        if (mounted) {
          showSnackBar(context, _localizations.screenshotSaved);
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, _localizations.screenshotError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _pickColor(BuildContext context, ThemeData previewTheme,
      Color initialColor, ValueChanged<Color> onColor) {
    HapticService.onButtonPress(context);
    showDialog(
      context: context,
      builder: (context) {
        Color pickedColor = initialColor;
        return Theme(
          data: previewTheme,
          child: AlertDialog(
            title: Text(_localizations.backgroundColor),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: initialColor,
                onColorChanged: (color) => pickedColor = color,
                enableAlpha: false,
                displayThumbColor: true,
                pickerAreaBorderRadius: BorderRadius.circular(8),
              ),
            ),
            actions: [
              TextButton(
                child: Text(_localizations.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FilledButton(
                child: Text(_localizations.save),
                onPressed: () {
                  onColor(pickedColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context, ThemeData previewTheme,
      ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    showBlurredModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return _buildSettings(
                  context,
                  previewTheme,
                  lightDynamic,
                  darkDynamic,
                  (fn) {
                    setState(fn);
                    setSheetState(() {});
                  },
                  scrollController,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainAppTheme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final isDark = _screenshotTheme == ThemeMode.dark;
        ColorScheme colorScheme;
        if (_useMonetColors && lightDynamic != null && darkDynamic != null) {
          colorScheme = isDark ? darkDynamic : lightDynamic;
        } else {
          colorScheme = ColorScheme.fromSeed(
              seedColor: appConfig.seedColor,
              brightness: isDark ? Brightness.dark : Brightness.light);
        }

        if (_previousTheme != _screenshotTheme) {
          _backgroundColor = colorScheme.surface;
          _userBubbleColor = colorScheme.primaryContainer;
          _aiBubbleColor = colorScheme.surfaceContainer;
          _watermarkColor = colorScheme.onSurface.withOpacity(0.4);
          _useMonetColors = false;
          _previousTheme = _screenshotTheme;
        } else {
          _backgroundColor ??= colorScheme.surface;
          _userBubbleColor ??= colorScheme.primaryContainer;
          _aiBubbleColor ??= colorScheme.surfaceContainer;
          _watermarkColor ??= colorScheme.onSurface.withOpacity(0.4);
        }

        final previewDialogTheme = ThemeData.from(colorScheme: colorScheme);

        return Theme(
          data: mainAppTheme,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_localizations.screenshot),
              actions: [
                if (!isDesktop)
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => _showSettingsSheet(
                        context, previewDialogTheme, lightDynamic, darkDynamic),
                    tooltip: _localizations.screenshotOptions,
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FilledButton.icon(
                    onPressed: _saveScreenshot,
                    label: Text(_localizations.generateScreenshot),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_alt_outlined),
                  ),
                ),
              ],
            ),
            body: ResponsiveLayout(
              desktopBody: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPreview(previewDialogTheme, appConfig),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 1,
                    child: _buildSettings(context, previewDialogTheme,
                        lightDynamic, darkDynamic, setState),
                  ),
                ],
              ),
              mobileBody: _buildPreview(previewDialogTheme, appConfig),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreview(ThemeData previewTheme, AppConfigProvider appConfig) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            return Screenshot(
              controller: _screenshotController,
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: Theme(
                  data: previewTheme,
                  child: _ScreenshotContent(
                    messages: widget.messages,
                    backgroundColor: _backgroundColor!,
                    userBubbleColor: _userBubbleColor!,
                    aiBubbleColor: _aiBubbleColor!,
                    bubbleWidth: _bubbleWidth,
                    enableWatermark: _enableWatermark,
                    watermarkText: _watermarkController.text,
                    watermarkPosition: _watermarkPosition,
                    watermarkFontSize: _watermarkFontSize,
                    watermarkColor: _watermarkColor!,
                    watermarkPadding: _watermarkPadding,
                    appConfig: appConfig,
                    previewWidth: constraints.maxWidth,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettings(
      BuildContext context,
      ThemeData previewTheme,
      ColorScheme? lightDynamic,
      ColorScheme? darkDynamic,
      void Function(VoidCallback fn) stateSetter,
      [ScrollController? scrollController]) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(localizations.screenshotTheme,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(localizations.light),
                        icon: const Icon(Icons.light_mode_outlined)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(localizations.dark),
                        icon: const Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {_screenshotTheme!},
                  onSelectionChanged: (selection) {
                    HapticService.onSwitchToggle(context);
                    stateSetter(() {
                      _screenshotTheme = selection.first;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text(localizations.backgroundColor),
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                ),
                onTap: () => _pickColor(
                    context, previewTheme, _backgroundColor!, (color) {
                  stateSetter(() {
                    _backgroundColor = color;
                    _useMonetColors = false;
                  });
                }),
              ),
              if (lightDynamic != null && darkDynamic != null && !isDesktop)
                SwitchListTile(
                  title: Text(localizations.useMonetColors),
                  value: _useMonetColors,
                  onChanged: (value) {
                    HapticService.onSwitchToggle(context);
                    stateSetter(() {
                      _useMonetColors = value;
                      final isDark = _screenshotTheme == ThemeMode.dark;
                      ColorScheme newColorScheme;
                      if (value) {
                        newColorScheme = isDark ? darkDynamic : lightDynamic;
                      } else {
                        newColorScheme = ColorScheme.fromSeed(
                            seedColor: appConfig.seedColor,
                            brightness:
                                isDark ? Brightness.dark : Brightness.light);
                      }
                      _backgroundColor = newColorScheme.surface;
                      _userBubbleColor = newColorScheme.primaryContainer;
                      _aiBubbleColor = newColorScheme.surfaceContainer;
                      _watermarkColor =
                          newColorScheme.onSurface.withOpacity(0.4);
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(localizations.chat, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(localizations.userBubbleColor),
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _userBubbleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                ),
                onTap: () => _pickColor(
                    context, previewTheme, _userBubbleColor!, (color) {
                  stateSetter(() {
                    _userBubbleColor = color;
                    _useMonetColors = false;
                  });
                }),
              ),
              ListTile(
                title: Text(localizations.aiBubbleColor),
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _aiBubbleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                ),
                onTap: () =>
                    _pickColor(context, previewTheme, _aiBubbleColor!, (color) {
                  stateSetter(() {
                    _aiBubbleColor = color;
                    _useMonetColors = false;
                  });
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  '${localizations.bubbleWidth}: ${(_bubbleWidth * 100).round()}%',
                ),
              ),
              Slider(
                value: _bubbleWidth,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                label: '${(_bubbleWidth * 100).round()}%',
                onChanged: (value) {
                  HapticService.onSliderChange(context);
                  stateSetter(() => _bubbleWidth = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(localizations.watermark,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(localizations.enableWatermark),
                value: _enableWatermark,
                onChanged: (value) {
                  HapticService.onSwitchToggle(context);
                  stateSetter(() => _enableWatermark = value);
                },
              ),
              if (_enableWatermark) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _watermarkController,
                    decoration:
                        InputDecoration(labelText: localizations.watermarkText),
                    onChanged: (_) => stateSetter(() {}),
                  ),
                ),
                ListTile(
                  title: Text(localizations.watermarkColor),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _watermarkColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  onTap: () => _pickColor(
                      context, previewTheme, _watermarkColor!, (color) {
                    stateSetter(() {
                      _watermarkColor = color;
                    });
                  }),
                ),
                ListTile(
                  title: Text(localizations.watermarkPosition),
                  trailing: DropdownButton<Alignment>(
                    value: _watermarkPosition,
                    items: [
                      DropdownMenuItem(
                          value: Alignment.topLeft,
                          child: Text(localizations.topLeft)),
                      DropdownMenuItem(
                          value: Alignment.topCenter,
                          child: Text(localizations.topCenter)),
                      DropdownMenuItem(
                          value: Alignment.topRight,
                          child: Text(localizations.topRight)),
                      DropdownMenuItem(
                          value: Alignment.centerLeft,
                          child: Text(localizations.centerLeft)),
                      DropdownMenuItem(
                          value: Alignment.center,
                          child: Text(localizations.center)),
                      DropdownMenuItem(
                          value: Alignment.centerRight,
                          child: Text(localizations.centerRight)),
                      DropdownMenuItem(
                          value: Alignment.bottomLeft,
                          child: Text(localizations.bottomLeft)),
                      DropdownMenuItem(
                          value: Alignment.bottomCenter,
                          child: Text(localizations.bottomCenter)),
                      DropdownMenuItem(
                          value: Alignment.bottomRight,
                          child: Text(localizations.bottomRight)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        HapticService.onSwitchToggle(context);
                        stateSetter(() => _watermarkPosition = value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    '${localizations.watermarkPadding}: ${_watermarkPadding.toStringAsFixed(0)}',
                  ),
                ),
                Slider(
                  value: _watermarkPadding,
                  min: 0.0,
                  max: 32.0,
                  divisions: 32,
                  label: _watermarkPadding.toStringAsFixed(0),
                  onChanged: (value) {
                    HapticService.onSliderChange(context);
                    stateSetter(() => _watermarkPadding = value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    '${localizations.watermarkFontSize}: ${_watermarkFontSize.toStringAsFixed(0)}',
                  ),
                ),
                Slider(
                  value: _watermarkFontSize,
                  min: 8.0,
                  max: 24.0,
                  divisions: 16,
                  label: _watermarkFontSize.toStringAsFixed(0),
                  onChanged: (value) {
                    HapticService.onSliderChange(context);
                    stateSetter(() => _watermarkFontSize = value);
                  },
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _ScreenshotContent extends StatelessWidget {
  final List<ChatMessage> messages;
  final Color backgroundColor;
  final Color userBubbleColor;
  final Color aiBubbleColor;
  final double bubbleWidth;
  final bool enableWatermark;
  final String watermarkText;
  final Alignment watermarkPosition;
  final double watermarkFontSize;
  final Color watermarkColor;
  final double watermarkPadding;
  final AppConfigProvider appConfig;
  final double previewWidth;

  const _ScreenshotContent({
    required this.messages,
    required this.backgroundColor,
    required this.userBubbleColor,
    required this.aiBubbleColor,
    required this.bubbleWidth,
    required this.enableWatermark,
    required this.watermarkText,
    required this.watermarkPosition,
    required this.watermarkFontSize,
    required this.watermarkColor,
    required this.watermarkPadding,
    required this.appConfig,
    required this.previewWidth,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget content;
    if (appConfig.plainTextMode) {
      content = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isUser = message.role == 'user';
          final isError = message.isError;
          final textColor = isError
              ? themeData.colorScheme.error
              : isUser
                  ? themeData.colorScheme.primary
                  : themeData.colorScheme.onSurface;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: _ScreenshotMessageBubble(
              message: message,
              isUser: isUser,
              bubbleColor: Colors.transparent,
              textColor: textColor,
              bubbleWidth: 1.0,
              previewWidth: previewWidth,
              appConfig: appConfig,
              isPlainText: true,
            ),
          );
        },
      );
    } else {
      content = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isUser = message.role == 'user';
          final isError = message.isError;
          return _ScreenshotMessageBubble(
            message: message,
            isUser: isUser,
            bubbleColor: isError
                ? themeData.colorScheme.errorContainer
                : isUser
                    ? userBubbleColor
                    : aiBubbleColor,
            textColor: isError
                ? themeData.colorScheme.onErrorContainer
                : isUser
                    ? themeData.colorScheme.onPrimaryContainer
                    : themeData.colorScheme.onSurface,
            bubbleWidth: bubbleWidth,
            previewWidth: previewWidth,
            appConfig: appConfig,
            isPlainText: false,
          );
        },
      );
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          content,
          if (enableWatermark && watermarkText.isNotEmpty)
            Positioned.fill(
              child: Align(
                alignment: watermarkPosition,
                child: Padding(
                  padding: EdgeInsets.all(watermarkPadding),
                  child: Text(
                    watermarkText,
                    style: TextStyle(
                      fontSize: watermarkFontSize,
                      color: watermarkColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScreenshotMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final Color bubbleColor;
  final Color textColor;
  final double bubbleWidth;
  final double previewWidth;
  final AppConfigProvider appConfig;
  final bool isPlainText;

  const _ScreenshotMessageBubble({
    required this.message,
    required this.isUser,
    required this.bubbleColor,
    required this.textColor,
    required this.bubbleWidth,
    required this.previewWidth,
    required this.appConfig,
    required this.isPlainText,
  });

  @override
  Widget build(BuildContext context) {
    CrossAxisAlignment alignment;
    switch (appConfig.bubbleAlignmentOption) {
      case BubbleAlignmentOption.standard:
        alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        break;
      case BubbleAlignmentOption.reversed:
        alignment = isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end;
        break;
      case BubbleAlignmentOption.allLeft:
        alignment = CrossAxisAlignment.start;
        break;
      case BubbleAlignmentOption.allRight:
        alignment = CrossAxisAlignment.end;
        break;
    }
    if (appConfig.chatBubbleAlignment == ChatBubbleAlignment.center) {
      alignment = CrossAxisAlignment.center;
    }

    double fontSize;
    switch (appConfig.fontSize) {
      case FontSize.small:
        fontSize = 13;
        break;
      case FontSize.large:
        fontSize = 17;
        break;
      case FontSize.medium:
      default:
        fontSize = 15;
        break;
    }

    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: fontSize, height: 1.4),
      code: TextStyle(
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.6),
        color: textColor,
        fontFamily: 'monospace',
      ),
      a: TextStyle(color: Theme.of(context).colorScheme.primary),
    );

    final content = MarkdownBody(
      data: message.content,
      selectable: false,
      styleSheet: markdownStyleSheet,
      extensionSet: md.ExtensionSet.gitHubWeb,
      builders: {
        'code': MarkdownCodeBlockBuilder(
            context: context, isSelectable: false, wrapCode: true),
      },
    );

    if (isPlainText) {
      return Column(
        crossAxisAlignment: alignment,
        children: [content],
      );
    }

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: appConfig.compactMode ? 1.0 : 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: previewWidth * bubbleWidth,
            ),
            child: Card(
              color: bubbleColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(appConfig.cornerRadius),
                side: !isUser && appConfig.distinguishAssistantBubble
                    ? BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5),
                      )
                    : BorderSide.none,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: appConfig.compactMode ? 6 : 10),
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
