import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';

class MarkdownCodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  MarkdownCodeBlockBuilder({required this.context});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code' && element.attributes['class'] != null) {
      final String language = element.attributes['class']!.substring(9);
      final String code = element.textContent;
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final theme = themeMap[appConfig.codeTheme] ?? themeMap['github-dark']!;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: theme['root']?.backgroundColor ??
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
                    language.toUpperCase(),
                    style: TextStyle(
                      color: theme['root']?.color?.withOpacity(0.7) ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy,
                        size: 18,
                        color: theme['root']?.color?.withOpacity(0.7) ??
                            Theme.of(context).colorScheme.onSurfaceVariant),
                    tooltip: AppLocalizations.of(context)!.copyCode,
                    onPressed: () => copyToClipboard(context, code),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.5)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                code,
                language: language,
                theme: theme,
                padding: const EdgeInsets.all(12.0),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }
}

extension BorderSideToBorder on BorderSide {
  Border toBorder() {
    return Border.fromBorderSide(this);
  }
}
