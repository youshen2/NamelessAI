import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class MessageMetaInfo extends StatelessWidget {
  final ChatMessage message;
  final CrossAxisAlignment alignment;

  const MessageMetaInfo({
    super.key,
    required this.message,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
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
        message.modelName != null &&
        message.role == 'assistant';
    final showTime = appConfig.showTimestamps;

    final meta = <Widget>[];

    if (showName) {
      meta.add(_MetaItem(
        label: '${localizations.modelLabel}: ',
        value: message.modelName!,
        isCompact: appConfig.compactMode,
      ));
    }
    if (showTime) {
      meta.add(_MetaItem(
        label: '${localizations.timeLabel}: ',
        value:
            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
        isCompact: appConfig.compactMode,
      ));
    }

    return meta;
  }

  List<Widget> _buildPerformanceStats(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (message.role != 'assistant' || message.isError) {
      return [];
    }

    final localizations = AppLocalizations.of(context)!;
    final stats = <Widget>[];

    if (appConfig.showTotalTime && message.completionTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.totalTime,
          value: '${(message.completionTimeMs! / 1000).toStringAsFixed(2)}s',
          isCompact: appConfig.compactMode));
    }
    if (appConfig.showFirstChunkTime && message.firstChunkTimeMs != null) {
      stats.add(_StatItem(
          label: localizations.firstChunkTime,
          value: '${(message.firstChunkTimeMs! / 1000).toStringAsFixed(2)}s',
          isCompact: appConfig.compactMode));
    }
    if (appConfig.showOutputCharacters && message.outputCharacters != null) {
      stats.add(_StatItem(
          label: localizations.outputCharacters,
          value: message.outputCharacters.toString(),
          isCompact: appConfig.compactMode));
    }

    return stats;
  }

  List<Widget> _buildTokenStats(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (message.role != 'assistant' ||
        message.isError ||
        !appConfig.showTokenUsage) {
      return [];
    }

    final localizations = AppLocalizations.of(context)!;
    final stats = <Widget>[];

    if (message.promptTokens != null || message.completionTokens != null) {
      final prompt = message.promptTokens?.toString() ?? '-';
      final completion = message.completionTokens?.toString() ?? '-';
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
