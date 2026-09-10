import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// يغلّف عمليات مصادقة Supabase (تسجيل الدخول، إنشاء حساب، تسجيل الخروج).
class AuthRepository {
  GoTrueClient get _auth => SupabaseService.client.auth;

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': ?phone},
    );
  }

  Future<void> signOut() => _auth.signOut();
}
