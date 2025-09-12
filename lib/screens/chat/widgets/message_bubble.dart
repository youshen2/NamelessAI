import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:nameless_ai/services/haptic_service.dart';

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

    if (widget.message.content != oldWidget.message.content) {
      if (widget.message.isLoading &&
          !widget.isReadOnly &&
          widget.message.role == 'assistant' &&
          widget.message.asyncTaskStatus == AsyncTaskStatus.none) {
        HapticService.onStreamOutput(context);
      }
    }

    if (widget.message.thinkingContent != oldWidget.message.thinkingContent) {
      if (widget.message.isLoading && !widget.isReadOnly) {
        HapticService.onThinking(context);
      }
    }

    if (oldWidget.message.isEditing != widget.message.isEditing) {
      if (widget.message.isEditing) {
        _editController.text = widget.message.content;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _editFocusNode.requestFocus();
            _editController.selection = TextSelection.fromPosition(
                TextPosition(offset: _editController.text.length));
          }
        });
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
    final platform = Theme.of(context).platform;
    final isTouchDevice = platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.fuchsia;

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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: (!widget.isReadOnly &&
                          !widget.message.isEditing &&
                          !widget.message.isLoading &&
                          (_isHovering || isTouchDevice))
                      ? MessageActionBar(
                          key: ValueKey(widget.message.id),
                          message: widget.message,
                          onCopy: () => widget.onCopy(widget.message.videoUrl ??
                              widget.message.content),
                          onRegenerate: () =>
                              widget.onRegenerate(widget.message),
                          onEdit: () => widget.onEdit(widget.message, true),
                          onDelete: () => widget.onDelete(widget.message),
                          onRefresh: () => widget.onRefresh(widget.message),
                        )
                      : (appConfig.reserveActionSpace
                          ? const SizedBox(
                              key: ValueKey('reserved_space'), height: 34.0)
                          : const SizedBox.shrink(key: ValueKey('empty'))),
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

    final Widget content;

    if (appConfig.plainTextMode) {
      final textColor = isError
          ? Theme.of(context).colorScheme.error
          : isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface;
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.thinkingContent != null &&
                widget.message.thinkingContent!.isNotEmpty)
              ThinkingContentWidget(
                message: widget.message,
                textColor: textColor,
                isPlainText: true,
              ),
            if (widget.message.isEditing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildEditModeContent(context, textColor),
              )
            else
              _buildDisplayModeContent(context, textColor, appConfig),
          ],
        ),
      );
    } else {
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

      content = Card(
        color: bubbleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: !isUser && !isError && appConfig.distinguishAssistantBubble
              ? BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
                )
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.thinkingContent != null &&
                widget.message.thinkingContent!.isNotEmpty)
              ThinkingContentWidget(
                message: widget.message,
                textColor: textColor,
              ),
            if (widget.message.isEditing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildEditModeContent(context, textColor),
              )
            else
              _buildDisplayModeContent(context, textColor, appConfig),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * appConfig.chatBubbleWidth,
      ),
      child: RepaintBoundary(
        child: content,
      ),
    );
  }

  Widget _buildDisplayModeContent(
      BuildContext context, Color textColor, AppConfigProvider appConfig) {
    if (widget.message.messageType == MessageType.image) {
      return _buildImageContent(context, textColor);
    }
    if (widget.message.messageType == MessageType.video) {
      return _buildVideoContent(context, textColor);
    }
    return _buildTextContent(context, textColor, appConfig);
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
      return _buildTextContent(context, textColor,
          Provider.of<AppConfigProvider>(context, listen: false));
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
            HapticService.onButtonPress(context);
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
      return _buildTextContent(context, textColor,
          Provider.of<AppConfigProvider>(context, listen: false));
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
                  tooltip: localizations.playVideo,
                  onPressed: () {
                    HapticService.onButtonPress(context);
                    launchUrl(Uri.parse(message.videoUrl!));
                  },
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
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: textColor.withOpacity(0.7)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    localizations.videoExpirationWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildTextContent(context, textColor,
                Provider.of<AppConfigProvider>(context, listen: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildAsyncTaskStatus(
      BuildContext context, Color textColor, AppLocalizations localizations) {
    final message = widget.message;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
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
        return _buildTextContent(context, textColor, appConfig);
      default:
        statusText = localizations.taskStatus;
        statusIcon = Icons.info_outline;
    }

    final bool needsTimer = message.nextRefreshTime != null &&
        message.nextRefreshTime!.isAfter(DateTime.now()) &&
        appConfig.asyncTaskRefreshInterval > 0 &&
        !message.isLoading &&
        (message.asyncTaskStatus == AsyncTaskStatus.submitted ||
            message.asyncTaskStatus == AsyncTaskStatus.inProgress);

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
              else if (needsTimer)
                _CircularCountdownTimer(
                  nextRefreshTime: message.nextRefreshTime!,
                  totalDurationSeconds: appConfig.asyncTaskRefreshInterval,
                  onFinished: () {
                    if (mounted) {
                      widget.onRefresh(widget.message);
                    }
                  },
                  color: textColor,
                )
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(
      BuildContext context, Color textColor, AppConfigProvider appConfig) {
    final isUser = widget.message.role == 'user';
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

    Widget contentWidget;
    if (isUser) {
      contentWidget = SelectableText(
        widget.message.content,
        style: TextStyle(color: textColor, fontSize: fontSize, height: 1.4),
      );
    } else {
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

      contentWidget = SelectionArea(
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
            'code':
                MarkdownCodeBlockBuilder(context: context, isSelectable: false),
            'math_inline': MathBuilder(context: context, fontSize: fontSize),
            'math_display': MathBuilder(context: context, fontSize: fontSize),
            'hr': HrBuilder(context: context),
          },
          onTapLink: (text, href, title) {
            if (href != null) {
              HapticService.onButtonPress(context);
              launchUrl(Uri.parse(href));
            }
          },
        ),
      );
    }

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
                Expanded(child: contentWidget),
              ],
            )
          else
            contentWidget,
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
                onPressed: () {
                  HapticService.onButtonPress(context);
                  widget.onEdit(widget.message, false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: localizations.save,
                onPressed: () {
                  HapticService.onButtonPress(context);
                  widget.onSave(widget.message, _editController.text);
                },
              ),
              if (isUser)
                IconButton(
                  icon: const Icon(Icons.send_and_archive_outlined),
                  tooltip: localizations.saveAndResubmit,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    HapticService.onButtonPress(context);
                    widget.onResubmit(widget.message, _editController.text);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularCountdownTimer extends StatefulWidget {
  final DateTime nextRefreshTime;
  final int totalDurationSeconds;
  final VoidCallback onFinished;
  final Color color;

  const _CircularCountdownTimer({
    required this.nextRefreshTime,
    required this.totalDurationSeconds,
    required this.onFinished,
    required this.color,
  });

  @override
  State<_CircularCountdownTimer> createState() =>
      _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<_CircularCountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    if (!mounted) {
      _timer?.cancel();
      return;
    }
    final now = DateTime.now();
    final remaining = widget.nextRefreshTime.difference(now);

    if (remaining.isNegative) {
      setState(() {
        _remaining = Duration.zero;
      });
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFinished();
        }
      });
    } else {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalDurationSeconds > 0
        ? _remaining.inMilliseconds / (widget.totalDurationSeconds * 1000)
        : 0.0;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            color: widget.color,
            backgroundColor: widget.color.withOpacity(0.2),
          ),
          Center(
            child: Text(
              '${_remaining.inSeconds + 1}',
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
