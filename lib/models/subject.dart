import 'package:flutter/material.dart';

import '../utils/icon_lookup.dart';

/// مادة علمية ضمن منصة "المحجة البيضاء" (كالتفسير، الحديث، الفقه...)، تضم
/// عددًا من الدروس.
class Subject {
  const Subject({
    required this.title,
    required this.lessonCount,
    required this.category,
    required this.icon,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      title: map['title'] as String,
      lessonCount: map['lesson_count'] as int? ?? 0,
      category: map['category'] as String,
      icon: iconFromName(
        map['icon'] as String?,
        fallback: Icons.menu_book_outlined,
      ),
    );
  }

  final String title;
  final int lessonCount;
  final String category;
  final IconData icon;
}
