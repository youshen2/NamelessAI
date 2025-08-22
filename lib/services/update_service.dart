import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';

class UpdateService {
  final Dio _dio = Dio();
  static const String _repoUrl =
      'https://api.github.com/repos/youshen2/NamelessAI/releases/latest';

  Future<void> check(BuildContext context,
      {bool showNoUpdateDialog = false}) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final response = await _dio.get(_repoUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersionStr =
            (data['tag_name'] as String).replaceAll('v', '');
        final releaseUrl = data['html_url'] as String;
        final releaseNotes = data['body'] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersionStr = packageInfo.version;

        if (_isNewer(latestVersionStr, currentVersionStr)) {
          if (context.mounted) {
            _showUpdateDialog(
                context, latestVersionStr, releaseUrl, releaseNotes);
          }
        } else if (showNoUpdateDialog) {
          if (context.mounted) {
            _showNoUpdateDialog(context);
          }
        }
      }
    } catch (e) {
      if (showNoUpdateDialog && context.mounted) {
        showSnackBar(context, localizations.updateCheckFailed(e.toString()),
            isError: true);
      }
    }
  }

  bool _isNewer(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < newParts.length; i++) {
        if (i >= currentParts.length) {
          return true;
        }
        if (newParts[i] > currentParts[i]) {
          return true;
        }
        if (newParts[i] < currentParts[i]) {
          return false;
        }
      }
      return false;
    } catch (e) {
      return newVersion.compareTo(currentVersion) > 0;
    }
  }

  void _showUpdateDialog(
      BuildContext context, String version, String url, String notes) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.updateAvailable(version)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(localizations.newVersionMessage),
                const SizedBox(height: 16),
                Text(localizations.releaseNotes,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                MarkdownBody(
                  data: notes,
                  selectable: true,
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrl(Uri.parse(href));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.later),
          ),
          FilledButton(
            onPressed: () {
              launchUrl(Uri.parse(url));
              Navigator.of(context).pop();
            },
            child: Text(localizations.update),
          ),
        ],
      ),
    );
  }

  void _showNoUpdateDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.noUpdates),
        content: Text(localizations.latestVersionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
