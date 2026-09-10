import 'package:flutter/material.dart';

import '../models/profile_stats.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepository = ProfileRepository();
  late Future<ProfileStats> _statsFuture;

  static const _items = [
    (Icons.menu_book_outlined, 'دوراتي'),
    (Icons.favorite_outline, 'المفضلة'),
    (Icons.note_outlined, 'الملاحظات'),
    (Icons.workspace_premium_outlined, 'الشهادات'),
    (Icons.settings_outlined, 'الإعدادات'),
  ];

  @override
  void initState() {
    super.initState();
    _statsFuture = _profileRepository.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository().currentUser;
    final fullName = user?.userMetadata?['full_name'] as String?;
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user?.email ?? 'زائر');

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(Icons.person, color: AppColors.navy, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'طالب علم',
                    style: TextStyle(color: AppColors.textGray, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<ProfileStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data ?? const ProfileStats();
                return Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.emoji_events_outlined,
                        value: '${stats.completedCourses}',
                        label: 'دورات مكتملة',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.menu_book_outlined,
                        value: '${stats.followedLessons}',
                        label: 'درس متابع',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.star_outline,
                        value: '${stats.knowledgePoints}',
                        label: 'نقطة علم',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: AppColors.cardLight,
                child: Column(
                  children: _items.asMap().entries.map((entry) {
                    final (icon, label) = entry.value;
                    final isLast = entry.key == _items.length - 1;
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(icon, color: AppColors.navy),
                          title: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_left,
                            color: AppColors.textGray,
                          ),
                          onTap: () {},
                        ),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: AppColors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'بالتعاون مع جمعية عون وسند الخيرية.. معًا لخير دائم',
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: AppColors.cardLight,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.fail),
                  title: const Text(
                    'تسجيل خروج',
                    style: TextStyle(color: AppColors.fail, fontSize: 13.5),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGray, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
