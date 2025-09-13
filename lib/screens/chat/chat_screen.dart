import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
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
  final TextEditingController _historySearchController =
      TextEditingController();
  String _historySearchQuery = '';

  String? _currentSessionId;
  bool _userScrolledUp = false;
  final double _scrollThreshold = 50.0;
  bool _showScrollUpButton = false;
  bool _showScrollPageUpButton = false;
  bool _showScrollDownButton = false;
  final Set<String> _animatedMessageIds = {};
  bool _isMultiSelectMode = false;
  final Set<String> _selectedMessageIds = {};

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
      _historySearchController.addListener(() {
        if (mounted) {
          setState(() {
            _historySearchQuery = _historySearchController.text.toLowerCase();
          });
        }
      });
    });
  }

  void _enterMultiSelectMode(String messageId) {
    HapticService.onLongPress(context);
    setState(() {
      _isMultiSelectMode = true;
      _selectedMessageIds.add(messageId);
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedMessageIds.clear();
    });
  }

  void _toggleSelection(String messageId) {
    HapticService.onButtonPress(context);
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _selectAllMessages() {
    HapticService.onButtonPress(context);
    setState(() {
      final allMessageIds =
          _chatSessionManager.activeMessages.map((m) => m.id).toSet();
      if (_selectedMessageIds.length == allMessageIds.length) {
        _selectedMessageIds.clear();
        _isMultiSelectMode = false;
      } else {
        _selectedMessageIds.addAll(allMessageIds);
      }
    });
  }

  Future<void> _deleteSelectedMessages() async {
    HapticService.onButtonPress(context);
    final localizations = AppLocalizations.of(context)!;
    final count = _selectedMessageIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteSelected),
        content: Text(localizations.deleteMultipleConfirmation(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _chatSessionManager.deleteMultipleMessagesFromCurrentSession(
          _selectedMessageIds.toList());
      _exitMultiSelectMode();
    }
  }

  void _chatUpdateListener() {
    if (!mounted) return;

    final manager = Provider.of<ChatSessionManager>(context, listen: false);

    if (manager.currentSession?.id != _currentSessionId) {
      _animatedMessageIds.clear();
      _currentSessionId = manager.currentSession?.id;
      _userScrolledUp = false;
      _exitMultiSelectMode();
      setState(() {
        _showScrollUpButton = false;
        _showScrollPageUpButton = false;
        _showScrollDownButton = false;
      });
      if (manager.shouldScrollToBottomOnLoad) {
        _scrollToBottom(instant: true);
      } else {
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
    if (!mounted ||
        !_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions) return;
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    if (manager.currentSession != null) {
      void onSave(Map<String, dynamic> settings) {
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
      }

      if (isDesktop) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 450,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: ChatSettingsSheet(
                isDialog: true,
                session: manager.currentSession!,
                onSave: onSave,
                scrollController: ScrollController(),
              ),
            ),
          ),
        );
      } else {
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
              onSave: onSave,
              scrollController: scrollController,
            ),
          ),
        );
      }
    }
  }

  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = context.watch<AppConfigProvider>();
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = context.watch<AppConfigProvider>();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _isMultiSelectMode
          ? _buildMultiSelectAppBar(context, localizations)
          : _buildAppBar(context, localizations),
      body: Stack(
        children: [
          _buildChatList(localizations, false),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Selector<ChatSessionManager, bool>(
                selector: (_, manager) => manager.isGenerating,
                builder: (context, isGenerating, _) {
                  return _buildInputArea(localizations, isGenerating,
                      isDesktop: false);
                }),
          ),
          Positioned(
            bottom: appConfig.scrollButtonBottomOffset,
            right: appConfig.scrollButtonRightOffset,
            child: _buildScrollButtons(localizations, appConfig),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = context.watch<AppConfigProvider>();
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopHistoryPanel(localizations),
          VerticalDivider(
              thickness: 1,
              width: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.5)),
          Expanded(
            child: Column(
              children: [
                _isMultiSelectMode
                    ? _buildMultiSelectAppBar(context, localizations,
                        isDesktop: true)
                    : _buildAppBar(context, localizations, isDesktop: true),
                Expanded(
                  child: Stack(
                    children: [
                      _buildChatList(localizations, true),
                      Positioned(
                        bottom: 20.0,
                        right: appConfig.scrollButtonRightOffset,
                        child: _buildScrollButtons(localizations, appConfig),
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Selector<ChatSessionManager, bool>(
                      selector: (_, manager) => manager.isGenerating,
                      builder: (context, isGenerating, _) {
                        return _buildInputArea(localizations, isGenerating,
                            isDesktop: true);
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHistoryPanel(AppLocalizations localizations) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: 240,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(localizations.history,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: localizations.newChat,
                    onPressed: _startNewChat,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _historySearchController,
                decoration: InputDecoration(
                  hintText: localizations.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _historySearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            HapticService.onButtonPress(context);
                            _historySearchController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Consumer<ChatSessionManager>(
                  builder: (context, manager, child) {
                if (manager.sessions.isEmpty) {
                  return Center(
                    child: Text(localizations.noChatHistory),
                  );
                }

                final filteredSessions = manager.sessions.where((session) {
                  if (_historySearchQuery.isEmpty) return true;
                  final nameMatch =
                      session.name.toLowerCase().contains(_historySearchQuery);
                  final contentMatch = session.messages.any((msg) =>
                      msg.content.toLowerCase().contains(_historySearchQuery));
                  return nameMatch || contentMatch;
                }).toList();

                if (filteredSessions.isEmpty) {
                  return Center(child: Text(localizations.noResultsFound));
                }

                return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      final isSelected =
                          manager.currentSession?.id == session.id;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                        child: ListTile(
                          title: Text(session.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${localizations.timeLabel}: ${session.updatedAt.toLocal().toString().substring(0, 16)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            HapticService.onButtonPress(context);
                            _chatSessionManager.loadSession(session.id);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    });
              }),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations localizations,
      {bool isDesktop = false}) {
    final appConfig = context.watch<AppConfigProvider>();
    return AppBar(
      backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: _buildBlurBackground(context),
      title: Selector<ChatSessionManager, (String, String?)>(
        selector: (_, manager) =>
            (manager.currentSession?.name ?? '', manager.currentSession?.id),
        builder: (context, sessionData, _) {
          final sessionName = sessionData.$1;
          final sessionId = sessionData.$2;
          return GestureDetector(
            onTap: () {
              if (sessionId != null && sessionName.isNotEmpty) {
                HapticService.onButtonPress(context);
                final manager =
                    Provider.of<ChatSessionManager>(context, listen: false);
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
              sessionName.isNotEmpty ? sessionName : localizations.newChat,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      actions: [
        if (!isDesktop)
          Consumer<APIProviderManager>(builder: (context, apiManager, _) {
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
            return _buildModelSelectorMenu(localizations, apiManager, providers,
                isDesktop: false);
          }),
        if (!isDesktop)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: localizations.newChat,
            onPressed: _startNewChat,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar(
      BuildContext context, AppLocalizations localizations,
      {bool isDesktop = false}) {
    final appConfig = context.watch<AppConfigProvider>();
    return AppBar(
      backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: _buildBlurBackground(context),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitMultiSelectMode,
      ),
      title: Text(localizations.itemsSelected(_selectedMessageIds.length)),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: localizations.selectAll,
          onPressed: _selectAllMessages,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: localizations.deleteSelected,
          onPressed: _deleteSelectedMessages,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatList(AppLocalizations localizations, bool isDesktop) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    return Selector<ChatSessionManager, (List<ChatMessage>, bool)>(
      selector: (_, m) => (m.activeMessages, m.isGenerating),
      builder: (context, data, _) {
        final messages = data.$1;
        final isGenerating = data.$2;
        if (messages.isEmpty && !isGenerating) {
          return Center(
            child: Text(localizations.noChatHistory),
          );
        }

        return ListView.builder(
          physics: isAndroid
              ? const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics())
              : null,
          controller: _scrollController,
          itemCount: messages.length,
          padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8.0,
              bottom: isDesktop ? 8.0 : 140.0),
          itemBuilder: (context, index) {
            final message = messages[index];
            final isSelected = _selectedMessageIds.contains(message.id);
            final manager =
                Provider.of<ChatSessionManager>(context, listen: false);
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
              branchCount = session.branches[aiMessageIdForBranching]!.length;
              activeBranchIndex =
                  session.activeBranchSelections[aiMessageIdForBranching] ?? 0;
            }

            return GestureDetector(
              onLongPress: () => _enterMultiSelectMode(message.id),
              onTap: _isMultiSelectMode
                  ? () => _toggleSelection(message.id)
                  : null,
              child: MessageBubble(
                key: ValueKey(message.id),
                message: message,
                animatedMessageIds: _animatedMessageIds,
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
                isSelected: isSelected,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScrollButtons(
      AppLocalizations localizations, AppConfigProvider appConfig) {
    return Column(
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

  Widget _buildInputArea(AppLocalizations localizations, bool isLoading,
      {required bool isDesktop}) {
    if (isDesktop) {
      return _buildDesktopInputArea(localizations, isLoading);
    }
    return _buildMobileInputArea(localizations, isLoading);
  }

  Widget _buildMobileInputArea(AppLocalizations localizations, bool isLoading) {
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

  Widget _buildDesktopInputArea(
      AppLocalizations localizations, bool isLoading) {
    final apiManager = Provider.of<APIProviderManager>(context, listen: false);
    final selectedModel = apiManager.selectedModel;
    final isMidjourney = selectedModel?.modelType == ModelType.image &&
        selectedModel?.imageGenerationMode == ImageGenerationMode.asynchronous;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: Focus(
                focusNode: _inputFocusNode,
                onKey: _handleKeyEvent,
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: isMidjourney
                        ? localizations.midjourneyPromptHint
                        : localizations.sendMessage,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: _showChatSettings,
                      tooltip: localizations.chatSettings,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Consumer<APIProviderManager>(
                        builder: (context, apiManager, _) {
                      final providers = apiManager.providers;
                      if (providers.isEmpty) {
                        return TextButton(
                          onPressed: () {
                            HapticService.onButtonPress(context);
                            context.go('/settings/api_providers');
                          },
                          child: Text(localizations.addProvider),
                        );
                      }
                      return _buildModelSelectorMenu(
                          localizations, apiManager, providers,
                          isDesktop: true);
                    }),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: isLoading
                          ? IconButton(
                              key: const ValueKey('stop_button_desktop'),
                              icon: const Icon(Icons.stop),
                              tooltip: localizations.stopGenerating,
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                if (_chatSessionManager.currentSession !=
                                    null) {
                                  _chatSessionManager.cancelGeneration(
                                      _chatSessionManager.currentSession!.id);
                                }
                              },
                              color: Theme.of(context).colorScheme.error,
                            )
                          : IconButton(
                              key: const ValueKey('send_button_desktop'),
                              icon: const Icon(Icons.send),
                              tooltip: localizations.sendMessage,
                              onPressed: _sendMessage,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
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

  Widget _buildModelSelectorMenu(AppLocalizations localizations,
      APIProviderManager apiManager, List<APIProvider> providers,
      {bool isDesktop = false}) {
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
      child: isDesktop
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    apiManager.selectedModel?.name ?? localizations.selectModel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            )
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
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
                      apiManager.selectedModel?.name ??
                          localizations.selectModel,
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
    _historySearchController.dispose();
    super.dispose();
  }
}
