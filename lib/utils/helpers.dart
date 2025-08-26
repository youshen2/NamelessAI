import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).snackBarTheme.backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<bool?> showConfirmDialog(BuildContext context, String itemType) async {
  final localizations = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.confirmDelete),
      content: Text(localizations.deleteConfirmation(itemType)),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            Navigator.of(context).pop(false);
          },
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(localizations.delete),
        ),
      ],
    ),
  );
}

Future<String?> showTextInputDialog(
    BuildContext context, String title, String label,
    {String? initialValue}) async {
  final TextEditingController controller =
      TextEditingController(text: initialValue);
  final localizations = AppLocalizations.of(context)!;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            Navigator.of(context).pop();
          },
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            if (controller.text.trim().isNotEmpty) {
              Navigator.of(context).pop(controller.text.trim());
            } else {
              showSnackBar(context, localizations.chatNameRequired,
                  isError: true);
            }
          },
          child: Text(localizations.save),
        ),
      ],
    ),
  );
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text)).then((_) {
    HapticService.onButtonPress(context);
    showSnackBar(context, AppLocalizations.of(context)!.copiedToClipboard);
  });
}

Future<T?> showBlurredModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
  final cornerRadius = appConfig.cornerRadius;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
    builder: (context) {
      Widget content = builder(context);

      if (appConfig.enableBlurEffect) {
        return ClipRRect(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(cornerRadius)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Theme.of(context)
                  .bottomSheetTheme
                  .backgroundColor
                  ?.withOpacity(0.88),
              child: content,
            ),
          ),
        );
      } else {
        return content;
      }
    },
  );
}
