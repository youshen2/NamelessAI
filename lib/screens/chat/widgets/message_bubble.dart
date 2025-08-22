import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/typing_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

class MathBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final double fontSize;

  MathBuilder({required this.context, required this.fontSize});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final isDisplayMode = element.tag == 'math_display';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDisplayMode ? 8.0 : 2.0),
      child: Math.tex(
        text,
        mathStyle: isDisplayMode ? MathStyle.display : MathStyle.text,
        textStyle: preferredStyle?.copyWith(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onErrorFallback: (err) => SelectableText(
          isDisplayMode ? '\$\$${text}\$\$' : '\$${text}\$',
          style: preferredStyle?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class MathInlineSyntax extends md.InlineSyntax {
  MathInlineSyntax() : super(r'\$((?:\\.|[^$])+)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element el = md.Element.text('math_inline', match[1]!);
    parser.addNode(el);
    return true;
  }
}

class MathDisplaySyntax extends md.InlineSyntax {
  MathDisplaySyntax() : super(r'\$\$((?:\\.|[^$])+)\$\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element el = md.Element.text('math_display', match[1]!);
    parser.addNode(el);
    return true;
  }
}

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final Function(ChatMessage, bool) onEdit;
  final Function(ChatMessage, String) onSave;
  final Function(ChatMessage) onDelete;
  final Function(ChatMessage, String) onResubmit;
  final Function(ChatMessage) onRegenerate;
  final Function(String) onCopy;
  final bool isReadOnly;
  final int branchCount;
  final int activeBranchIndex;
  final ValueChanged<int> onBranchChange;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onEdit,
    required this.onSave,
    required this.onDelete,
    required this.onResubmit,
    required this.onRegenerate,
    required this.onCopy,
    this.isReadOnly = false,
    this.branchCount = 0,
    required this.onBranchChange,
    required this.activeBranchIndex,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();
  bool _isHovering = false;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  static final Set<String> _animatedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    if (!_animatedMessageIds.contains(widget.message.id)) {
      _animationController.forward();
      _animatedMessageIds.add(widget.message.id);
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.content != widget.message.content &&
        !widget.message.isEditing) {
      _editController.text = widget.message.content;
    }
    if (oldWidget.message.isEditing != widget.message.isEditing) {
      if (widget.message.isEditing) {
        _editFocusNode.requestFocus();
      }
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleEditKeyEvent(RawKeyEvent event) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    if (!appConfig.useSendKeyInEditMode) return;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      bool shouldSend = false;
      switch (appConfig.sendKeyOption) {
        case SendKeyOption.enter:
          if (!event.isControlPressed && !event.isShiftPressed) {
            shouldSend = true;
          }
          break;
        case SendKeyOption.ctrlEnter:
          if (event.isControlPressed && !event.isShiftPressed) {
            shouldSend = true;
          }
          break;
        case SendKeyOption.shiftCtrlEnter:
          if (event.isControlPressed && event.isShiftPressed) shouldSend = true;
          break;
      }
      if (shouldSend) {
        widget.onResubmit(widget.message, _editController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    final isUser = widget.message.role == 'user';

    CrossAxisAlignment alignment;
    switch (appConfig.chatBubbleAlignment) {
      case ChatBubbleAlignment.center:
        alignment = CrossAxisAlignment.center;
        break;
      case ChatBubbleAlignment.normal:
      default:
        if (appConfig.reverseBubbleAlignment) {
          alignment =
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end;
        } else {
          alignment =
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        }
        break;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 8.0, vertical: appConfig.compactMode ? 2.0 : 4.0),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                _buildMessageContent(context),
                if (!widget.isReadOnly) _buildMetaAndStats(context, alignment),
                if (!widget.isReadOnly &&
                    !widget.message.isEditing &&
                    !widget.message.isLoading)
                  _buildActionBar(context),
                if (widget.branchCount > 1) _buildBranchNavigator(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final isUser = widget.message.role == 'user';
    final isError = widget.message.isError;

    final bubbleColor = isError
        ? Theme.of(context).colorScheme.errorContainer
        : isUser
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainer;
    final textColor = isError
        ? Theme.of(context).colorScheme.onErrorContainer
        : isUser
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * appConfig.chatBubbleWidth,
      ),
      child: Card(
        color: bubbleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.thinkingContent != null &&
                widget.message.thinkingContent!.isNotEmpty)
              _buildThinkingContent(context, textColor),
            Padding(
              padding: widget.message.isEditing
                  ? const EdgeInsets.all(8.0)
                  : EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: appConfig.compactMode ? 6 : 10,
                    ),
              child: widget.message.isEditing
                  ? _buildEditModeContent(context, textColor)
                  : _buildDisplayModeContent(context, textColor, isError),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingContent(BuildContext context, Color textColor) {
    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(
          color: textColor.withOpacity(0.8), fontSize: 14, height: 1.3),
      code: TextStyle(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        color: textColor.withOpacity(0.8),
        fontFamily: 'monospace',
      ),
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey(
            'thinking_tile_${widget.message.id}_${widget.message.thinkingDurationMs != null}'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        collapsedBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHigh,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        leading:
            Icon(Icons.psychology_outlined, color: textColor.withOpacity(0.8)),
        title: Align(
          alignment: Alignment.centerLeft,
          child: _ThinkingTimer(
            startTime: widget.message.thinkingStartTime,
            durationMs: widget.message.thinkingDurationMs,
            textColor: textColor.withOpacity(0.8),
          ),
        ),
        initiallyExpanded: widget.message.thinkingDurationMs == null,
        children: [
          Divider(
              height: 1,
              thickness: 0.5,
              color: textColor.withOpacity(0.2),
              endIndent: 0,
              indent: 0),
          const SizedBox(height: 8),
          SelectionArea(
            child: MarkdownBody(
              data: widget.message.thinkingContent!,
              styleSheet: markdownStyleSheet,
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayModeContent(
      BuildContext context, Color textColor, bool isError) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
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

    if (widget.message.isLoading && widget.message.content.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: TypingIndicator(isInline: true),
      );
    }

    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: fontSize, height: 1.4),
      code: TextStyle(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'monospace',
      ),
      a: TextStyle(color: Theme.of(context).colorScheme.primary),
    );

    final markdownContent = MarkdownBody(
      data: widget.message.content,
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
        'code': MarkdownCodeBlockBuilder(context: context),
        'math_inline': MathBuilder(context: context, fontSize: fontSize),
        'math_display': MathBuilder(context: context, fontSize: fontSize),
      },
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
    );

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: textColor, size: 20),
                const SizedBox(width: 8),
                Expanded(child: markdownContent),
              ],
            )
          else
            markdownContent,
          if (widget.message.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: TypingIndicator(isInline: true),
            ),
        ],
      ),
    );
  }

  Widget _buildEditModeContent(BuildContext context, Color textColor) {
    final localizations = AppLocalizations.of(context)!;
    final isUser = widget.message.role == 'user';

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleEditKeyEvent,
      child: Column(
        children: [
          TextField(
            controller: _editController,
            focusNode: _editFocusNode,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                tooltip: localizations.cancel,
                onPressed: () => widget.onEdit(widget.message, false),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: localizations.save,
                onPressed: () =>
                    widget.onSave(widget.message, _editController.text),
              ),
              if (isUser)
                IconButton(
                  icon: const Icon(Icons.send_and_archive_outlined),
                  tooltip: localizations.saveAndResubmit,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () =>
                      widget.onResubmit(widget.message, _editController.text),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    final localizations = AppLocalizations.of(context)!;
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(widget.message.toJson());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.debugInfo),
        content: SingleChildScrollView(
          child: SelectableText(jsonString),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final platform = Theme.of(context).platform;
    final isTouchDevice = platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.fuchsia;
    final isUser = widget.message.role == 'user';

    return AnimatedOpacity(
      opacity: _isHovering || isTouchDevice ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, right: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(
                Icons.copy_all_outlined,
                localizations.copyMessage,
                () => widget.onCopy(widget.message.content),
                appConfig.compactMode),
            if (!isUser)
              _actionButton(
                  Icons.refresh,
                  localizations.regenerateResponse,
                  () => widget.onRegenerate(widget.message),
                  appConfig.compactMode),
            _actionButton(
                Icons.edit_outlined,
                localizations.editMessage,
                () => widget.onEdit(widget.message, true),
                appConfig.compactMode),
            _actionButton(Icons.delete_outline, localizations.deleteMessage,
                () => widget.onDelete(widget.message), appConfig.compactMode),
            if (appConfig.showDebugButton)
              _actionButton(Icons.bug_report_outlined, localizations.debugInfo,
                  _showDebugInfo, appConfig.compactMode),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String tooltip, VoidCallback onPressed, bool isCompact) {
    final double iconSize = isCompact ? 16 : 18;
    final double padding = isCompact ? 4 : 6;
    return IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      splashRadius: 18,
      padding: EdgeInsets.all(padding),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildBranchNavigator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: widget.activeBranchIndex > 0
                ? () => widget.onBranchChange(widget.activeBranchIndex - 1)
                : null,
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Text(
            '${widget.activeBranchIndex + 1}/${widget.branchCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: widget.activeBranchIndex < widget.branchCount - 1
                ? () => widget.onBranchChange(widget.activeBranchIndex + 1)
                : null,
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaAndStats(
      BuildContext context, CrossAxisAlignment alignment) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final meta = _buildMetaInfo(context);
    final stats = _buildPerformanceStats(context);
    final tokens = _buildTokenStats(context);

    if (meta.isEmpty && stats.isEmpty && tokens.isEmpty) {
      return const SizedBox.shrink();
    }

    final wrapAlignment = alignment == CrossAxisAlignment.start
        ? WrapAlignment.start
        : WrapAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (meta.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
                top: appConfig.compactMode ? 1 : 2.0, right: 8.0, left: 8.0),
            child: Wrap(
              spacing: appConfig.compactMode ? 8.0 : 12.0,
              runSpacing: 4.0,
              alignment: wrapAlignment,
              children: meta,
            ),
          ),
        if (stats.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
                top: appConfig.compactMode ? 2 : 4.0, right: 8.0, left: 8.0),
            child: Wrap(
              spacing: appConfig.compactMode ? 8.0 : 12.0,
              runSpacing: 4.0,
              alignment: wrapAlignment,
              children: stats,
            ),
          ),
        if (tokens.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
                top: appConfig.compactMode ? 2 : 4.0, right: 8.0, left: 8.0),
            child: Wrap(
              spacing: appConfig.compactMode ? 8.0 : 12.0,
              runSpacing: 4.0,
              alignment: wrapAlignment,
              children: tokens,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildMetaInfo(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final showName = appConfig.showModelName &&
        widget.message.modelName != null &&
        widget.message.role == 'assistant';
    final showTime = appConfig.showTimestamps;

    final meta = <Widget>[];

    if (showName) {
      meta.add(_MetaItem(
        label: '${localizations.modelLabel}: ',
        value: widget.message.modelName!,
        isCompact: appConfig.compactMode,
      ));
    }
    if (showTime) {
      meta.add(_MetaItem(
        label: '${localizations.timeLabel}: ',
        value:
            '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
        isCompact: appConfig.compactMode,
      ));
    }

    return meta;
  }

  List<Widget> _buildPerformanceStats(BuildContext context) {
    if (widget.isReadOnly) return [];

    final appConfig = Provider.of<AppConfigProvider>(context);
    if (widget.message.role != 'assistant' || widget.message.isError) {
      return [];
    }

    final localizations = AppLocalizations.of(context)!;
    final stats = <Widget>[];

    if (appConfig.showTotalTime && widget.message.completionTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.totalTime,
          value:
              '${(widget.message.completionTimeMs! / 1000).toStringAsFixed(2)}s',
          isCompact: appConfig.compactMode));
    }
    if (appConfig.showFirstChunkTime &&
        widget.message.firstChunkTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.firstChunkTime,
          value:
              '${(widget.message.firstChunkTimeMs! / 1000).toStringAsFixed(2)}s',
          isCompact: appConfig.compactMode));
    }
    if (appConfig.showOutputCharacters &&
        widget.message.outputCharacters != null) {
      stats.add(_StatItem(
          label: localizations.outputCharacters,
          value: widget.message.outputCharacters.toString(),
          isCompact: appConfig.compactMode));
    }

    return stats;
  }

  List<Widget> _buildTokenStats(BuildContext context) {
    if (widget.isReadOnly) return [];

    final appConfig = Provider.of<AppConfigProvider>(context);
    if (widget.message.role != 'assistant' ||
        widget.message.isError ||
        !appConfig.showTokenUsage) {
      return [];
    }

    final localizations = AppLocalizations.of(context)!;
    final stats = <Widget>[];

    if (widget.message.promptTokens != null ||
        widget.message.completionTokens != null) {
      final prompt = widget.message.promptTokens?.toString() ?? '-';
      final completion = widget.message.completionTokens?.toString() ?? '-';
      stats.add(_StatItem(
          label: localizations.tokens,
          value:
              '${localizations.prompt}: $prompt / ${localizations.completion}: $completion',
          isCompact: appConfig.compactMode));
    }

    return stats;
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isCompact;

  const _MetaItem(
      {required this.label, required this.value, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: isCompact ? 10 : null);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: style?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isCompact;

  const _StatItem(
      {required this.label, required this.value, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: isCompact ? 10 : null);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: style?.copyWith(fontWeight: FontWeight.bold),
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
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
