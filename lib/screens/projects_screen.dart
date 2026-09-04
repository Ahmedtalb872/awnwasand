import 'package:flutter/material.dart';

import '../models/project.dart';
import '../repositories/projects_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/project_card.dart';
import 'donate_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  static const _categories = ['الكل', 'دعم الأسر', 'إغاثية', 'تعليمية', 'عمارية'];
  final _projectsRepository = ProjectsRepository();
  late Future<List<CharityProject>> _projectsFuture;
  String _selected = 'الكل';

  @override
  void initState() {
    super.initState();
    _projectsFuture = _projectsRepository.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: const Text('مشاريع الجمعية')),
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
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<CharityProject>>(
                future: _projectsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'تعذّر تحميل المشاريع',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    );
                  }
                  final all = snapshot.data ?? [];
                  final projects = _selected == 'الكل'
                      ? all
                      : all.where((p) => p.category == _selected).toList();
                  if (projects.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد مشاريع في هذه الفئة',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    children: projects
                        .map(
                          (p) => ProjectCard(
                            project: p,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DonateScreen(project: p),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
