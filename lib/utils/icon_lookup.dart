import 'package:flutter/material.dart';

/// يحوّل اسم أيقونة نصي (كما يُخزَّن في Supabase) إلى [IconData] فعلية.
/// أضف إدخالًا هنا عند إضافة أيقونة جديدة من لوحة تحكم Supabase.
const Map<String, IconData> _icons = {
  'water_drop_outlined': Icons.water_drop_outlined,
  'food_bank_outlined': Icons.food_bank_outlined,
  'checkroom_outlined': Icons.checkroom_outlined,
  'menu_book_outlined': Icons.menu_book_outlined,
  'balance_outlined': Icons.balance_outlined,
  'auto_stories_outlined': Icons.auto_stories_outlined,
  'history_edu_outlined': Icons.history_edu_outlined,
  'import_contacts_outlined': Icons.import_contacts_outlined,
  'volunteer_activism': Icons.volunteer_activism,
  'volunteer_activism_outlined': Icons.volunteer_activism_outlined,
  'groups_outlined': Icons.groups_outlined,
  'school_outlined': Icons.school_outlined,
  'home_repair_service_outlined': Icons.home_repair_service_outlined,
};

IconData iconFromName(String? name, {IconData fallback = Icons.circle_outlined}) {
  if (name == null) return fallback;
  return _icons[name] ?? fallback;
}
