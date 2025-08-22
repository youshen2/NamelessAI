import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/message_bubble.dart';
import 'package:nameless_ai/utils/helpers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ChatSession? _selectedSessionForPreview;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Future<List<ChatMessage>>? _previewMessagesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatSessionManager =
          Provider.of<ChatSessionManager>(context, listen: false);
      if (chatSessionManager.currentSession != null &&
          !chatSessionManager.isNewSession) {
        final initialSession = AppDatabase.chatSessionsBox
            .get(chatSessionManager.currentSession!.id);
        if (initialSession != null) {
          _selectSessionForPreview(initialSession);
        }
      }
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSessionForPreview(ChatSession session) {
    if (!mounted) return;
    setState(() {
      _selectedSessionForPreview = session;
      _previewMessagesFuture = Future(() => session.activeMessages);
    });
  }

  Future<void> _editSessionName(
      ChatSession session, AppLocalizations localizations) async {
    final manager = Provider.of<ChatSessionManager>(context, listen: false);
    final newName = await showTextInputDialog(
      context,
      localizations.editChatName,
      localizations.chatName,
      initialValue: session.name,
    );

    if (newName != null && newName.isNotEmpty) {
      await manager.renameSession(session.id, newName);
      if (mounted) {
        showSnackBar(context, localizations.chatSaved);
      }
      if (_selectedSessionForPreview?.id == session.id) {
        final freshSession = AppDatabase.chatSessionsBox.get(session.id);
        if (freshSession != null) {
          _selectSessionForPreview(freshSession);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.history),
      ),
      body: Consumer<ChatSessionManager>(
        builder: (context, manager, child) {
          if (manager.sessions.isEmpty) {
            return Center(
              child: Text(localizations.noChatHistory),
            );
          }

          final filteredSessions = manager.sessions.where((session) {
            if (_searchQuery.isEmpty) return true;
            final nameMatch = session.name.toLowerCase().contains(_searchQuery);
            final contentMatch = session.messages
                .any((msg) => msg.content.toLowerCase().contains(_searchQuery));
            return nameMatch || contentMatch;
          }).toList();

          if (isDesktop) {
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      _buildSearchBar(localizations),
                      Expanded(
                        child:
                            _buildSessionList(filteredSessions, localizations),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withOpacity(0.5)),
                Expanded(
                  child: _buildSessionPreview(localizations),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSearchBar(localizations),
                Expanded(
                    child: _buildSessionList(filteredSessions, localizations)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "${localizations.search}...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSessionList(
      List<ChatSession> sessions, AppLocalizations localizations) {
    if (sessions.isEmpty) {
      return Center(child: Text(localizations.noResultsFound));
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isSelected = _selectedSessionForPreview?.id == session.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          child: ListTile(
            title: Text(session.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              session.messages.isNotEmpty
                  ? session.messages.last.content
                  : localizations.noChatHistory,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: localizations.editChatName,
                  onPressed: () => _editSessionName(session, localizations),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  tooltip: localizations.delete,
                  onPressed: () async {
                    final confirmed =
                        await showConfirmDialog(context, localizations.chat);
                    if (confirmed == true) {
                      final manager = Provider.of<ChatSessionManager>(context,
                          listen: false);
                      await manager.deleteSession(session.id);
                      if (mounted) {
                        showSnackBar(
                            context, '${localizations.delete} ${session.name}');
                      }
                      if (_selectedSessionForPreview?.id == session.id) {
                        setState(() {
                          _selectedSessionForPreview = null;
                          _previewMessagesFuture = null;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              final freshSession = AppDatabase.chatSessionsBox.get(session.id);
              if (freshSession != null) {
                _selectSessionForPreview(freshSession);
              }
              if (MediaQuery.of(context).size.width < 600) {
                Provider.of<ChatSessionManager>(context, listen: false)
                    .loadSession(session.id);
                context.go('/');
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionPreview(AppLocalizations localizations) {
    if (_selectedSessionForPreview == null) {
      return Center(
        child: Text(localizations.noChatHistory),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedSessionForPreview!.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${localizations.systemPrompt}: ${_selectedSessionForPreview!.systemPrompt ?? localizations.noSystemPromptTemplates}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    Provider.of<ChatSessionManager>(context, listen: false)
                        .loadSession(_selectedSessionForPreview!.id);
                    context.go('/');
                  },
                  icon: const Icon(Icons.chat),
                  label: Text(localizations.chat),
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        Expanded(
          child: FutureBuilder<List<ChatMessage>>(
            future: _previewMessagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('${localizations.error}: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(localizations.noChatHistory));
              }

              final messages = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return MessageBubble(
                    message: message,
                    isReadOnly: true,
                    onEdit: (_, __) {},
                    onSave: (_, __) {},
                    onDelete: (_) {},
                    onResubmit: (_, __) {},
                    onRegenerate: (_) {},
                    onCopy: (_) {},
                    activeBranchIndex: 0,
                    onBranchChange: (_) {},
                    animatedMessageIds: const {},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
