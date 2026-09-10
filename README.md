# المحجة البيضاء

منصة تعليمية مجانية للعلوم الشرعية، مبنية بـ **Flutter** وباك-إند **Supabase**،
أطلقتها جمعية عون وسند الخيرية. الهدف الأساسي تطبيق جوال (Android/iOS)، مع
نسخة ويب تجريبية للمعاينة السريعة في المتصفح.

**تجربة النسخة الحية في المتصفح:** https://ahmedtalb872.github.io/awnwasand/
(بعد تفعيل خطوة واحدة يدوية لمرة واحدة — انظر قسم "النسخة الويب" أدناه)

## الإعداد

1. ثبّت [Flutter SDK](https://docs.flutter.dev/get-started/install) (قناة stable).
2. ثبّت الحزم:

   ```bash
   flutter pub get
   ```

3. أنشئ مشروع على [supabase.com](https://supabase.com)، وشغّل محتوى `supabase/schema.sql`
   في SQL Editor الخاص بالمشروع (ينشئ جداول المواد العلمية والدروس والاختبارات
   وسياسات الوصول، ويضبط تريغر إنشاء ملف تعريف تلقائيًا عند تسجيل مستخدم جديد).

4. انسخ ملف الإعداد:

   ```bash
   cp .env.example .env
   ```

   وعبّئ فيه `SUPABASE_URL` و `SUPABASE_ANON_KEY` من لوحة تحكم المشروع (Project Settings > API).

   > ملف `.env` مستثنى من Git عمدًا لأنه يحتوي مفاتيح المشروع.

5. أضف بيانات تجريبية لجداول `subjects` و `lessons` و `quiz_questions` (عبر
   Table Editor في Supabase) لترى محتوى حقيقيًا في الشاشات. عمود `category`
   في جدولي `subjects` و`lessons` هو الرابط بينهما (كل درس ينتمي لمادة بنفس
   قيمة `category`).

## التشغيل

```bash
flutter run
```

## النسخة الويب

مصدر عرض/معاينة سريع (النسخة الأساسية للتطبيق تبقى الجوال). للتشغيل محليًا:

```bash
flutter run -d chrome
```

البناء والنشر يتمّان تلقائيًا عند كل push عبر `.github/workflows/deploy-web.yml`
(أو يدويًا من تبويب Actions بزر "Run workflow")، وينشران على
`https://ahmedtalb872.github.io/awnwasand/` عبر GitHub Pages.

> **خطوة لمرة واحدة مطلوبة منك أولاً:** GitHub لا يسمح لتوكن الـActions
> الافتراضي بتفعيل Pages تلقائيًا (يحتاج صلاحية إدارة المستودع). اذهب إلى
> **Settings > Pages > Build and deployment > Source** واختر **"GitHub
> Actions"**. بعدها، كل push سينشر تلقائيًا بدون أي تدخل إضافي.

## التشغيل بدون Supabase مُعدّ

التطبيق يعمل ويُقلع حتى بدون بيانات Supabase حقيقية في `.env` — شاشات البداية
وتسجيل الدخول وإنشاء الحساب تعمل (ويمكن أيضًا الدخول كزائر دون حساب من شاشة
تسجيل الدخول)، لكن أي شاشة تجلب بيانات (المواد العلمية، الدروس، الاختبارات،
إحصاءات الحساب) ستعرض رسالة "تعذّر التحميل" إلى أن يُضبط الاتصال.

## البنية

- `lib/main.dart` — نقطة الدخول، يهيّئ `.env` و Supabase قبل تشغيل التطبيق.
- `lib/screens/` — شاشات التطبيق:
  - `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart` — الترحيب والدخول.
  - `home_screen.dart` — الرئيسية: بانر، مواد سريعة، أحدث الدروس.
  - `subjects_screen.dart` — المواد العلمية (التفسير، الحديث، الفقه...).
  - `lessons_screen.dart` — دروس مادة واحدة، أو كل الدروس (تبويب "دروسي").
  - `lesson_player_screen.dart` — مُشغّل الدرس (المحتوى، دروس المادة، الملاحظات).
  - `quiz_screen.dart` — اختبار الدرس.
  - `profile_screen.dart` — "حسابي": إحصاءات التقدّم وقائمة الإعدادات.
  - `root_shell.dart` — الحاوية الجذرية وشريط التنقل السفلي.
- `lib/repositories/` — طبقة الوصول لبيانات Supabase (المواد، الدروس،
  الاختبارات، الحساب، المصادقة). الشاشات لا تستدعي Supabase مباشرة، بل عبر هذه الطبقة.
- `lib/models/` — نماذج البيانات، مع `fromMap` لتحويل صفوف Supabase.
- `lib/services/supabase_service.dart` — تهيئة الاتصال بـ Supabase.
- `lib/theme/` — الألوان والثيم الموحّد (تيل وذهبي على خلفية كريمية).
- `lib/widgets/` — عناصر واجهة مشتركة بين الشاشات.
- `supabase/schema.sql` — مخطط قاعدة البيانات وسياسات الوصول (RLS).
- `test/` — اختبارات الواجهة.
