# عون وسند

تطبيق جوال لجمعية عون وسند الخيرية، مبني بـ **Flutter** وباك-إند **Supabase**.

## الإعداد

1. ثبّت [Flutter SDK](https://docs.flutter.dev/get-started/install) (قناة stable).
2. ثبّت الحزم:

   ```bash
   flutter pub get
   ```

3. أنشئ مشروع على [supabase.com](https://supabase.com)، ثم انسخ ملف الإعداد:

   ```bash
   cp .env.example .env
   ```

   وعبّئ فيه `SUPABASE_URL` و `SUPABASE_ANON_KEY` من لوحة تحكم المشروع (Project Settings > API).

   > ملف `.env` مستثنى من Git عمدًا لأنه يحتوي مفاتيح المشروع.

## التشغيل

```bash
flutter run
```

## البنية

- `lib/main.dart` — نقطة الدخول والشاشة الرئيسية.
- `lib/services/supabase_service.dart` — تهيئة الاتصال بـ Supabase.
- `test/` — اختبارات الواجهة.
