import 'package:flutter/material.dart';
import '../constants/colors.dart';

void showAppAlertDialog(BuildContext context, String title, String message,
    {Color? titleColor}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppColors.darkerBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
