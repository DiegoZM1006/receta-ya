import 'package:flutter/material.dart';
import 'package:receta_ya/core/constants/app_colors.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(suffixIcon, color: AppColors.grey),
                      onPressed: onSuffixIconPressed,
                    )
                  : null,
            ),
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}
