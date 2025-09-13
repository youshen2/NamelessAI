import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/widgets/responsive_layout.dart';
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

    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(
          context, localizations, errorInfo, copyInfo, submitIssue),
      desktopBody: _buildDesktopLayout(
          context, localizations, errorInfo, copyInfo, submitIssue),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      AppLocalizations localizations,
      String errorInfo,
      VoidCallback copyInfo,
      VoidCallback submitIssue) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.crashReport),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context, localizations),
          const SizedBox(height: 24),
          _buildErrorDetailsCard(context, localizations),
          const SizedBox(height: 16),
          _buildStackTraceCard(context, localizations),
          const SizedBox(height: 24),
          _buildSubmitIssueCard(context, localizations),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(
          context, localizations, copyInfo, submitIssue, onRestart),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      AppLocalizations localizations,
      String errorInfo,
      VoidCallback copyInfo,
      VoidCallback submitIssue) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.crashReport),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  _buildHeader(context, localizations),
                  const SizedBox(height: 24),
                  _buildErrorDetailsCard(context, localizations),
                  const SizedBox(height: 16),
                  _buildSubmitIssueCard(context, localizations),
                  const SizedBox(height: 24),
                  _buildBottomActions(
                      context, localizations, copyInfo, submitIssue, onRestart),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.stackTrace,
                          style: Theme.of(context).textTheme.titleMedium),
                      const Divider(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            stackTrace.toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Column(
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
      ],
    );
  }

  Widget _buildErrorDetailsCard(
      BuildContext context, AppLocalizations localizations) {
    return Card(
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
    );
  }

  Widget _buildStackTraceCard(
      BuildContext context, AppLocalizations localizations) {
    return Card(
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
    );
  }

  Widget _buildSubmitIssueCard(
      BuildContext context, AppLocalizations localizations) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          localizations.submitIssueDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context,
      AppLocalizations localizations,
      VoidCallback copyInfo,
      VoidCallback submitIssue,
      VoidCallback onRestart) {
    return Padding(
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
    );
  }
}
