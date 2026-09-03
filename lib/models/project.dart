import 'package:flutter/material.dart';

/// مشروع خيري تابع للجمعية (تمويل جماعي، مساعدات، إلخ).
class CharityProject {
  const CharityProject({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.collected,
    required this.goal,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final int collected;
  final int goal;

  double get progress => goal == 0 ? 0 : (collected / goal).clamp(0, 1);
  int get progressPercent => (progress * 100).round();
}
