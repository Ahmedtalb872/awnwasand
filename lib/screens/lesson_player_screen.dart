import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../repositories/lessons_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'quiz_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _lessonsRepository = LessonsRepository();
  late Future<List<Lesson>> _siblingLessonsFuture;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _siblingLessonsFuture = _lessonsRepository.fetchAll(
      category: widget.lesson.category,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: Text(lesson.title)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(18, 4, 18, 0),
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Text(
                          lesson.durationLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        const Spacer(),
                        const Icon(Icons.volume_up, color: Colors.white, size: 18),
                        const SizedBox(width: 12),
                        const Icon(Icons.settings, color: Colors.white, size: 18),
                        const SizedBox(width: 12),
                        const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.navy,
              unselectedLabelColor: AppColors.textGray,
              indicatorColor: AppColors.navy,
              tabs: const [
                Tab(text: 'المحتوى'),
                Tab(text: 'الدروس'),
                Tab(text: 'الملاحظات'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ContentTab(lesson: lesson),
                  _SiblingLessonsTab(
                    future: _siblingLessonsFuture,
                    currentLessonId: lesson.id,
                  ),
                  _NotesTab(controller: _noteController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  const _ContentTab({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          lesson.title,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
        ),
        if (lesson.summary.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'ملخص الدرس',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.summary,
            style: const TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.7),
          ),
        ],
        if (lesson.quranText != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.quranText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14.5,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lesson.quranReference != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    lesson.quranReference!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textGray, fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (lesson.hasPdf)
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.navy),
            label: const Text(
              'تحميل ملف الدرس (PDF)',
              style: TextStyle(color: AppColors.navy),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'اختبار الدرس',
          color: AppColors.navy,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuizScreen(lessonId: lesson.id, lessonTitle: lesson.title),
            ),
          ),
        ),
      ],
    );
  }
}

class _SiblingLessonsTab extends StatelessWidget {
  const _SiblingLessonsTab({required this.future, required this.currentLessonId});

  final Future<List<Lesson>> future;
  final String currentLessonId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lesson>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('تعذّر تحميل الدروس', style: TextStyle(color: AppColors.textGray)),
          );
        }
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) {
          return const Center(
            child: Text('لا توجد دروس أخرى', style: TextStyle(color: AppColors.textGray)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: lessons.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final lesson = lessons[i];
            final isCurrent = lesson.id == currentLessonId;
            return Material(
              color: isCurrent ? AppColors.accentSoft : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                leading: Icon(
                  isCurrent ? Icons.play_circle_fill : Icons.play_circle_outline,
                  color: AppColors.navy,
                ),
                title: Text(
                  lesson.title,
                  style: const TextStyle(color: AppColors.navy, fontSize: 13.5),
                ),
                trailing: Text(
                  lesson.durationLabel,
                  style: const TextStyle(color: AppColors.textGray, fontSize: 11.5),
                ),
                onTap: isCurrent
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LessonPlayerScreen(lesson: lesson),
                          ),
                        ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'دوّن ملاحظاتك على هذا الدرس',
            style: TextStyle(color: AppColors.textGray, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 8,
            style: const TextStyle(color: AppColors.navy, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظة...',
              hintStyle: const TextStyle(color: AppColors.textGray),
              filled: true,
              fillColor: AppColors.cardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
