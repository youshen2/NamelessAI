import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () {
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
    showSnackBar(context, AppLocalizations.of(context)!.copiedToClipboard);
  });
}
