import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../repositories/subjects_repository.dart';
import '../theme/app_theme.dart';
import 'lessons_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _subjectsRepository = SubjectsRepository();
  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _subjectsRepository.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: const Text('المواد العلمية')),
      body: SafeArea(
        child: FutureBuilder<List<Subject>>(
          future: _subjectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'تعذّر تحميل المواد العلمية',
                  style: TextStyle(color: AppColors.textGray),
                ),
              );
            }
            final subjects = snapshot.data ?? [];
            if (subjects.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد مواد علمية بعد',
                  style: TextStyle(color: AppColors.textGray),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: subjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final subject = subjects[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonsScreen(
                        category: subject.category,
                        title: subject.title,
                      ),
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(subject.icon, color: AppColors.navy),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.title,
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${subject.lessonCount} دورة',
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
