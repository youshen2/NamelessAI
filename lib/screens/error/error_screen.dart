import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRestart;

  const ErrorScreen({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final errorInfo = '''
${localizations.errorDetails}:
$error

${localizations.stackTrace}:
$stackTrace
''';

    void copyInfo() {
      Clipboard.setData(ClipboardData(text: errorInfo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.copiedToClipboard)),
      );
    }

    void submitIssue() {
      launchUrl(Uri.parse('https://github.com/youshen2/NamelessAI/issues/new'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.crashReport),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.anErrorOccurred,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.errorDetails,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              title: Text(localizations.stackTrace),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableText(
                    stackTrace.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                localizations.submitIssueDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(localizations.copyMessage),
                    onPressed: copyInfo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bug_report_outlined),
                    label: Text(localizations.submitIssue),
                    onPressed: submitIssue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: Text(localizations.restartApp),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
