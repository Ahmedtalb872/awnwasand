import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../repositories/lessons_repository.dart';
import '../theme/app_theme.dart';
import 'lesson_player_screen.dart';

/// دروس مادة علمية واحدة (كالتفسير أو الحديث)، أو كل الدروس عندما لا تُحدَّد
/// مادة (تُستخدم لتبويب "دروسي").
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, this.category, this.title});

  final String? category;
  final String? title;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _lessonsRepository = LessonsRepository();
  late Future<List<Lesson>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _lessonsRepository.fetchAll(category: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: Text(widget.title ?? widget.category ?? 'دروسي')),
      body: SafeArea(
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
            final lessons = snapshot.data ?? [];
            if (lessons.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد دروس في هذه المادة بعد',
                  style: TextStyle(color: AppColors.textGray),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: lessons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final lesson = lessons[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonPlayerScreen(lesson: lesson),
                    ),
                  ),
                  child: Container(
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
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white),
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
                                lesson.durationLabel,
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
