import 'package:flutter/material.dart';
import 'package:receta_ya/core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: child,
    );
  }
}
