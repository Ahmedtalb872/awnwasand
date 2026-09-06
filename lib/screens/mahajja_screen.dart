import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'lessons_screen.dart';

class MahajjaScreen extends StatelessWidget {
  const MahajjaScreen({super.key});

  static const _items = [
    (Icons.menu_book_outlined, 'الدروس'),
    (Icons.description_outlined, 'المواد التعليمية'),
    (Icons.library_books_outlined, 'الكتب والمراجع'),
    (Icons.school_outlined, 'الأساتذة والعلماء'),
    (Icons.quiz_outlined, 'الاختبارات'),
    (Icons.emoji_events_outlined, 'الأنشطة والمسابقات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: const Text('المحجة البيضاء')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mosque_outlined, color: AppColors.accent, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'المحجة البيضاء',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'صرح تعليمي مجاني',
                    style: TextStyle(color: AppColors.accent, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ننشر العلم الشرعي الصحيح ونكوّن جيلاً واعياً متمسكاً بدينه وأخلاقه.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: _items.map((item) {
                final (icon, label) = item;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (label == 'الدروس') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LessonsScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppColors.accent, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'ابدأ التعلم الآن',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LessonsScreen()),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'جميع الخدمات مجانية بالكامل',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
