import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF386BF6);
  static const Color gradientStart = Color(0xFFE6F4FD);
  static const Color gradientEnd = Color(0xFFF4EDFD);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color error = Colors.redAccent;
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}
