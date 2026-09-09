import 'package:flutter/material.dart';

/// ألوان هوية منصة "المحجة البيضاء" التعليمية (تابعة لجمعية عون وسند الخيرية).
///
/// لوحة كريمية هادئة، مع تيل (أخضر مزرق داكن) وذهبي كألوان علامة تجارية،
/// مطابقة لشعار المنصة وأخف على العين من الألوان الفاقعة.
class AppColors {
  AppColors._();

  static const scaffoldLight = Color(0xFFFBF6EC);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFEEE3CC);

  // لون العلامة التجارية الأساسي (تيل داكن) ولون ثانوي (ذهبي).
  static const navy = Color(0xFF0F5C48);
  static const navySoft = Color(0xFF4C8071);
  static const accent = Color(0xFFB8935A);
  static const accentSoft = Color(0xFFEFDFC0);

  static const textGray = Color(0xFF7C8580);

  static const ok = Color(0xFF3FAE71);
  static const fail = Color(0xFFC1443A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        brightness: Brightness.light,
        primary: AppColors.navy,
        secondary: AppColors.accent,
        surface: AppColors.cardLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldLight,
        foregroundColor: AppColors.navy,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textGray,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      dividerColor: AppColors.borderLight,
    );
  }
}
