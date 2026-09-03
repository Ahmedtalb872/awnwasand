import 'package:flutter/material.dart';

/// ألوان هوية جمعية عون وسند الخيرية.
///
/// `background`/`panel` (كحلي داكن) تُستخدم في شاشات الترحيب والدخول،
/// بينما بقية شاشات التطبيق تعتمد لوحة الألوان الفاتحة (`scaffoldLight` وما يليها).
class AppColors {
  AppColors._();

  // اللوحة الداكنة (شاشة البداية / تسجيل الدخول).
  static const background = Color(0xFF221D3F);
  static const panel = Color(0xFF2B2550);
  static const line = Color(0xFF3E3670);
  static const text = Color(0xFFF8F3EF);
  static const textDim = Color(0xFFCFC7DE);

  // لون العلامة التجارية المشترك بين اللوحتين.
  static const accent = Color(0xFFEC998C);
  static const accentSoft = Color(0xFFF6CDBE);

  static const ok = Color(0xFF3FAE71);
  static const fail = Color(0xFFE0645A);

  // اللوحة الفاتحة (بقية شاشات التطبيق).
  static const scaffoldLight = Color(0xFFFBF7F5);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFEFE6E2);
  static const navy = Color(0xFF221D3F);
  static const navySoft = Color(0xFF4A4470);
  static const textGray = Color(0xFF8E8AA0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        surface: AppColors.panel,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        surface: AppColors.cardLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldLight,
        foregroundColor: AppColors.navy,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navy,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textDim,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerColor: AppColors.borderLight,
    );
  }
}
