import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../repositories/quiz_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_bar.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.lessonId, required this.lessonTitle});

  final String lessonId;
  final String lessonTitle;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _quizRepository = QuizRepository();
  late Future<List<QuizQuestion>> _questionsFuture;
  int _index = 0;
  final Map<int, int> _answers = {};

  @override
  void initState() {
    super.initState();
    _questionsFuture = _quizRepository.fetchForLesson(widget.lessonId);
  }

  void _finish(int total) {
    final correct = _answers.length;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نتيجتك'),
        content: Text('أجبت على $correct من $total أسئلة.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: Text('اختبار الدرس')),
      body: SafeArea(
        child: FutureBuilder<List<QuizQuestion>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'تعذّر تحميل الاختبار',
                  style: TextStyle(color: AppColors.textGray),
                ),
              );
            }
            final questions = snapshot.data ?? [];
            if (questions.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد اختبار لهذا الدرس بعد',
                  style: TextStyle(color: AppColors.textGray),
                ),
              );
            }
            final total = questions.length;
            final safeIndex = _index.clamp(0, total - 1);
            final question = questions[safeIndex];
            final selected = _answers[safeIndex];

            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'السؤال ${safeIndex + 1} من $total',
                    style: const TextStyle(color: AppColors.textGray, fontSize: 12.5),
                  ),
                  const SizedBox(height: 8),
                  AppProgressBar(
                    progress: (safeIndex + 1) / total,
                    color: AppColors.navy,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    question.question,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: question.options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final isSelected = selected == i;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _answers[safeIndex] = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentSoft
                                  : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.navy
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.navy
                                      : AppColors.textGray,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    question.options[i],
                                    style: const TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (safeIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _index = safeIndex - 1),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              side: const BorderSide(color: AppColors.borderLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'السابق',
                              style: TextStyle(color: AppColors.navy),
                            ),
                          ),
                        ),
                      if (safeIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: safeIndex == total - 1 ? 'إنهاء' : 'التالي',
                          color: AppColors.navy,
                          onPressed: () {
                            if (safeIndex == total - 1) {
                              _finish(total);
                            } else {
                              setState(() => _index = safeIndex + 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
