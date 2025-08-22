import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  bool _showScrollUpFab = false;
  bool _showScrollDownFab = false;

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
    if (mounted) {
      final manager = Provider.of<ChatSessionManager>(context, listen: false);
      if (manager.isGenerating &&
          manager.currentSession?.id == _currentSessionId) {
        if (!_userScrolledUp) {
          _scrollToBottom();
        }
      }
    }
  }

  void _scrollListener() {
    if (!mounted) return;
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

    final shouldShowUp = position.pixels > 200;
    final shouldShowDown = position.pixels < position.maxScrollExtent - 200 &&
        position.maxScrollExtent > MediaQuery.of(context).size.height;

    if (shouldShowUp != _showScrollUpFab ||
        shouldShowDown != _showScrollDownFab) {
      setState(() {
        _showScrollUpFab = shouldShowUp;
        _showScrollDownFab = shouldShowDown;
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
    _scrollToBottom(instant: true);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToBottom({bool instant = false}) {
    if (_userScrolledUp && !instant) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (instant) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _sendMessage() async {
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
      String chatName = messageText.length > 40
          ? '${messageText.substring(0, 37)}...'
          : messageText;
      await chatSessionManager.saveCurrentSession(chatName);
    }

    _messageController.clear();
    setState(() {
      _userScrolledUp = false;
    });
    await chatSessionManager.sendMessage(
        messageText, selectedProvider, selectedModel);
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

  Future<void> _saveChat() async {
    final localizations = AppLocalizations.of(context)!;
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);
    if (chatSessionManager.currentSession == null ||
        chatSessionManager.currentSession!.messages.isEmpty) {
      showSnackBar(context, localizations.noChatHistory, isError: true);
      return;
    }

    final String? chatName = await showTextInputDialog(
      context,
      localizations.saveChat,
      localizations.chatName,
      initialValue:
          chatSessionManager.currentSession!.name.startsWith("New Chat")
              ? null
              : chatSessionManager.currentSession!.name,
    );

    if (chatName != null && chatName.isNotEmpty) {
      await chatSessionManager.saveCurrentSession(chatName);
      showSnackBar(context, localizations.chatSaved);
    }
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
        message.id, newContent, selectedProvider, selectedModel);
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
    Provider.of<ChatSessionManager>(context, listen: false)
        .switchActiveBranch(aiMessageId, newIndex);
  }

  void _showChatSettings() {
    final manager = Provider.of<ChatSessionManager>(context, listen: false);
    if (manager.currentSession != null) {
      showModalBottomSheet(
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<ChatSessionManager>(
      builder: (context, manager, child) {
        if (manager.currentSession?.id != _currentSessionId) {
          _currentSessionId = manager.currentSession?.id;
          _userScrolledUp = false;
          SchedulerBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom(instant: true));
        }

        final messages = manager.activeMessages;
        return Scaffold(
          appBar: AppBar(
            title: Text(manager.currentSession?.name ?? localizations.newChat),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: localizations.newChat,
                onPressed: _startNewChat,
              ),
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: localizations.saveChat,
                onPressed: _saveChat,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (messages.isEmpty && !manager.isGenerating) {
                          return Center(
                            child: Text(localizations.noChatHistory),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          itemCount: messages.length,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                session.branches
                                    .containsKey(messages[index - 1].id)) {
                              aiMessageIdForBranching = messages[index - 1].id;
                              branchCount = session
                                  .branches[aiMessageIdForBranching]!.length;
                              activeBranchIndex =
                                  session.activeBranchSelections[
                                          aiMessageIdForBranching] ??
                                      0;
                            }

                            return MessageBubble(
                              key: ValueKey(message.id),
                              message: message,
                              onEdit: (msg, isEditing) =>
                                  _toggleEditing(msg.id, isEditing),
                              onSave: _saveEditedMessage,
                              onDelete: _deleteMessage,
                              onResubmit: _resubmitMessage,
                              onRegenerate: _regenerateResponse,
                              onCopy: (text) => copyToClipboard(context, text),
                              branchCount: branchCount,
                              activeBranchIndex: activeBranchIndex,
                              onBranchChange: (newIndex) {
                                if (aiMessageIdForBranching != null) {
                                  _onBranchChange(
                                      aiMessageIdForBranching, newIndex);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildInputArea(localizations, manager.isGenerating),
                ],
              ),
              if (_showScrollUpFab)
                Positioned(
                  top: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _showScrollUpFab ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: FloatingActionButton.small(
                      onPressed: _scrollToTop,
                      tooltip: 'Scroll to top',
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              if (_showScrollDownFab)
                Positioned(
                  bottom: 90,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _showScrollDownFab ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: FloatingActionButton.small(
                      onPressed: () {
                        setState(() {
                          _userScrolledUp = false;
                        });
                        _scrollToBottom();
                      },
                      tooltip: 'Scroll to bottom',
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(AppLocalizations localizations, bool isLoading) {
    return Focus(
      focusNode: _inputFocusNode,
      onKey: _handleKeyEvent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5))),
        ),
        child: SafeArea(
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
                    hintText: localizations.sendMessage,
                    border: Theme.of(context).inputDecorationTheme.border,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isLoading
                      ? FilledButton(
                          key: const ValueKey('stop_button'),
                          onPressed: () {
                            if (_chatSessionManager.currentSession != null) {
                              _chatSessionManager.cancelGeneration(
                                  _chatSessionManager.currentSession!.id);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.onErrorContainer,
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.stop),
                        )
                      : FilledButton(
                          key: const ValueKey('send_button'),
                          onPressed: _sendMessage,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.send),
                        ),
                ),
              ),
            ],
          ),
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
