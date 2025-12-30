// features/foucs_mode/views/widgets/stop_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:lockin/core/theme/colors.dart';

void showStopConfirmationDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surfaceDark,
        title: Row(
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              color: AppColors.warning,
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              'Really give up?',
              style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 22),
            ),
          ],
        ),
        content: Text(
          'You\'re doing great! The session is not over yet.\nAre you sure you want to stop?',
          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Keep Going',
              style: TextStyle(color: AppColors.secondaryLight, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              onConfirm();
            },
            child: const Text(
              'Stop Anyway',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
