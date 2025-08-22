import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/typing_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
    this.activeBranchIndex = 0,
    required this.onBranchChange,
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

    _animationController.forward();
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
    final isUser = widget.message.role == 'user';
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                _buildMessageContent(context),
                if (widget.message.modelName != null) _buildModelName(context),
                if (!widget.isReadOnly) _buildStatistics(context),
                if (!widget.isReadOnly && !widget.message.isEditing)
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
        maxWidth: MediaQuery.of(context).size.width * 0.8,
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
                  : const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        leading:
            Icon(Icons.psychology_outlined, color: textColor.withOpacity(0.8)),
        title: _ThinkingTimer(
          startTime: widget.message.thinkingStartTime,
          durationMs: widget.message.thinkingDurationMs,
          textColor: textColor.withOpacity(0.8),
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
    if (widget.message.isLoading && widget.message.content.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: TypingIndicator(isInline: true),
      );
    }

    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: 15, height: 1.4),
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
      builders: {
        'code': MarkdownCodeBlockBuilder(context: context),
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
              TextButton(
                onPressed: () => widget.onEdit(widget.message, false),
                child: Text(localizations.cancel),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () =>
                    widget.onSave(widget.message, _editController.text),
                child: Text(localizations.save),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: () =>
                      widget.onResubmit(widget.message, _editController.text),
                  label: Text(localizations.saveAndResubmit),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
            _actionButton(Icons.copy_all_outlined, localizations.copyCode,
                () => widget.onCopy(widget.message.content)),
            if (!isUser)
              _actionButton(Icons.refresh, "Regenerate",
                  () => widget.onRegenerate(widget.message)),
            _actionButton(Icons.edit_outlined, localizations.editMessage,
                () => widget.onEdit(widget.message, true)),
            _actionButton(Icons.delete_outline, localizations.deleteMessage,
                () => widget.onDelete(widget.message)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      splashRadius: 18,
      padding: const EdgeInsets.all(6),
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

  Widget _buildModelName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
      child: Text(
        widget.message.modelName!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    if (widget.isReadOnly) return const SizedBox.shrink();

    final appConfig = Provider.of<AppConfigProvider>(context);
    if (widget.message.role != 'assistant' || widget.message.isError) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;
    final stats = <Widget>[];

    if (appConfig.showTotalTime && widget.message.completionTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.totalTime,
          value:
              '${(widget.message.completionTimeMs! / 1000).toStringAsFixed(2)}s'));
    }
    if (appConfig.showFirstChunkTime &&
        widget.message.firstChunkTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.firstChunkTime,
          value:
              '${(widget.message.firstChunkTimeMs! / 1000).toStringAsFixed(2)}s'));
    }
    if (appConfig.showOutputCharacters &&
        widget.message.outputCharacters != null) {
      stats.add(_StatItem(
          label: localizations.outputCharacters,
          value: widget.message.outputCharacters.toString()));
    }
    if (appConfig.showTokenUsage &&
        (widget.message.promptTokens != null ||
            widget.message.completionTokens != null)) {
      final prompt = widget.message.promptTokens?.toString() ?? '-';
      final completion = widget.message.completionTokens?.toString() ?? '-';
      stats.add(_StatItem(
          label: localizations.tokens,
          value:
              '${localizations.prompt}: $prompt / ${localizations.completion}: $completion'));
    }

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 4.0,
        children: stats,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
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
        setState(() {
          _elapsed = DateTime.now().difference(widget.startTime!);
        });
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
    String text;

    if (widget.durationMs != null) {
      final duration = Duration(milliseconds: widget.durationMs!);
      text = "思考耗时: ${_formatDuration(duration)}";
    } else if (widget.startTime != null) {
      text = "正在思考... ${_formatDuration(_elapsed)}";
    } else {
      text = "思考";
    }

    return Text(
      text,
      style: TextStyle(
        color: widget.textColor,
        fontStyle: FontStyle.italic,
        fontSize: 14,
      ),
    );
  }
}
