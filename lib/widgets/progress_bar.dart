import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.progress, this.color});

  final double progress;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: 7,
        backgroundColor: AppColors.borderLight,
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.accent),
      ),
    );
  }
}
