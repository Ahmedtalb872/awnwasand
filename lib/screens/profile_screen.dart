import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _items = [
    (Icons.badge_outlined, 'بياناتي الشخصية'),
    (Icons.volunteer_activism_outlined, 'سجل التبرعات'),
    (Icons.notifications_none, 'الإشعارات'),
    (Icons.settings_outlined, 'إعدادات التطبيق'),
    (Icons.help_outline, 'المساعدة والدعم'),
  ];

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
        title: const Text('الملف الشخصي'),
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
                    backgroundColor: AppColors.borderLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.navySoft,
                      size: 40,
                    ),
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
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
