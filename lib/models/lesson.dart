import 'package:flutter/material.dart';

import '../utils/icon_lookup.dart';

/// درس ضمن برنامج "المحجة البيضاء" التعليمي.
class Lesson {
  const Lesson({
    required this.title,
    required this.lessonCount,
    required this.category,
    required this.icon,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
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
