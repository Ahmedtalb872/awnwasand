import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'root_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم الجوال أو البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _authRepository.signIn(email: identifier, password: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر تسجيل الدخول، حاول مرة أخرى')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تسجيل الدخول عبر هذه الوسيلة غير متاح بعد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_forward, color: AppColors.navy),
                alignment: Alignment.centerRight,
              ),
              Center(
                child: Image.asset('assets/images/mahajja_logo.png', height: 92),
              ),
              const SizedBox(height: 14),
              const Text(
                'المحجة البيضاء',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'للعلم الشرعي',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.accent, fontSize: 13),
              ),
              const SizedBox(height: 10),
              const Text(
                'تطبيق تعليمي مجاني أطلقته جمعية عون وسند الخيرية',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
              const SizedBox(height: 26),
              AppTextField(
                hint: 'رقم الجوال أو البريد الإلكتروني',
                icon: Icons.person_outline,
                controller: _identifierController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'كلمة المرور',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.navy,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  ),
                  const Text(
                    'تذكرني',
                    style: TextStyle(color: AppColors.textGray, fontSize: 12.5),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: _loading ? 'جارٍ تسجيل الدخول...' : 'تسجيل الدخول',
                color: AppColors.navy,
                onPressed: _loading ? null : _signIn,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(color: AppColors.textGray, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.borderLight)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'أو',
                      style: TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.borderLight)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ليس لديك حساب؟ ',
                    style: TextStyle(color: AppColors.textGray, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _comingSoon,
                icon: const Icon(Icons.g_mobiledata, color: AppColors.navy, size: 26),
                label: const Text(
                  'الدخول عبر جوجل',
                  style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _continueAsGuest,
                  child: const Text(
                    'متابعة كزائر',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12.5,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
