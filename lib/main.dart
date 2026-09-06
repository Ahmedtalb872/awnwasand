import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.init();
  runApp(const AwnWasandApp());
}

class AwnWasandApp extends StatelessWidget {
  const AwnWasandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عون وسند',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
