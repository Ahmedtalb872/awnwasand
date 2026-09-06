import 'package:flutter/material.dart';

import '../utils/icon_lookup.dart';

/// مشروع خيري تابع للجمعية (تمويل جماعي، مساعدات، إلخ).
class CharityProject {
  const CharityProject({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.collected,
    required this.goal,
  });

  factory CharityProject.fromMap(Map<String, dynamic> map) {
    return CharityProject(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      category: map['category'] as String,
      icon: iconFromName(
        map['icon'] as String?,
        fallback: Icons.volunteer_activism_outlined,
      ),
      color: Color(map['color'] as int? ?? 0xFF5B9BD5),
      collected: map['collected'] as int? ?? 0,
      goal: map['goal'] as int,
    );
  }

  final String id;
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
