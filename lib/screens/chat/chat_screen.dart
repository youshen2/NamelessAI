import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';
import 'package:nameless_ai/screens/chat/widgets/chat_settings_sheet.dart';
import 'package:nameless_ai/screens/chat/widgets/message_bubble.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late ChatSessionManager _chatSessionManager;

  String? _currentSessionId;
  bool _userScrolledUp = false;
  final double _scrollThreshold = 50.0;
  bool _showScrollUpButton = false;
  bool _showScrollPageUpButton = false;
  bool _showScrollDownButton = false;
  final Set<String> _animatedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadInitialChatState();
      _currentSessionId = _chatSessionManager.currentSession?.id;
      _chatSessionManager.addListener(_chatUpdateListener);
      _scrollController.addListener(_scrollListener);
    });
  }

  void _chatUpdateListener() {
    if (!mounted) return;

    final manager = Provider.of<ChatSessionManager>(context, listen: false);

    if (manager.currentSession?.id != _currentSessionId) {
      _animatedMessageIds.clear();
      _currentSessionId = manager.currentSession?.id;
      _userScrolledUp = false;
      setState(() {
        _showScrollUpButton = false;
        _showScrollPageUpButton = false;
        _showScrollDownButton = false;
      });
      if (manager.shouldScrollToBottomOnLoad) {
        _scrollToBottom(instant: true);
      } else {
        // When not scrolling on load, manually check button visibility after layout
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollListener();
          }
        });
      }
    }

    if (manager.isGenerating &&
        manager.currentSession?.id == _currentSessionId) {
      if (!_userScrolledUp) {
        _scrollToBottom();
      }
    }
  }

  void _scrollListener() {
    if (!mounted || !_scrollController.hasClients) return;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final position = _scrollController.position;

    if (appConfig.disableAutoScrollOnUp &&
        position.userScrollDirection == ScrollDirection.forward) {
      if (!_userScrolledUp) {
        setState(() {
          _userScrolledUp = true;
        });
      }
    }

    if (appConfig.resumeAutoScrollOnBottom &&
        position.pixels >= position.maxScrollExtent - _scrollThreshold) {
      if (_userScrolledUp) {
        setState(() {
          _userScrolledUp = false;
        });
      }
    }

    final shouldShowUp = position.pixels > MediaQuery.of(context).size.height;
    final shouldShowPageUp = position.pixels > 200;
    final shouldShowDown = position.pixels < position.maxScrollExtent - 200 &&
        position.maxScrollExtent > MediaQuery.of(context).size.height;

    if (shouldShowUp != _showScrollUpButton ||
        shouldShowPageUp != _showScrollPageUpButton ||
        shouldShowDown != _showScrollDownButton) {
      setState(() {
        _showScrollUpButton = shouldShowUp;
        _showScrollPageUpButton = shouldShowPageUp;
        _showScrollDownButton = shouldShowDown;
      });
    }
  }

  void _loadInitialChatState() {
    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);

    if (_chatSessionManager.currentSession == null) {
      _chatSessionManager.startNewSession(
        providerId: apiProviderManager.selectedProvider?.id,
        modelId: apiProviderManager.selectedModel?.id,
      );
    } else {
      final currentSession = _chatSessionManager.currentSession!;
      if (currentSession.providerId != null) {
        final provider = apiProviderManager.providers.firstWhere(
          (p) => p.id == currentSession.providerId,
          orElse: () => apiProviderManager.selectedProvider!,
        );
        apiProviderManager.setSelectedProvider(provider);
      }
      if (currentSession.modelId != null &&
          apiProviderManager.availableModels.isNotEmpty) {
        final model = apiProviderManager.availableModels.firstWhere(
          (m) => m.id == currentSession.modelId,
          orElse: () => apiProviderManager.selectedModel!,
        );
        apiProviderManager.setSelectedModel(model);
      }
    }
    if (mounted) {
      setState(() {});
    }
    if (_chatSessionManager.shouldScrollToBottomOnLoad) {
      _scrollToBottom(instant: true);
    } else {
      // When not scrolling on load, manually check button visibility after layout
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollListener();
        }
      });
    }
  }

  void _scrollToTop() {
    HapticService.onButtonPress(context);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollPageUp() {
    HapticService.onButtonPress(context);
    _scrollController.animateTo(
      (_scrollController.offset - _scrollController.position.viewportDimension)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToBottom({bool instant = false}) {
    if (_userScrolledUp && !instant) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients ||
          !_scrollController.position.hasContentDimensions) {
        return;
      }

      if (instant) {
        void jumpRepeatedly(int attempts) {
          if (attempts <= 0 || !mounted) return;

          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _scrollController.hasClients &&
                _scrollController.position.hasContentDimensions &&
                _scrollController.position.pixels <
                    _scrollController.position.maxScrollExtent) {
              jumpRepeatedly(attempts - 1);
            }
          });
        }

        jumpRepeatedly(5);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    HapticService.onButtonPress(context);
    final localizations = AppLocalizations.of(context)!;
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);

    final String messageText = _messageController.text.trim();
    if (messageText.isEmpty || chatSessionManager.isGenerating) return;

    final selectedProvider = apiProviderManager.selectedProvider;
    final selectedModel = apiProviderManager.selectedModel;

    if (selectedProvider == null || selectedModel == null) {
      showSnackBar(context, localizations.selectModel, isError: true);
      return;
    }

    if (chatSessionManager.isNewSession && appConfig.useFirstSentenceAsTitle) {
      const titleMaxLength = 25;
      String chatName = messageText.split('\n').first;
      if (chatName.length > titleMaxLength) {
        chatName = '${chatName.substring(0, titleMaxLength)}...';
      }
      await chatSessionManager.saveCurrentSession(chatName);
    }

    _messageController.clear();
    setState(() {
      _userScrolledUp = false;
    });
    await chatSessionManager.sendMessage(
        messageText, selectedProvider, selectedModel, localizations);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    if (chatSessionManager.isGenerating) return KeyEventResult.ignored;

    final sendKeyOption =
        Provider.of<AppConfigProvider>(context, listen: false).sendKeyOption;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      bool shouldSend = false;
      switch (sendKeyOption) {
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
          if (event.isControlPressed && event.isShiftPressed) {
            shouldSend = true;
          }
          break;
      }

      if (shouldSend) {
        _sendMessage();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _startNewChat() async {
    HapticService.onButtonPress(context);
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);

    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);
    chatSessionManager.startNewSession(
      providerId: apiProviderManager.selectedProvider?.id,
      modelId: apiProviderManager.selectedModel?.id,
    );
    _messageController.clear();
  }

  void _toggleEditing(String messageId, bool isEditing) {
    Provider.of<ChatSessionManager>(context, listen: false)
        .toggleMessageEditing(messageId, isEditing);
  }

  void _saveEditedMessage(ChatMessage message, String newContent) {
    Provider.of<ChatSessionManager>(context, listen: false)
        .updateMessageInCurrentSession(message.id, newContent);
  }

  void _resubmitMessage(ChatMessage message, String newContent) async {
    final localizations = AppLocalizations.of(context)!;
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);

    final selectedProvider = apiProviderManager.selectedProvider;
    final selectedModel = apiProviderManager.selectedModel;

    if (selectedProvider == null || selectedModel == null) {
      showSnackBar(context, localizations.selectModel, isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _userScrolledUp = false;
    });
    await chatSessionManager.resubmitMessage(
        message.id, newContent, selectedProvider, selectedModel, localizations);
  }

  void _regenerateResponse(ChatMessage message) async {
    final localizations = AppLocalizations.of(context)!;
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);

    final selectedProvider = apiProviderManager.selectedProvider;
    final selectedModel = apiProviderManager.selectedModel;

    if (selectedProvider == null || selectedModel == null) {
      showSnackBar(context, localizations.selectModel, isError: true);
      return;
    }

    setState(() {
      _userScrolledUp = false;
    });
    await chatSessionManager.regenerateResponse(
        message.id, selectedProvider, selectedModel, localizations);
  }

  void _refreshAsyncTask(ChatMessage message) async {
    HapticService.onButtonPress(context);
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    final apiProviderManager =
        Provider.of<APIProviderManager>(context, listen: false);

    final selectedProvider = apiProviderManager.selectedProvider;
    final selectedModel = apiProviderManager.selectedModel;

    if (selectedProvider == null || selectedModel == null) {
      return;
    }

    await chatSessionManager.refreshAsyncTaskStatus(
        message.id, selectedProvider, selectedModel);
  }

  void _deleteMessage(ChatMessage message) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(context, localizations.message);
    if (confirmed == true) {
      Provider.of<ChatSessionManager>(context, listen: false)
          .deleteMessageFromCurrentSession(message.id);
    }
  }

  void _onBranchChange(String aiMessageId, int newIndex) {
    HapticService.onButtonPress(context);
    Provider.of<ChatSessionManager>(context, listen: false)
        .switchActiveBranch(aiMessageId, newIndex);
  }

  void _showChatSettings() {
    HapticService.onButtonPress(context);
    final manager = Provider.of<ChatSessionManager>(context, listen: false);
    if (manager.currentSession != null) {
      showBlurredModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => ChatSettingsSheet(
            session: manager.currentSession!,
            onSave: (settings) {
              manager.updateCurrentSessionDetails(
                providerId: settings['providerId'],
                modelId: settings['modelId'],
                systemPrompt: settings['systemPrompt'],
                temperature: settings['temperature'],
                topP: settings['topP'],
                useStreaming: settings['useStreaming'],
                maxContextMessages: settings['maxContextMessages'],
                imageSize: settings['imageSize'],
                imageQuality: settings['imageQuality'],
                imageStyle: settings['imageStyle'],
              );
              final apiManager =
                  Provider.of<APIProviderManager>(context, listen: false);
              if (settings['providerId'] != null) {
                final provider = apiManager.providers
                    .firstWhere((p) => p.id == settings['providerId']);
                apiManager.setSelectedProvider(provider);
              }
              if (settings['modelId'] != null) {
                final model = apiManager.availableModels
                    .firstWhere((m) => m.id == settings['modelId']);
                apiManager.setSelectedModel(model);
              }
            },
            scrollController: scrollController,
          ),
        ),
      );
    }
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
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Consumer<ChatSessionManager>(
      builder: (context, manager, child) {
        final appConfig = Provider.of<AppConfigProvider>(context);
        final messages = manager.activeMessages;
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor:
                appConfig.enableBlurEffect ? Colors.transparent : null,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: _buildBlurBackground(context),
            title: GestureDetector(
              onTap: () {
                if (manager.currentSession != null &&
                    (manager.currentSession?.name.isNotEmpty ?? false)) {
                  HapticService.onButtonPress(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.chatName),
                      content: SelectableText(manager.currentSession!.name),
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
              },
              child: Text(
                manager.currentSession?.name ?? localizations.newChat,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              _buildAppBarModelSelector(localizations),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: localizations.newChat,
                onPressed: _startNewChat,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              if (messages.isEmpty && !manager.isGenerating)
                Center(
                  child: Text(localizations.noChatHistory),
                )
              else
                ListView.builder(
                  physics: isAndroid
                      ? const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics())
                      : null,
                  controller: _scrollController,
                  addAutomaticKeepAlives: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.only(
                      top: kToolbarHeight +
                          MediaQuery.of(context).padding.top +
                          8.0,
                      bottom: isDesktop ? 90.0 : 140.0),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final session = manager.currentSession;
                    int branchCount = 0;
                    int activeBranchIndex = 0;
                    String? aiMessageIdForBranching;

                    if (session != null &&
                        message.role == 'assistant' &&
                        index > 0 &&
                        messages[index - 1].role == 'user' &&
                        session.branches.containsKey(messages[index - 1].id)) {
                      aiMessageIdForBranching = messages[index - 1].id;
                      branchCount =
                          session.branches[aiMessageIdForBranching]!.length;
                      activeBranchIndex = session.activeBranchSelections[
                              aiMessageIdForBranching] ??
                          0;
                    }

                    return MessageBubble(
                      key: ValueKey(message.id),
                      message: message,
                      animatedMessageIds: _animatedMessageIds,
                      onEdit: (msg, isEditing) =>
                          _toggleEditing(msg.id, isEditing),
                      onSave: _saveEditedMessage,
                      onDelete: _deleteMessage,
                      onResubmit: _resubmitMessage,
                      onRegenerate: _regenerateResponse,
                      onRefresh: _refreshAsyncTask,
                      onCopy: (text) => copyToClipboard(context, text),
                      branchCount: branchCount,
                      activeBranchIndex: activeBranchIndex,
                      onBranchChange: (newIndex) {
                        if (aiMessageIdForBranching != null) {
                          _onBranchChange(aiMessageIdForBranching, newIndex);
                        }
                      },
                    );
                  },
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildInputArea(localizations, manager.isGenerating),
              ),
              Positioned(
                bottom: 110,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showScrollUpButton)
                      _buildScrollButton(
                        icon: Icons.vertical_align_top,
                        onPressed: _scrollToTop,
                        tooltip: localizations.scrollToTop,
                      ),
                    if (_showScrollPageUpButton)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildScrollButton(
                          icon: Icons.arrow_upward,
                          onPressed: _scrollPageUp,
                          tooltip: localizations.pageUp,
                        ),
                      ),
                    if (_showScrollDownButton)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildScrollButton(
                          icon: Icons.arrow_downward,
                          onPressed: () {
                            HapticService.onButtonPress(context);
                            setState(() {
                              _userScrolledUp = false;
                            });
                            _scrollToBottom(instant: true);
                          },
                          tooltip: localizations.scrollToBottom,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    final theme = Theme.of(context);

    final buttonContent = InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );

    Widget button;
    if (appConfig.enableBlurEffect) {
      button = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: theme.colorScheme.surfaceContainer.withOpacity(0.6),
            child: buttonContent,
          ),
        ),
      );
    } else {
      button = Material(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        child: buttonContent,
      );
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: button,
    );
  }

  Widget _buildInputArea(AppLocalizations localizations, bool isLoading) {
    final apiManager = Provider.of<APIProviderManager>(context, listen: false);
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final selectedModel = apiManager.selectedModel;
    final isMidjourney = selectedModel?.modelType == ModelType.image &&
        selectedModel?.imageGenerationMode == ImageGenerationMode.asynchronous;

    final inputContainer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: appConfig.enableBlurEffect
            ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
            : Theme.of(context).colorScheme.surface,
        border: Border(
            top: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.5))),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showChatSettings,
              tooltip: localizations.chatSettings,
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: isMidjourney
                      ? localizations.midjourneyPromptHint
                      : localizations.sendMessage,
                  border: Theme.of(context).inputDecorationTheme.border,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isLoading
                  ? _buildStopButton()
                  : _buildSendButton(localizations),
            ),
          ],
        ),
      ),
    );

    return Focus(
      focusNode: _inputFocusNode,
      onKey: _handleKeyEvent,
      child: appConfig.enableBlurEffect
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: inputContainer,
              ),
            )
          : inputContainer,
    );
  }

  Widget _buildStopButton() {
    return SizedBox(
      key: const ValueKey('stop_button'),
      width: 48,
      height: 48,
      child: FilledButton(
        onPressed: () {
          HapticService.onButtonPress(context);
          if (_chatSessionManager.currentSession != null) {
            _chatSessionManager
                .cancelGeneration(_chatSessionManager.currentSession!.id);
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: const Icon(Icons.stop),
      ),
    );
  }

  Widget _buildSendButton(AppLocalizations localizations) {
    return SizedBox(
      key: const ValueKey('send_button'),
      width: 48,
      height: 48,
      child: FilledButton(
        onPressed: _sendMessage,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget _buildAppBarModelSelector(AppLocalizations localizations) {
    final apiManager = Provider.of<APIProviderManager>(context);
    final providers = apiManager.providers;

    if (providers.isEmpty) {
      return TextButton.icon(
        onPressed: () {
          HapticService.onButtonPress(context);
          context.go('/settings/api_providers');
        },
        icon: const Icon(Icons.warning_amber_rounded),
        label: Text(localizations.addProvider),
      );
    }

    return PopupMenuButton<dynamic>(
      tooltip: localizations.modelSelection,
      onSelected: (value) {
        HapticService.onButtonPress(context);
        if (value is Model) {
          APIProvider? providerOfSelectedModel;
          for (var p in providers) {
            if (p.models.any((m) => m.id == value.id)) {
              providerOfSelectedModel = p;
              break;
            }
          }
          if (providerOfSelectedModel != null) {
            apiManager.setSelectedProvider(providerOfSelectedModel);
            apiManager.setSelectedModel(value);

            final chatManager =
                Provider.of<ChatSessionManager>(context, listen: false);
            if (chatManager.currentSession != null) {
              chatManager.updateCurrentSessionDetails(
                providerId: providerOfSelectedModel.id,
                modelId: value.id,
              );
            }
          }
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<dynamic>> items = [];
        for (var provider in providers) {
          items.add(PopupMenuItem(
            enabled: false,
            height: 32,
            child: Text(
              provider.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ));
          for (var model in provider.models) {
            final bool isSelected = apiManager.selectedModel?.id == model.id;
            items.add(PopupMenuItem(
              value: model,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(model.name)),
                ],
              ),
            ));
          }
          if (providers.indexOf(provider) < providers.length - 1) {
            items.add(const PopupMenuDivider());
          }
        }
        return items;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.model_training_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.2),
              child: Text(
                apiManager.selectedModel?.name ?? localizations.selectModel,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _inputFocusNode.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _chatSessionManager.removeListener(_chatUpdateListener);
    super.dispose();
  }
}
