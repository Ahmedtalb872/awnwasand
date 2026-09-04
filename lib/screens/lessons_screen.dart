import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../repositories/lessons_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  static const _categories = ['الكل', 'العقيدة', 'الحديث', 'الفقه', 'السيرة'];
  final _lessonsRepository = LessonsRepository();
  late Future<List<Lesson>> _lessonsFuture;
  String _selected = 'الكل';

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _lessonsRepository.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: const Text('دروس المحجة')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = cat == _selected;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selected = cat),
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.cardLight,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.navy,
                      fontSize: 12.5,
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.accent : AppColors.borderLight,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Lesson>>(
                future: _lessonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'تعذّر تحميل الدروس',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    );
                  }
                  final all = snapshot.data ?? [];
                  final lessons = _selected == 'الكل'
                      ? all
                      : all.where((l) => l.category == _selected).toList();
                  if (lessons.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد دروس في هذه الفئة',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    itemCount: lessons.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final lesson = lessons[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(lesson.icon, color: AppColors.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: const TextStyle(
                                      color: AppColors.navy,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${lesson.lessonCount} درس',
                                    style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_left, color: AppColors.textGray),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: PrimaryButton(
                label: 'عرض جميع الدروس',
                color: AppColors.navy,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
