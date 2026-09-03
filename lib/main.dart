import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.init();
  runApp(const AwnWasandApp());
}

/// ألوان هوية جمعية عون وسند الخيرية.
class AppColors {
  static const background = Color(0xFF221D3F);
  static const panel = Color(0xFF2B2550);
  static const line = Color(0xFF3E3670);
  static const accent = Color(0xFFF0ACA0);
  static const text = Color(0xFFF8F3EF);
  static const textDim = Color(0xFFCFC7DE);
}

class AwnWasandApp extends StatelessWidget {
  const AwnWasandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عون وسند',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          surface: AppColors.panel,
        ),
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جمعية عون وسند الخيرية')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'مرحبًا بكم',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أهلاً وسهلاً، هذه بداية تطبيق جمعية عون وسند الخيرية.',
                style: TextStyle(color: AppColors.textDim, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: const [
                    _FeatureCard(
                      icon: Icons.groups_outlined,
                      title: 'الأعضاء',
                      subtitle: 'قائمة أعضاء الجمعية وبياناتهم',
                    ),
                    _FeatureCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'المساهمات والتبرعات',
                      subtitle: 'متابعة المساهمات والحملات',
                    ),
                    _FeatureCard(
                      icon: Icons.campaign_outlined,
                      title: 'الإشعارات',
                      subtitle: 'إرسال إشعارات وحملات للأعضاء',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.accent,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
