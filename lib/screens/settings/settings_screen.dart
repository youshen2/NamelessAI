import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/export_options_sheet.dart';
import 'package:nameless_ai/screens/settings/widgets/import_confirmation_dialog.dart';
import 'package:nameless_ai/screens/settings/widgets/nameless_import_confirmation_dialog.dart';
import 'package:nameless_ai/services/backup_service.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/import_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final ImportService _importService = ImportService();
  bool _isWorking = false;

  Future<void> _exportData() async {
    HapticService.onButtonPress(context);
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final exportOptions = isDesktop
        ? await showDialog<Map<String, bool>>(
            context: context,
            builder: (context) => Dialog(
              child: SizedBox(
                width: 400,
                child: ExportOptionsSheet(isDialog: true),
              ),
            ),
          )
        : await showBlurredModalBottomSheet<Map<String, bool>>(
            context: context,
            isScrollControlled: true,
            builder: (context) => ExportOptionsSheet(),
          );

    if (exportOptions == null) return;

    setState(() => _isWorking = true);
    try {
      await _backupService.exportData(options: exportOptions);
      if (mounted) {
        showSnackBar(context, localizations.exportSuccess);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, localizations.exportError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _importFromNamelessAI() async {
    HapticService.onButtonPress(context);
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    setState(() => _isWorking = true);
    try {
      final backupData = await _backupService.pickAndParseFile();
      if (backupData == null) {
        if (mounted) setState(() => _isWorking = false);
        return;
      }

      if (mounted) {
        final result = isDesktop
            ? await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) =>
                    NamelessImportConfirmationDialog(backupData: backupData),
              )
            : await showBlurredModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (context) =>
                    NamelessImportConfirmationDialog(backupData: backupData),
              );

        if (result != null) {
          final mode = result['mode'] as ImportMode;
          final categories = result['categories'] as Set<String>;
          await _backupService.importNamelessData(backupData, mode, categories);

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text(localizations.importSuccess.split('.').first),
                content: Text(localizations.importSuccess),
                actions: [
                  FilledButton(
                    onPressed: () {
                      HapticService.onButtonPress(context);
                      Navigator.of(context).pop();
                    },
                    child: Text(localizations.ok),
                  )
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, localizations.importError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _importFromChatBox() async {
    HapticService.onButtonPress(context);
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    setState(() => _isWorking = true);
    try {
      final backupData = await _importService.pickAndParseChatBoxFile();
      if (backupData == null) {
        if (mounted) setState(() => _isWorking = false);
        return;
      }

      if (mounted) {
        final result = isDesktop
            ? await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) =>
                    ImportConfirmationDialog(backupData: backupData),
              )
            : await showBlurredModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (context) =>
                    ImportConfirmationDialog(backupData: backupData),
              );

        if (result != null) {
          final mode = result['mode'] as ImportMode;
          final categories = result['categories'] as Set<String>;
          await _importService.importFromChatBox(backupData, mode, categories);

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text(localizations.importSuccess.split('.').first),
                content: Text(localizations.importSuccess),
                actions: [
                  FilledButton(
                    onPressed: () {
                      HapticService.onButtonPress(context);
                      Navigator.of(context).pop();
                    },
                    child: Text(localizations.ok),
                  )
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, localizations.importError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.settings),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
                16,
                kToolbarHeight + MediaQuery.of(context).padding.top + 16,
                16,
                isDesktop ? 16 : 96),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apps),
                      title: Text(localizations.appSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/app');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: Text(localizations.generalSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/general');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(localizations.appearanceSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/appearance');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(localizations.appLock),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/app_lock');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(localizations.notificationSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/notifications');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.vibration),
                      title: Text(localizations.hapticSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/haptics');
                      },
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.api),
                      title: Text(localizations.apiProviderSettings),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/api_providers');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.library_books),
                      title: Text(localizations.systemPromptTemplates),
                      onTap: () {
                        HapticService.onButtonPress(context);
                        context.go('/settings/system_prompts');
                      },
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(localizations.exportData),
                      onTap: _isWorking ? null : _exportData,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_done_outlined),
                      title: Text(localizations
                          .importFrom(localizations.namelessAiSource)),
                      onTap: _isWorking ? null : _importFromNamelessAI,
                    ),
                    ListTile(
                      leading: const Icon(Icons.move_down_outlined),
                      title: Text(localizations
                          .importFrom(localizations.chatBoxSource)),
                      onTap: _isWorking ? null : _importFromChatBox,
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(localizations.about),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/about');
                  },
                ),
              ),
            ],
          ),
          if (_isWorking)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
