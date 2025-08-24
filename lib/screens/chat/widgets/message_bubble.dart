import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_code_block.dart';
import 'package:nameless_ai/screens/chat/widgets/markdown_components.dart';
import 'package:nameless_ai/screens/chat/widgets/message_action_bar.dart';
import 'package:nameless_ai/screens/chat/widgets/message_branch_navigator.dart';
import 'package:nameless_ai/screens/chat/widgets/message_meta_info.dart';
import 'package:nameless_ai/screens/chat/widgets/thinking_content_widget.dart';
import 'package:nameless_ai/screens/chat/widgets/typing_indicator.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final Set<String> animatedMessageIds;
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
    required this.animatedMessageIds,
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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();
  bool _isHovering = false;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

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

    if (widget.isReadOnly) {
      _animationController.value = 1.0;
    } else if (!widget.animatedMessageIds.contains(widget.message.id)) {
      _animationController.forward();
      widget.animatedMessageIds.add(widget.message.id);
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.content != widget.message.content) {
      _editController.text = widget.message.content;
    }
    if (oldWidget.message.isEditing != widget.message.isEditing) {
      if (widget.message.isEditing) {
        _editController.text = widget.message.content;
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
    super.build(context);
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
                if (!widget.isReadOnly)
                  MessageMetaInfo(
                      message: widget.message, alignment: alignment),
                if (!widget.isReadOnly &&
                    !widget.message.isEditing &&
                    !widget.message.isLoading)
                  MessageActionBar(
                    message: widget.message,
                    isHovering: _isHovering,
                    onCopy: () => widget.onCopy(widget.message.content),
                    onRegenerate: () => widget.onRegenerate(widget.message),
                    onEdit: () => widget.onEdit(widget.message, true),
                    onDelete: () => widget.onDelete(widget.message),
                  ),
                if (widget.branchCount > 1)
                  MessageBranchNavigator(
                    branchCount: widget.branchCount,
                    activeBranchIndex: widget.activeBranchIndex,
                    onBranchChange: widget.onBranchChange,
                  ),
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
              ThinkingContentWidget(
                  message: widget.message, textColor: textColor),
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
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.6),
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'monospace',
      ),
      a: TextStyle(color: Theme.of(context).colorScheme.primary),
    );

    final markdownContent = SelectionArea(
      child: MarkdownBody(
        data: widget.message.content,
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
          'code': MarkdownCodeBlockBuilder(context: context),
          'math_inline': MathBuilder(context: context, fontSize: fontSize),
          'math_display': MathBuilder(context: context, fontSize: fontSize),
          'hr': HrBuilder(context: context),
        },
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
      ),
    );

    return Column(
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
}
