import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// تهيئة الاتصال بـ Supabase، ونقطة وصول مختصرة للعميل (client) في بقية التطبيق.
class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
