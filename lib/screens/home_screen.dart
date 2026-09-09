import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../repositories/auth_repository.dart';
import '../repositories/lessons_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import 'lesson_player_screen.dart';
import 'lessons_screen.dart';
import 'login_screen.dart';
import 'root_shell.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _lessonsRepository = LessonsRepository();
  late Future<List<Lesson>> _latestLessonsFuture;

  static const _quickCategories = [
    (Icons.family_restroom_outlined, 'أحكام الأسرة'),
    (Icons.favorite_outline, 'العقيدة'),
    (Icons.import_contacts_outlined, 'الحديث'),
    (Icons.auto_stories_outlined, 'التفسير'),
  ];

  @override
  void initState() {
    super.initState();
    _latestLessonsFuture = _lessonsRepository.fetchLatest();
  }

  String get _userGreetingName {
    final user = AuthRepository().currentUser;
    final fullName = user?.userMetadata?['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return user?.email ?? 'زائر';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      drawer: const _HomeDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'المحجة البيضاء',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            const SizedBox(height: 4),
            Text(
              'مرحبًا بك، $_userGreetingName',
              style: const TextStyle(color: AppColors.textGray, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طريقك إلى العلوم الشرعية',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'بسهولة .. وفي كل مكان',
                          style: TextStyle(color: AppColors.accentSoft, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book, color: AppColors.accent, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _quickCategories.map((item) {
                final (icon, label) = item;
                return _QuickCategory(
                  icon: icon,
                  label: label,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonsScreen(category: label),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'أحدث الدروس',
              onSeeAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubjectsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Lesson>>(
              future: _latestLessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'تعذّر تحميل الدروس',
                      style: TextStyle(color: AppColors.textGray),
                    ),
                  );
                }
                final lessons = snapshot.data ?? [];
                if (lessons.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'لا توجد دروس بعد',
                      style: TextStyle(color: AppColors.textGray),
                    ),
                  );
                }
                return SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: lessons.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _LessonCard(lesson: lessons[i]),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuickCategory extends StatelessWidget {
  const _QuickCategory({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.navy, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.navy, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: lesson)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 92,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lesson.durationLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.scaffoldLight,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Text(
                'المحجة البيضاء',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined, color: AppColors.navy),
              title: const Text('المواد العلمية'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubjectsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.navy),
              title: const Text('حسابي'),
              onTap: () {
                Navigator.of(context).pop();
                context.goToTab(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.fail),
              title: const Text(
                'تسجيل خروج',
                style: TextStyle(color: AppColors.fail),
              ),
              onTap: () async {
                await AuthRepository().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
