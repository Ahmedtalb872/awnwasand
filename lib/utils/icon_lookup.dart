import 'package:flutter/material.dart';

/// يحوّل اسم أيقونة نصي (كما يُخزَّن في Supabase) إلى [IconData] فعلية.
/// أضف إدخالًا هنا عند إضافة أيقونة جديدة من لوحة تحكم Supabase.
const Map<String, IconData> _icons = {
  'menu_book_outlined': Icons.menu_book_outlined,
  'menu_book': Icons.menu_book,
  'balance_outlined': Icons.balance_outlined,
  'auto_stories_outlined': Icons.auto_stories_outlined,
  'history_edu_outlined': Icons.history_edu_outlined,
  'import_contacts_outlined': Icons.import_contacts_outlined,
  'mosque_outlined': Icons.mosque_outlined,
  'family_restroom_outlined': Icons.family_restroom_outlined,
  'school_outlined': Icons.school_outlined,
  'quiz_outlined': Icons.quiz_outlined,
  'workspace_premium_outlined': Icons.workspace_premium_outlined,
  'favorite_outline': Icons.favorite_outline,
  'gavel_outlined': Icons.gavel_outlined,
};

IconData iconFromName(String? name, {IconData fallback = Icons.circle_outlined}) {
  if (name == null) return fallback;
  return _icons[name] ?? fallback;
}
