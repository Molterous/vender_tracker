import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showConfirmDeleteDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  String? title,
  String? content,
}) {

  final l10n = AppLocalizations.of(context)!;

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.deleteUser,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(l10n.confUserDeleteText),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            onConfirm(); // Trigger delete
          },
          child: Text(
            l10n.delete,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
