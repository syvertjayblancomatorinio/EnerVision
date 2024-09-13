import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showReusableActionSheet({
  required BuildContext context,
  required String title,
  required List<ActionSheetOption> options,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text(title),
      actions: options.map((option) {
        return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
            option.onPressed(); // Trigger the corresponding action
          },
          isDestructiveAction: option.isDestructiveAction,
          child: Text(option.label),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context); // Close the action sheet
        },
        child: const Text('Cancel'),
      ),
    ),
  );
}

class ActionSheetOption {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructiveAction;

  ActionSheetOption({
    required this.label,
    required this.onPressed,
    this.isDestructiveAction = false,
  });
}
