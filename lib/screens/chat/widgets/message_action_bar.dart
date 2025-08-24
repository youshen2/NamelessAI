import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/widgets/json_viewer.dart';

class MessageActionBar extends StatelessWidget {
  final ChatMessage message;
  final bool isHovering;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const MessageActionBar({
    super.key,
    required this.message,
    required this.isHovering,
    required this.onCopy,
    required this.onRegenerate,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  void _showDebugInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final messageJson = message.toJson();

    if (message.rawResponseJson != null) {
      try {
        final rawJson = jsonDecode(message.rawResponseJson!);
        messageJson[localizations.rawResponse] = rawJson;
      } catch (e) {
        messageJson[localizations.rawResponse] = message.rawResponseJson;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.debugInfo),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: JsonViewer(json: messageJson),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String tooltip,
      VoidCallback onPressed, bool isCompact) {
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final platform = Theme.of(context).platform;
    final isTouchDevice = platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.fuchsia;
    final isUser = message.role == 'user';
    final isAiMedia = message.role == 'assistant' &&
        (message.messageType == MessageType.image ||
            message.messageType == MessageType.video);
    final isAsyncTask = isAiMedia && message.taskId != null;
    final isTaskFinished = message.asyncTaskStatus == AsyncTaskStatus.success ||
        message.asyncTaskStatus == AsyncTaskStatus.failure;

    return AnimatedOpacity(
      opacity: isHovering || isTouchDevice ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, right: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAsyncTask || isTaskFinished)
              _actionButton(context, Icons.copy_all_outlined,
                  localizations.copyMessage, onCopy, appConfig.compactMode),
            if (!isUser)
              _actionButton(
                  context,
                  Icons.refresh,
                  localizations.regenerateResponse,
                  onRegenerate,
                  appConfig.compactMode),
            if (isAsyncTask && !isTaskFinished)
              _actionButton(context, Icons.sync, localizations.refresh,
                  onRefresh, appConfig.compactMode),
            if (!isAiMedia)
              _actionButton(context, Icons.edit_outlined,
                  localizations.editMessage, onEdit, appConfig.compactMode),
            _actionButton(context, Icons.delete_outline,
                localizations.deleteMessage, onDelete, appConfig.compactMode),
            if (appConfig.showDebugButton)
              _actionButton(
                  context,
                  Icons.bug_report_outlined,
                  localizations.debugInfo,
                  () => _showDebugInfo(context),
                  appConfig.compactMode),
          ],
        ),
      ),
    );
  }
}
