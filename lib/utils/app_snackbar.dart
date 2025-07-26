import 'package:flutter/material.dart';
import '../constants/colors.dart';

void showAppSnackBar(BuildContext context, String message,
    {Color? backgroundColor, Color? textColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor ?? Colors.white),
      ),
      backgroundColor: backgroundColor ?? AppColors.navyBlue,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
