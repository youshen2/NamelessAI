import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

void _showFreeCopyDialog(BuildContext context, String code) {
  final localizations = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.copyCode),
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: SelectableText(code),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            Navigator.of(context).pop();
          },
          child: Text(localizations.close),
        ),
      ],
    ),
  );
}

class MarkdownCodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final bool isSelectable;

  MarkdownCodeBlockBuilder({required this.context, this.isSelectable = true});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code' && element.attributes['class'] != null) {
      final String language = element.attributes['class']!.substring(9);
      final String code = element.textContent;
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final theme = themeMap[appConfig.codeTheme] ?? themeMap['github-dark']!;

      return CollapsibleCodeBlock(
        language: language,
        code: code,
        theme: theme,
        isSelectable: isSelectable,
      );
    }
    return null;
  }
}

class CollapsibleCodeBlock extends StatefulWidget {
  final String language;
  final String code;
  final Map<String, TextStyle> theme;
  final bool isReadOnly;
  final bool isSelectable;

  const CollapsibleCodeBlock({
    super.key,
    required this.language,
    required this.code,
    required this.theme,
    this.isReadOnly = false,
    this.isSelectable = true,
  });

  @override
  State<CollapsibleCodeBlock> createState() => _CollapsibleCodeBlockState();
}

class _CollapsibleCodeBlockState extends State<CollapsibleCodeBlock> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final highlightView = HighlightView(
      widget.code,
      language: widget.language,
      theme: widget.theme,
      padding: const EdgeInsets.all(12.0),
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.theme['root']?.backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.5))
            .toBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.toUpperCase(),
                  style: TextStyle(
                    color: widget.theme['root']?.color?.withOpacity(0.7) ??
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (!widget.isReadOnly)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.content_paste_go_outlined,
                            size: 18,
                            color: widget.theme['root']?.color
                                    ?.withOpacity(0.7) ??
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        tooltip: localizations.freeCopy,
                        onPressed: () {
                          HapticService.onButtonPress(context);
                          _showFreeCopyDialog(context, widget.code);
                        },
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            size: 18,
                            color: widget.theme['root']?.color
                                    ?.withOpacity(0.7) ??
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        tooltip: localizations.copyCode,
                        onPressed: () => copyToClipboard(context, widget.code),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            _isExpanded
                                ? Icons.unfold_less_outlined
                                : Icons.unfold_more_outlined,
                            size: 18,
                            color: widget.theme['root']?.color
                                    ?.withOpacity(0.7) ??
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        tooltip: _isExpanded
                            ? localizations.collapse
                            : localizations.expand,
                        onPressed: () {
                          HapticService.onButtonPress(context);
                          setState(() => _isExpanded = !_isExpanded);
                        },
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _isExpanded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                      height: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.5)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: widget.isSelectable
                        ? SelectionArea(child: highlightView)
                        : highlightView,
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

extension BorderSideToBorder on BorderSide {
  Border toBorder() {
    return Border.fromBorderSide(this);
  }
}
