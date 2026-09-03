import 'package:flutter/material.dart';

/// درس ضمن برنامج "المحجة البيضاء" التعليمي.
class Lesson {
  const Lesson({
    required this.title,
    required this.lessonCount,
    required this.category,
    required this.icon,
  });

  final String title;
  final int lessonCount;
  final String category;
  final IconData icon;
}
