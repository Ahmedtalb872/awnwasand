import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// حقل نصي بمظهر موحّد، يدعم اللوحة الداكنة (تسجيل الدخول) والفاتحة (باقي الشاشات).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.dark = false,
    this.keyboardType,
    this.controller,
  });

  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool dark;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final fillColor = dark ? AppColors.panel : AppColors.cardLight;
    final textColor = dark ? AppColors.text : AppColors.navy;
    final hintColor = dark ? AppColors.textDim : AppColors.textGray;
    final borderColor = dark ? AppColors.line : AppColors.borderLight;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 13.5),
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}
