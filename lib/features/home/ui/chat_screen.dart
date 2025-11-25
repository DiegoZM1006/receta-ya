import 'package:flutter/material.dart';
import 'package:receta_ya/core/constants/app_colors.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Chat Screen',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
