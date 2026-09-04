# عون وسند

تطبيق لجمعية عون وسند الخيرية، مبني بـ **Flutter** وباك-إند **Supabase**. الهدف
الأساسي تطبيق جوال (Android/iOS)، مع نسخة ويب تجريبية للمعاينة السريعة في المتصفح.

**تجربة النسخة الحية في المتصفح:** https://ahmedtalb872.github.io/awnwasand/
(تُبنى وتُنشر تلقائيًا عند كل push عبر GitHub Actions — انظر قسم "النسخة الويب" أدناه)

## الإعداد

1. ثبّت [Flutter SDK](https://docs.flutter.dev/get-started/install) (قناة stable).
2. ثبّت الحزم:

   ```bash
   flutter pub get
   ```

3. أنشئ مشروع على [supabase.com](https://supabase.com)، وشغّل محتوى `supabase/schema.sql`
   في SQL Editor الخاص بالمشروع (ينشئ الجداول وسياسات الوصول ويضبط تريغر إنشاء
   ملف تعريف تلقائيًا عند تسجيل مستخدم جديد).

4. انسخ ملف الإعداد:

   ```bash
   cp .env.example .env
   ```

   وعبّئ فيه `SUPABASE_URL` و `SUPABASE_ANON_KEY` من لوحة تحكم المشروع (Project Settings > API).

   > ملف `.env` مستثنى من Git عمدًا لأنه يحتوي مفاتيح المشروع.

5. أضف بيانات تجريبية لجداول `projects` و `lessons` و `members` و `expenses` (عبر
   Table Editor في Supabase) لترى محتوى حقيقيًا في الشاشات.

## التشغيل

```bash
flutter run
```

## النسخة الويب

مصدر عرض/معاينة سريع (النسخة الأساسية للتطبيق تبقى الجوال). للتشغيل محليًا:

```bash
flutter run -d chrome
```

للبناء والنشر يدويًا، شغّل `.github/workflows/deploy-web.yml` من تبويب Actions
في GitHub (زر "Run workflow")، أو ادفع أي commit — ينشر تلقائيًا على
`https://ahmedtalb872.github.io/awnwasand/` عبر GitHub Pages. أول مرة فقط، قد
تحتاج تفعيل Pages يدويًا من Settings > Pages إن لم يُفعَّل تلقائيًا عبر الـworkflow.

## التشغيل بدون Supabase مُعدّ

التطبيق يعمل ويُقلع حتى بدون بيانات Supabase حقيقية في `.env` — شاشات البداية
وتسجيل الدخول وإنشاء الحساب تعمل، لكن أي شاشة تجلب بيانات (المشاريع، الدروس،
الأعضاء، التقارير) ستعرض رسالة "تعذّر التحميل" إلى أن يُضبط الاتصال.

## البنية

- `lib/main.dart` — نقطة الدخول، يهيّئ `.env` و Supabase قبل تشغيل التطبيق.
- `lib/screens/` — شاشات التطبيق (كل شاشة من التصميم في ملف مستقل).
- `lib/repositories/` — طبقة الوصول لبيانات Supabase (المشاريع، الأعضاء، الدروس،
  المصروفات، التبرعات، المصادقة). الشاشات لا تستدعي Supabase مباشرة، بل عبر هذه الطبقة.
- `lib/models/` — نماذج البيانات، مع `fromMap` لتحويل صفوف Supabase.
- `lib/services/supabase_service.dart` — تهيئة الاتصال بـ Supabase.
- `lib/theme/` — الألوان والثيم الموحّد.
- `lib/widgets/` — عناصر واجهة مشتركة بين الشاشات.
- `supabase/schema.sql` — مخطط قاعدة البيانات وسياسات الوصول (RLS).
- `test/` — اختبارات الواجهة.
