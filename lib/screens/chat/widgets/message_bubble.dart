import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/image_viewer_screen.dart';
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
  final Function(ChatMessage) onRefresh;
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
    required this.onRefresh,
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

  Timer? _countdownTimer;
  int _countdown = 0;
  late AppConfigProvider _appConfig;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
    _appConfig = Provider.of<AppConfigProvider>(context, listen: false);

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

    _setupTimer();
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
    if (oldWidget.message.asyncTaskStatus != widget.message.asyncTaskStatus) {
      _setupTimer();
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _setupTimer() {
    _countdownTimer?.cancel();
    final needsTimer = widget.message.taskId != null &&
        (widget.message.asyncTaskStatus == AsyncTaskStatus.submitted ||
            widget.message.asyncTaskStatus == AsyncTaskStatus.inProgress);

    if (needsTimer && _appConfig.asyncTaskRefreshInterval > 0) {
      _countdown = _appConfig.asyncTaskRefreshInterval;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_countdown > 1) {
            _countdown--;
          } else {
            _countdown = _appConfig.asyncTaskRefreshInterval;
          }
        });
      });
    }
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
                    onCopy: () => widget.onCopy(
                        widget.message.videoUrl ?? widget.message.content),
                    onRegenerate: () => widget.onRegenerate(widget.message),
                    onEdit: () => widget.onEdit(widget.message, true),
                    onDelete: () => widget.onDelete(widget.message),
                    onRefresh: () => widget.onRefresh(widget.message),
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
            if (widget.message.isEditing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildEditModeContent(context, textColor),
              )
            else
              _buildDisplayModeContent(context, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayModeContent(BuildContext context, Color textColor) {
    if (widget.message.messageType == MessageType.image) {
      return _buildImageContent(context, textColor);
    }
    if (widget.message.messageType == MessageType.video) {
      return _buildVideoContent(context, textColor);
    }
    return _buildTextContent(context, textColor);
  }

  Widget _buildImageContent(BuildContext context, Color textColor) {
    final localizations = AppLocalizations.of(context)!;
    final message = widget.message;

    if (message.isLoading && message.asyncTaskStatus == AsyncTaskStatus.none) {
      return const SizedBox(
        width: 256,
        height: 256,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (message.asyncTaskStatus != AsyncTaskStatus.none &&
        message.asyncTaskStatus != AsyncTaskStatus.success) {
      return _buildAsyncTaskStatus(context, textColor, localizations);
    }

    if (message.isError || message.content.isEmpty) {
      return _buildTextContent(context, textColor);
    }

    String imageUrl = message.content;
    try {
      final decoded = jsonDecode(message.content);
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          final firstItem = data.first;
          if (firstItem is Map<String, dynamic> &&
              firstItem.containsKey('url')) {
            imageUrl = firstItem['url'];
          }
        }
      }
    } catch (e) {
      // NULL
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(
                  imageUrl: imageUrl,
                  heroTag: message.id,
                ),
              ),
            );
          },
          child: Hero(
            tag: message.id,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 256,
                  height: 256,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.broken_image,
                          size: 48, color: textColor.withOpacity(0.7)),
                      const SizedBox(height: 8),
                      Text(localizations.failedToLoadImage,
                          style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline,
                  size: 14, color: textColor.withOpacity(0.7)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  localizations.imageExpirationWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent(BuildContext context, Color textColor) {
    final localizations = AppLocalizations.of(context)!;
    final message = widget.message;

    if (message.isLoading && message.asyncTaskStatus == AsyncTaskStatus.none) {
      return const SizedBox(
        width: 256,
        height: 256,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (message.asyncTaskStatus != AsyncTaskStatus.none &&
        message.asyncTaskStatus != AsyncTaskStatus.success) {
      return _buildAsyncTaskStatus(context, textColor, localizations);
    }

    if (message.isError) {
      return _buildTextContent(context, textColor);
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.enhancedPrompt != null &&
              message.enhancedPrompt!.isNotEmpty) ...[
            Text(localizations.enhancedPrompt,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: textColor.withOpacity(0.8))),
            const SizedBox(height: 4),
            SelectableText(message.enhancedPrompt!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: textColor.withOpacity(0.8))),
            const SizedBox(height: 12),
          ],
          if (message.videoUrl != null) ...[
            Container(
              width: 256,
              height: 144,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 48),
                  onPressed: () => launchUrl(Uri.parse(message.videoUrl!)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: Icon(Icons.link, size: 16, color: textColor),
              label: Text(localizations.copyUrl,
                  style: TextStyle(color: textColor)),
              onPressed: () => widget.onCopy(message.videoUrl!),
            ),
          ] else ...[
            _buildTextContent(context, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAsyncTaskStatus(
      BuildContext context, Color textColor, AppLocalizations localizations) {
    final message = widget.message;
    String statusText;
    IconData statusIcon;

    switch (message.asyncTaskStatus) {
      case AsyncTaskStatus.submitted:
        statusText = localizations.taskSubmitted;
        statusIcon = Icons.check_circle_outline;
        break;
      case AsyncTaskStatus.inProgress:
        statusText =
            '${localizations.taskInProgress} ${message.asyncTaskProgress ?? ''}';
        statusIcon = Icons.hourglass_bottom_outlined;
        break;
      case AsyncTaskStatus.failure:
        return _buildTextContent(context, textColor);
      default:
        statusText = localizations.taskStatus;
        statusIcon = Icons.info_outline;
    }

    return SizedBox(
      width: 256,
      height: 256,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (message.isLoading)
                const CircularProgressIndicator()
              else
                Icon(statusIcon, size: 48, color: textColor.withOpacity(0.8)),
              const SizedBox(height: 16),
              Text(
                statusText,
                style: TextStyle(color: textColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (message.enhancedPrompt != null &&
                  message.enhancedPrompt!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${localizations.enhancedPrompt}:',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      message.enhancedPrompt!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: textColor.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              if (_countdownTimer?.isActive ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  localizations.refreshingIn(_countdown.toString()),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: textColor.withOpacity(0.7)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, Color textColor) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final isError = widget.message.isError;
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
        padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: appConfig.compactMode ? 6 : 10,
      ),
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
          if (widget.message.isLoading &&
              widget.message.asyncTaskStatus == AsyncTaskStatus.none)
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
}
