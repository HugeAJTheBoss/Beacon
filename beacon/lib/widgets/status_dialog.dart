import 'package:flutter/material.dart';

import '../app_theme.dart';

Future<void> showStatusDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool isError = false,
  double messageLineHeight = 1.45,
}) {
  final actionColor = isError ? AppColors.destructive : AppColors.primary;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      title: Text(title, style: AppTextStyles.dialogTitle),
      content: Text(
        message,
        style: TextStyle(color: AppColors.subtle, height: messageLineHeight),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const StadiumBorder(),
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
