import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_components.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ThinkingContentWidget extends StatelessWidget {
  final ChatMessage message;
  final Color textColor;
  final bool isPlainText;

  const ThinkingContentWidget({
    super.key,
    required this.message,
    required this.textColor,
    this.isPlainText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(
          color: textColor.withOpacity(0.8), fontSize: 14, height: 1.3),
      code: TextStyle(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        color: textColor.withOpacity(0.8),
        fontFamily: 'monospace',
      ),
    );

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey(
            'thinking_tile_${message.id}_${message.thinkingDurationMs != null}'),
        onExpansionChanged: (isExpanded) =>
            HapticService.onSwitchToggle(context),
        backgroundColor: isPlainText
            ? Colors.transparent
            : theme.colorScheme.surfaceContainerHighest,
        collapsedBackgroundColor: isPlainText
            ? Colors.transparent
            : theme.colorScheme.surfaceContainerHigh,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        leading: Icon(Icons.auto_awesome_outlined,
            color: textColor.withOpacity(0.8)),
        title: Align(
          alignment: Alignment.centerLeft,
          child: _ThinkingTimer(
            startTime: message.thinkingStartTime,
            durationMs: message.thinkingDurationMs,
            textColor: textColor.withOpacity(0.8),
          ),
        ),
        initiallyExpanded: message.thinkingDurationMs == null,
        children: [
          Divider(
              height: 1,
              thickness: 0.5,
              color: textColor.withOpacity(0.2),
              endIndent: 0,
              indent: 0),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPlainText
                  ? Colors.transparent
                  : theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: isPlainText
                  ? null
                  : Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SelectionArea(
              child: MarkdownBody(
                data: message.thinkingContent!,
                selectable: false,
                styleSheet: markdownStyleSheet,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubWeb.blockSyntaxes,
                  [
                    ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
                    MathInlineSyntax(),
                    MathDisplaySyntax(),
                  ],
                ),
                builders: {
                  'code': MarkdownCodeBlockBuilder(
                      context: context, isSelectable: false),
                  'math_inline': MathBuilder(context: context, fontSize: 14),
                  'math_display': MathBuilder(context: context, fontSize: 14),
                  'hr': HrBuilder(context: context),
                },
                onTapLink: (text, href, title) {
                  if (href != null) {
                    HapticService.onButtonPress(context);
                    launchUrl(Uri.parse(href));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingTimer extends StatefulWidget {
  final DateTime? startTime;
  final int? durationMs;
  final Color textColor;

  const _ThinkingTimer({
    this.startTime,
    this.durationMs,
    required this.textColor,
  });

  @override
  State<_ThinkingTimer> createState() => _ThinkingTimerState();
}

class _ThinkingTimerState extends State<_ThinkingTimer> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null && widget.durationMs == null) {
      _elapsed = DateTime.now().difference(widget.startTime!);
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (widget.startTime != null) {
          setState(() {
            _elapsed = DateTime.now().difference(widget.startTime!);
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _ThinkingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.durationMs != null) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    return '${d.inSeconds}.${(d.inMilliseconds % 1000 ~/ 100)}s';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String text;

    if (widget.durationMs != null) {
      final duration = Duration(milliseconds: widget.durationMs!);
      text = localizations.thinkingTimeTaken(_formatDuration(duration));
    } else if (widget.startTime != null) {
      text = localizations.thinking(_formatDuration(_elapsed));
    } else {
      text = localizations.thinkingTitle;
    }

    return Text(
      text,
      style: TextStyle(
        color: widget.textColor,
        fontSize: 14,
      ),
    );
  }
}
