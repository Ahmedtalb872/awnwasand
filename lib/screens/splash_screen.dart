import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Container(
                width: 168,
                height: 168,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset('assets/images/mahajja_logo.png'),
              ),
              const SizedBox(height: 18),
              const Text(
                'المحجة البيضاء',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'للعلم الشرعي',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.accent, fontSize: 15),
              ),
              const SizedBox(height: 18),
              const Text(
                'تعليم شرعي مجاني ..\nلبناء جيل واعٍ نافع لأمّته',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'ابدأ',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: AppColors.accent,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'بالتعاون مع جمعية عون وسند الخيرية',
                    style: TextStyle(color: AppColors.textGray, fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
