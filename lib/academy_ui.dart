import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'academy.dart';
import 'academy_models.dart';
import 'learning_store.dart';
import 'media_store.dart';
import 'brand.dart';
import 'ui_preferences.dart';

const academyGreen = brandPurple;
const academyGold = brandPink;
void showMessage(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
String friendlyError(Object error) {
  if (error is AuthException) {
    if (error.code == 'phone_provider_disabled' || error.message.toLowerCase().contains('phone provider')) return 'التسجيل بالهاتف غير متاح حاليًا. حاول لاحقًا أو تواصل مع إدارة المحجة البيضاء.';
    if (error.code == 'phone_not_confirmed') return 'يحتاج حسابك إلى تأكيد الهاتف. تواصل مع الإدارة لإكمال تفعيل حسابك.';
    if (error.code == 'invalid_credentials') return 'رقم الهاتف أو كلمة السر غير صحيحة.';
    return 'تعذّر تسجيل الدخول. تحقق من البيانات وإعدادات الحساب ثم حاول مجددًا.';
  }
  if (error is ArgumentError) return error.message?.toString() ?? 'تحقق من البيانات';
  if (error is StateError) return error.message;
  return 'تعذر إتمام العملية. تحقق من الاتصال والصلاحيات ثم حاول مجددًا.';
}

class AcademyPortal extends StatelessWidget {
  const AcademyPortal({super.key, required this.academy, required this.learningBuilder});
  final Academy academy;
  final Widget Function(LearningStore) learningBuilder;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: academy, builder: (context, _) => academy.user == null
    ? WelcomeScreen(academy: academy)
    : StudentArea(key: ValueKey(academy.user!.id), academy: academy, learningBuilder: learningBuilder));
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.academy, this.startWithAuth = false, this.initialRegister = true});
  final Academy academy;
  final bool startWithAuth, initialRegister;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), phone = TextEditingController(), password = TextEditingController();
  bool register = false, busy = false, authOpen = false, passwordVisible = false;
  String? error;
  @override
  void initState() { super.initState(); authOpen = widget.startWithAuth; register = widget.initialRegister; }
  @override
  void dispose() { name.dispose(); phone.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    try {
      if (widget.academy.isDemo || register) {
        final active = await widget.academy.signUp(name.text, phone.text, password.text);
        if (!active && mounted) setState(() => error = 'أُنشئ الحساب، لكن يحتاج حسابك إلى تأكيد الهاتف. تواصل مع الإدارة لإكمال تفعيل حسابك.');
      } else { await widget.academy.signIn(phone.text, password.text); }
    } catch (e) { if (mounted) setState(() => error = friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> select(String id) async {
    setState(() => busy = true);
    try { await widget.academy.selectDemo(id); }
    catch (e) { if (mounted) setState(() => error = friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Widget landing() => Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: LayoutBuilder(builder: (context, box) => SingleChildScrollView(child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight), child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(Icons.auto_stories_outlined, size: 22), SizedBox(width: 8), Text('للعلوم الشرعية', style: TextStyle(fontSize: 12)), Spacer(), Text('مرحبًا بك', style: TextStyle(fontSize: 12, color: brandMuted))])),
    const SizedBox(height: 22),
    const Column(children: [LogoMedallion(size: 280), SizedBox(height: 24), Text('مرحبًا بك', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)), SizedBox(height: 12), Text('ابدأ رحلتك في طلب العلم', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), SizedBox(height: 10), Text('منصة تعليمية تهدف إلى نشر العلم الشرعي\nبأسلوب ميسّر وموثوق', textAlign: TextAlign.center, style: TextStyle(color: brandMuted, fontSize: 13)), SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.circle, size: 7, color: brandPink), SizedBox(width: 6), Icon(Icons.circle, size: 7, color: brandBorder), SizedBox(width: 6), Icon(Icons.circle, size: 7, color: brandBorder)])]),
    const SizedBox(height: 24),
    const Wrap(alignment: WrapAlignment.center, spacing: 18, runSpacing: 10, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_circle_outline, size: 17, color: brandMuted), SizedBox(width: 6), Text('تعلّم', style: TextStyle(color: brandMuted, fontSize: 11))]),
      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bookmark_border, size: 17, color: brandMuted), SizedBox(width: 6), Text('احتفظ بمراجعك', style: TextStyle(color: brandMuted, fontSize: 11))]),
      Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.insights, size: 17, color: brandMuted), SizedBox(width: 6), Text('تقدّم', style: TextStyle(color: brandMuted, fontSize: 11))]),
    ]),
    const SizedBox(height: 26),
    GlowButton(onPressed: () => setState(() { authOpen = true; register = true; error = null; }), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('إنشاء حساب'), SizedBox(width: 10), Icon(Icons.arrow_back, size: 18)])),
    const SizedBox(height: 8), TextButton(onPressed: () => setState(() { authOpen = true; register = false; error = null; }), child: const Text('لديك حساب؟ تسجيل الدخول', style: TextStyle(fontSize: 12))),
    const SizedBox(height: 4),
  ])))))))));

  Widget authPage() => Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(backgroundColor: brandIvory, leading: IconButton(tooltip: 'العودة', onPressed: busy ? null : () => setState(() => authOpen = false), icon: const Icon(Icons.arrow_back)), title: Text(register ? 'حساب جديد' : 'تسجيل الدخول', style: const TextStyle(fontSize: 15)), actions: const [Padding(padding: EdgeInsetsDirectional.only(end: 24), child: Icon(Icons.auto_stories_outlined, size: 23))]), body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(28, 12, 28, 28), child: AutofillGroup(child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    AuthHero(register: register), const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: brandBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    if (widget.academy.isDemo) const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('أنشئ ملف طالب للتجربة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
    if (widget.academy.isDemo) const DemoNotice(),
    if (widget.academy.setupIssue != null) Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: brandIvory, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(widget.academy.setupIssue!, style: const TextStyle(fontSize: 12)), TextButton(onPressed: busy ? null : () async { setState(() => busy = true); await widget.academy.checkSchema(); if (mounted) setState(() => busy = false); }, child: const Text('التحقق مجددًا'))])),
    if (widget.academy.isDemo || register) ...[
      TextFormField(controller: name, maxLength: 60, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.name], decoration: const InputDecoration(labelText: 'اسم الطالب', prefixIcon: Icon(Icons.person_outline, size: 20), counterText: ''), validator: (value) => (value?.trim().length ?? 0) < 2 ? 'أدخل اسمًا من حرفين على الأقل' : null),
      const SizedBox(height: 16),
    ],
    if (!widget.academy.isDemo) ...[
      TextFormField(controller: phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, textDirection: TextDirection.ltr, autofillHints: const [AutofillHints.telephoneNumber], decoration: const InputDecoration(labelText: 'رقم الهاتف', hintText: '+212612345678', prefixIcon: Icon(Icons.phone_outlined, size: 20), helperText: 'مع رمز البلد، مثل \u200e+212'), validator: (value) { try { Academy.normalizePhone(value ?? ''); return null; } on ArgumentError catch (e) { return e.message.toString(); } }),
      const SizedBox(height: 16),
      TextFormField(controller: password, obscureText: !passwordVisible, textInputAction: TextInputAction.done, autofillHints: [register ? AutofillHints.newPassword : AutofillHints.password], onFieldSubmitted: (_) { if (!busy && widget.academy.setupIssue == null) submit(); }, decoration: InputDecoration(labelText: 'كلمة السر', prefixIcon: const Icon(Icons.lock_outline, size: 20), helperText: register ? '8 أحرف على الأقل' : null, suffixIcon: IconButton(tooltip: passwordVisible ? 'إخفاء كلمة السر' : 'إظهار كلمة السر', onPressed: () => setState(() => passwordVisible = !passwordVisible), icon: Icon(passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20))), validator: (value) => (value?.length ?? 0) < 8 ? '8 أحرف على الأقل' : null),
    ],
    if (error != null) Container(margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xffffedf1), borderRadius: BorderRadius.circular(14)), child: Text(error!, style: const TextStyle(color: Color(0xffa14366), fontSize: 12))),
    const SizedBox(height: 28), GlowButton(onPressed: busy || widget.academy.setupIssue != null ? null : submit, child: busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.academy.isDemo ? 'إنشاء ملف وبدء التعلم' : register ? 'إنشاء حساب' : 'تسجيل الدخول')),
    if (!widget.academy.isDemo) ...[const SizedBox(height: 12), TextButton(onPressed: busy ? null : () => setState(() { register = !register; error = null; }), child: Text(register ? 'لدي حساب بالفعل' : 'ليس لدي حساب؛ إنشاء حساب', style: const TextStyle(fontSize: 12)))],
    if (widget.academy.isDemo) ...[
      const SizedBox(height: 20), for (final student in widget.academy.students) OutlinedButton.icon(onPressed: busy ? null : () => select(student.id), icon: const Icon(Icons.person_outline), label: Text('متابعة ملف ${student.name}')),
      const SizedBox(height: 12), OutlinedButton.icon(onPressed: busy ? null : () => select('demo-admin'), icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('تجربة لوحة الإدارة')),
    ],
    ])),
    const SizedBox(height: 24), const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 14, color: brandMuted), SizedBox(width: 6), Flexible(child: Text('مساحة خاصة لرحلتك التعليمية', style: TextStyle(color: brandMuted, fontSize: 11)))]),
  ]))))))));

  @override
  Widget build(BuildContext context) => PopScope(canPop: !authOpen, onPopInvokedWithResult: (didPop, result) { if (!didPop && !busy) setState(() => authOpen = false); }, child: IslamicBackdrop(child: authOpen ? authPage() : landing()));
}

class Feature extends StatelessWidget {
  const Feature({super.key, required this.icon, required this.title});
  final IconData icon; final String title;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    decoration: BoxDecoration(color: brandSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: brandBorder)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 22, color: academyGreen), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))]),
  );
}
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: const Color(0xfff2edf7), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.info_outline, size: 16), SizedBox(width: 8), Expanded(child: Text('وضع تجريبي · البيانات محفوظة على هذا الجهاز', style: TextStyle(fontSize: 10)))]));
}

class StudentArea extends StatefulWidget {
  const StudentArea({super.key, required this.academy, required this.learningBuilder, this.initialSelected = 0});
  final int initialSelected;
  final Academy academy; final Widget Function(LearningStore) learningBuilder;
  @override
  State<StudentArea> createState() => _StudentAreaState();
}
class _StudentAreaState extends State<StudentArea> {
  int selected = 0;
  LearningStore? learning;
  String search = '';
  bool enrolledOnly = false;
  bool loading = false;
  Academy get academy => widget.academy;
  @override
  void initState() { super.initState(); selected = widget.initialSelected; loadLearning(); }
  Future<void> loadLearning() async {
    try {
      final store = await LearningStore.load(profileId: academy.user!.id);
      if (!mounted) { store.dispose(); return; }
      store.name = academy.user!.name;
      setState(() => learning = store);
    } catch (_) { if (mounted) showMessage(context, 'تعذر تحميل تقدم الدروس على الجهاز.'); }
  }
  @override
  void dispose() { learning?.dispose(); super.dispose(); }
  Widget title(String value) => SectionHeading(value);
  Future<void> action(Future<void> Function() work) async {
    if (loading) return;
    setState(() => loading = true);
    try { await work(); } catch (e) { if (mounted) showMessage(context, friendlyError(e)); }
    finally { if (mounted) setState(() => loading = false); }
  }
  void openCourse(AcademyCourse course) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => CourseScreen(academy: academy, courseId: course.id)));
  void editCourse([AcademyCourse? course]) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => CourseEditor(academy: academy, course: course)));
  Widget courseCard(AcademyCourse course) {
    final enrollment = academy.enrollment(course.id);
    final count = course.materials.length, completed = enrollment?.completed.length ?? 0;
    final icon = course.title.contains('قرآن') ? Icons.auto_stories_outlined : course.title.contains('سيرة') ? Icons.mosque_outlined : Icons.menu_book_outlined;
    return Card(child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => openCourse(course), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 70, height: 84, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff443167), Color(0xff29234d)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: brandPink, size: 34)),
        const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: brandIvory, borderRadius: BorderRadius.circular(6)), child: Text(course.level, style: const TextStyle(fontSize: 9, color: brandMuted))),
          const SizedBox(height: 7), Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4), Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: brandMuted)),
        ])),
      ]), const SizedBox(height: 16),
      Row(children: [const Icon(Icons.person_outline, size: 14, color: brandMuted), const SizedBox(width: 5), Expanded(child: Text(course.teacher.isEmpty ? 'المحجة البيضاء' : course.teacher, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: brandMuted))), Text(enrollment == null ? 'عرض الدورة' : 'متابعة', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(width: 4), const Icon(Icons.arrow_back, size: 15)]),
      if (enrollment != null) ...[const SizedBox(height: 14), LinearProgressIndicator(value: count == 0 ? 0 : (completed / count).clamp(0.0, 1.0).toDouble(), minHeight: 4), const SizedBox(height: 6), Text('$completed من $count مواد مكتملة', style: const TextStyle(fontSize: 10, color: brandMuted))],
    ]))));
  }
  Widget stat(String value, String label, IconData icon) => Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18), decoration: BoxDecoration(color: brandSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: brandBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 22, color: brandPurple), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2)), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 10, color: brandMuted))])));
  Widget home() {
    final enrolled = academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).toList();
    final next = enrolled.where((c) => academy.enrollment(c.id)!.completed.length < c.materials.length).firstOrNull;
    final progress = next == null || next.materials.isEmpty ? 0.0 : (academy.enrollment(next.id)!.completed.length / next.materials.length).clamp(0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('السلام عليكم، ${academy.user!.name.split(' ').first}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6), const Text('كل خطوة في العلم تُضيء الطريق.', style: TextStyle(color: brandMuted, fontSize: 12)), const SizedBox(height: 24),
      BrandPanel(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const Icon(Icons.auto_stories_outlined, color: brandPink, size: 18), const SizedBox(width: 8), Expanded(child: Text(academy.isAdmin ? 'مساحة الإدارة' : next == null ? 'بداية رحلتك' : 'دورتك الحالية', style: const TextStyle(color: brandPink, fontSize: 11))), const Icon(Icons.auto_awesome_outlined, color: Colors.white38, size: 20)]),
        const SizedBox(height: 14), Text(next?.title ?? 'خطوة جديدة نحو العلم', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (next != null) ...[Row(children: [const Expanded(child: Text('تابع تعلّمك', style: TextStyle(color: Colors.white70, fontSize: 11))), Text('${(progress * 100).round()}%', style: const TextStyle(color: brandPink, fontSize: 12))]), const SizedBox(height: 8), LinearProgressIndicator(value: progress, minHeight: 4)]
        else Text(academy.isAdmin ? 'جهّز المحتوى، ثم انشره للطلاب.' : 'اختر دورة، وابدأ رحلة تعلّم على مهل.', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 18), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: brandPink, foregroundColor: brandIvory, minimumSize: const Size(0, 44)), onPressed: () { if (next != null && !academy.isAdmin) { openCourse(next); } else { setState(() => selected = academy.isAdmin ? 3 : 1); } }, icon: const Icon(Icons.arrow_back, size: 16), label: Text(academy.isAdmin ? 'فتح لوحة الإدارة' : next != null ? 'متابعة الدورة' : 'استكشف الدورات')),
      ])),
      const SizedBox(height: 22),
      Row(children: [for (final item in [(Icons.school_outlined, 'الدورات'), (Icons.play_circle_outline, 'الفيديوهات'), (Icons.folder_outlined, 'المواد')]) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () { if (item.$2 == 'الدورات') { setState(() => selected = 1); } else { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => MaterialLibrary(academy: academy, videos: item.$2 == 'الفيديوهات'))); } }, child: Container(padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: const Color(0xfff7eaf0), borderRadius: BorderRadius.circular(18)), child: Column(children: [Icon(item.$1, color: brandPink), const SizedBox(height: 8), Text(item.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))])))))]),
      SectionHeading('الدورات المتاحة', action: 'عرض الكل', onTap: () => setState(() => selected = 1)), ...academy.visibleCourses.take(3).map(courseCard),
      if (academy.visibleCourses.isEmpty) const EmptyState(icon: Icons.auto_stories_outlined, title: 'رحلة جديدة تبدأ قريبًا', description: 'ستجد الدورات هنا بمجرد نشرها من المشرف.'),
      SectionHeading('مساراتك الأساسية', action: 'تعلّم الآن', onTap: learning == null ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => widget.learningBuilder(learning!)))),
      Card(child: ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('القرآن والسنة والعبادات والأخلاق'), subtitle: Text('${learning?.completedCount ?? 0} من 12 درسًا مكتملًا على هذا الجهاز'), trailing: const Icon(Icons.chevron_left), onTap: learning == null ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => widget.learningBuilder(learning!))))),
    ]);
  }
  Widget coursesPage() {
    final courses = academy.visibleCourses.where((c) => (!enrolledOnly || academy.enrollment(c.id) != null) && '${c.title} ${c.description} ${c.teacher}'.contains(search)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('اكتشف ما يلهمك', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('علمٌ منظّم، وخطوات تناسب رحلتك.', style: TextStyle(color: brandMuted, fontSize: 12)), const SizedBox(height: 22),
      TextField(decoration: const InputDecoration(hintText: 'ابحث عن دورة أو معلّم', prefixIcon: Icon(Icons.search, size: 22)), onChanged: (value) => setState(() => search = value.trim())), const SizedBox(height: 18),
      Wrap(spacing: 10, children: [ChoiceChip(label: const Text('كل الدورات'), selected: !enrolledOnly, onSelected: (_) => setState(() => enrolledOnly = false)), ChoiceChip(label: const Text('المسجّل بها'), selected: enrolledOnly, onSelected: (_) => setState(() => enrolledOnly = true))]),
      SectionHeading(enrolledOnly ? 'دوراتك المسجّل بها' : 'الدورات التعليمية'),
      ...courses.map(courseCard),
      if (courses.isEmpty) EmptyState(icon: Icons.search_off_outlined, title: search.isNotEmpty ? 'لا توجد نتائج' : enrolledOnly ? 'لم تنضم إلى دورة بعد' : 'الدورات قادمة قريبًا', description: search.isNotEmpty ? 'جرّب كلمات أقل، أو ابحث باسم المعلّم.' : enrolledOnly ? 'استكشف كل الدورات واختر بداية رحلتك.' : 'تابع هذه المساحة للتعرّف إلى الدورات الجديدة.'),
    ]);
  }
  Widget profilePage() {
    final user = academy.user!;
    final entries = academy.enrollments.where((e) => e.studentId == user.id).toList();
    final total = academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).fold<int>(0, (n, c) => n + c.materials.length);
    final completed = entries.fold<int>(0, (n, e) => n + e.completed.length);
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('ملف الطالب', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: brandBorder)), child: CircleAvatar(radius: 34, backgroundColor: brandPink, child: Text(user.name.substring(0, 1), style: const TextStyle(fontSize: 28, color: brandIvory)))), const SizedBox(height: 14),
        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: brandPurple)), const SizedBox(height: 4),
        Text('طالب علم · ${user.level}', style: const TextStyle(fontSize: 11, color: brandMuted)), if (user.phone.isNotEmpty) Text(user.phone, textDirection: TextDirection.ltr, style: const TextStyle(color: brandMuted, fontSize: 11)),
        if (user.bio.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(user.bio, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted, fontSize: 12))),
        const SizedBox(height: 18), OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: brandPurple, side: const BorderSide(color: brandBorder), minimumSize: const Size(0, 42)), onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProfileEditor(academy: academy))), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('تعديل ملفي', style: TextStyle(fontSize: 12))),
      ]))),
      const SizedBox(height: 20), Row(children: [stat('${entries.length}', 'دورات مسجّل بها', Icons.auto_stories_outlined), const SizedBox(width: 12), stat('$completed', 'مواد مكتملة', Icons.task_alt)]), const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('تقدّمك الدراسي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        LinearProgressIndicator(value: progress, minHeight: 8), const SizedBox(height: 10),
        Text(total == 0 ? 'ابدأ بدورة لتتابع تقدّمك هنا.' : '${(progress * 100).round()}% · $completed من $total مواد مكتملة'),
      ]))),
      Card(child: ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen())))),
      title('الدورات المسجّل بها'), ...academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).map(courseCard), if (entries.isEmpty) const EmptyState(icon: Icons.school_outlined, title: 'رحلتك بانتظارك', description: 'انضم إلى دورتك الأولى، وسنعرض تقدّمك هنا.'),
      const SizedBox(height: 16), Text(academy.isDemo ? 'هذا الملف تجريبي ومحفوظ على جهازك.' : 'ملفك والدورات المسجّل بها محفوظة في حسابك. نتائج المسارات الأساسية محفوظة على هذا الجهاز.', style: const TextStyle(fontSize: 12)),
    ]);
  }
  Widget adminPage() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('لوحة الإدارة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('نظّم المحتوى، وتابع رحلة الطلاب.', style: TextStyle(color: brandMuted, fontSize: 12)), const SizedBox(height: 22),
    Row(children: [stat('${academy.courses.length}', 'الدورات', Icons.auto_stories_outlined), const SizedBox(width: 10), stat('${academy.students.length}', 'الطلاب', Icons.people_outline), const SizedBox(width: 10), stat('${academy.courses.fold<int>(0, (n,c) => n+c.materials.length)}', 'المواد', Icons.folder_outlined)]),
    const SizedBox(height: 22), FilledButton.icon(onPressed: () => editCourse(), icon: const Icon(Icons.add, size: 20), label: const Text('إضافة دورة جديدة')),
    title('إدارة الدورات'),
    for (final course in academy.courses) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('${course.published ? 'منشورة للطلاب' : 'مسودة'} · ${course.materials.length} مواد'),
      Wrap(spacing: 8, children: [TextButton.icon(onPressed: () => openCourse(course), icon: const Icon(Icons.upload_file_outlined), label: const Text('الفيديوهات والملفات')), TextButton.icon(onPressed: () => editCourse(course), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الدورة')), TextButton.icon(onPressed: loading ? null : () async {
        final yes = await confirm(context, 'حذف الدورة؟', 'ستُحذف الدورة وموادها وتسجيلات الطلاب بها.');
        if (yes) await action(() => academy.deleteCourse(course));
      }, icon: const Icon(Icons.delete_outline), label: const Text('حذف'))]),
    ]))),
    title('ملفات الطلاب'),
    if (academy.students.isEmpty) const EmptyState(icon: Icons.people_outline, title: 'طلابك سيظهرون هنا', description: 'تابع الملفات والتقدّم بعد انضمام الطلاب.'),
    for (final student in academy.students) Card(child: ListTile(leading: const Icon(Icons.person_outline), title: Text(student.name), subtitle: Text('${student.level} · ${academy.enrollments.where((e) => e.studentId == student.id).length} دورات'), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => StudentDetails(academy: academy, student: student))))),
  ]);
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: academy, builder: (context, _) {
    if (academy.user == null) return const SizedBox.shrink();
    return Scaffold(appBar: AppBar(title: const BrandHeading(), actions: [IconButton(tooltip: 'تحديث', onPressed: loading ? null : () => action(academy.refresh), icon: const Icon(Icons.refresh)), PopupMenuButton<String>(tooltip: 'خيارات الحساب', icon: const Icon(Icons.more_horiz), onSelected: (value) async { if (value == 'logout' && !loading && await confirm(context, 'تسجيل الخروج؟', 'يمكنك العودة إلى رحلتك بتسجيل الدخول مجددًا.')) await action(academy.signOut); }, itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج'))])]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: SingleChildScrollView(key: ValueKey(selected), padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [if (academy.isDemo) const DemoNotice(), if (loading) const LinearProgressIndicator(), selected == 0 ? home() : selected == 1 ? coursesPage() : selected == 2 ? profilePage() : adminPage()])))),
      bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (value) => setState(() => selected = value), destinations: [const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'), const NavigationDestination(icon: Icon(Icons.play_lesson_outlined), label: 'دوراتي'), const NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'), if (academy.isAdmin) const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'الإدارة')]),
    );
  });
}

Future<bool> confirm(BuildContext context, String title, String text) async => await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد'))])) ?? false;

class CourseEditor extends StatefulWidget {
  const CourseEditor({super.key, required this.academy, this.course});
  final Academy academy; final AcademyCourse? course;
  @override
  State<CourseEditor> createState() => _CourseEditorState();
}
class _CourseEditorState extends State<CourseEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, description, teacher;
  bool published = false, busy = false; String level = 'مبتدئ';
  @override
  void initState() { super.initState(); name = TextEditingController(text: widget.course?.title); description = TextEditingController(text: widget.course?.description); teacher = TextEditingController(text: widget.course?.teacher); published = widget.course?.published ?? false; level = widget.course?.level ?? 'مبتدئ'; }
  @override
  void dispose() { name.dispose(); description.dispose(); teacher.dispose(); super.dispose(); }
  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await widget.academy.saveCourse(AcademyCourse(id: widget.course?.id ?? const Uuid().v4(), title: name.text.trim(), description: description.text.trim(), teacher: teacher.text.trim(), level: level, published: published));
      if (mounted) { showMessage(context, 'حُفظت الدورة. يمكنك الآن إضافة الفيديوهات والملفات.'); Navigator.pop(context); }
    } catch (e) { if (mounted) showMessage(context, friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.course == null ? 'إضافة دورة' : 'تعديل الدورة')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 750), child: Form(key: form, child: ListView(padding: const EdgeInsets.all(24), children: [
    TextFormField(controller: name, maxLength: 120, decoration: const InputDecoration(labelText: 'اسم الدورة'), validator: (value) => (value?.trim().length ?? 0) < 3 ? 'اسم من 3 أحرف على الأقل' : null), const SizedBox(height: 16),
    TextFormField(controller: description, maxLength: 5000, minLines: 4, maxLines: 8, decoration: const InputDecoration(labelText: 'وصف الدورة وما سيتعلمه الطالب'), validator: (value) => (value?.trim().length ?? 0) < 10 ? 'وصف من 10 أحرف على الأقل' : null), const SizedBox(height: 16),
    TextFormField(controller: teacher, maxLength: 120, decoration: const InputDecoration(labelText: 'اسم المعلّم')), const SizedBox(height: 16),
    DropdownButtonFormField<String>(value: level, decoration: const InputDecoration(labelText: 'المستوى'), items: ['مبتدئ', 'متوسط', 'متقدم'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (value) => setState(() => level = value ?? 'مبتدئ')),
    SwitchListTile(title: const Text('نشر الدورة للطلاب'), subtitle: const Text('أوقف النشر لتبقى الدورة مسودة داخل الإدارة.'), value: published, onChanged: busy ? null : (value) => setState(() => published = value)),
    const SizedBox(height: 16), FilledButton.icon(onPressed: busy ? null : save, icon: const Icon(Icons.save_outlined), label: Text(busy ? 'جارٍ الحفظ…' : 'حفظ الدورة')),
  ])))));
}

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key, required this.academy}); final Academy academy;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}
class _ProfileEditorState extends State<ProfileEditor> {
  late final TextEditingController name, bio; late String level; bool busy = false;
  @override
  void initState() { super.initState(); name = TextEditingController(text: widget.academy.user!.name); bio = TextEditingController(text: widget.academy.user!.bio); level = widget.academy.user!.level; }
  @override
  void dispose() { name.dispose(); bio.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تعديل ملف الطالب')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: ListView(padding: const EdgeInsets.all(24), children: [
    TextField(controller: name, maxLength: 60, decoration: const InputDecoration(labelText: 'اسم الطالب')), const SizedBox(height: 16),
    DropdownButtonFormField<String>(value: level, decoration: const InputDecoration(labelText: 'المستوى'), items: ['مبتدئ', 'متوسط', 'متقدم'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (value) => setState(() => level = value ?? 'مبتدئ')), const SizedBox(height: 16),
    TextField(controller: bio, maxLength: 1000, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'نبذة وأهداف التعلم')), const SizedBox(height: 16),
    FilledButton(onPressed: busy ? null : () async {
      setState(() => busy = true);
      try { await widget.academy.saveProfile(name.text, level, bio.text); if (context.mounted) Navigator.pop(context); }
      catch (e) { if (context.mounted) showMessage(context, friendlyError(e)); }
      finally { if (mounted) setState(() => busy = false); }
    }, child: Text(busy ? 'جارٍ الحفظ…' : 'حفظ ملفي')),
  ]))));
}

class StudentDetails extends StatelessWidget {
  const StudentDetails({super.key, required this.academy, required this.student}); final Academy academy; final StudentProfile student;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('ملف ${student.name}')), body: ListView(padding: const EdgeInsets.all(24), children: [
    Text(student.name, style: Theme.of(context).textTheme.headlineMedium), if (student.email.isNotEmpty) Text(student.email), Text('المستوى: ${student.level}'), Text(student.bio), const SizedBox(height: 24), const Text('الدورات المسجّل بها', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    for (final e in academy.enrollments.where((e) => e.studentId == student.id)) ...academy.courses.where((c) => c.id == e.courseId).map((c) => Card(child: ListTile(title: Text(c.title), subtitle: Text('${e.completed.where((id) => c.materials.any((m) => m.id == id)).length} / ${c.materials.length} مواد مكتملة')))),
    if (!academy.enrollments.any((e) => e.studentId == student.id)) const Text('لم ينضم الطالب إلى دورة بعد.'),
  ]));
}

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.academy, required this.courseId}); final Academy academy; final String courseId;
  @override
  State<CourseScreen> createState() => _CourseScreenState();
}
class _CourseScreenState extends State<CourseScreen> {
  bool busy = false;
  Academy get academy => widget.academy;
  Future<void> work(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try { await action(); } catch (e) { if (mounted) showMessage(context, friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: academy, builder: (context, _) {
    final matches = academy.courses.where((c) => c.id == widget.courseId);
    if (matches.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: Text('الدورة غير متاحة')));
    final course = matches.first, entry = academy.enrollment(widget.courseId);
    final unlocked = academy.isAdmin || entry != null;
    return Scaffold(appBar: AppBar(title: Text(course.title)), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: ListView(padding: const EdgeInsets.all(24), children: [
      Text(course.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text('${course.level} · ${course.teacher}'), const SizedBox(height: 18), Text(course.description, style: const TextStyle(fontSize: 18, height: 1.8)), const SizedBox(height: 24),
      if (busy) const LinearProgressIndicator(),
      if (academy.isAdmin) FilledButton.icon(onPressed: busy ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => UploadScreen(academy: academy, courseId: course.id))), icon: const Icon(Icons.upload_file), label: const Text('رفع فيديو أو ملف')),
      if (!academy.isAdmin && entry == null) FilledButton.icon(onPressed: busy ? null : () => work(() => academy.enroll(course.id)), icon: const Icon(Icons.school_outlined), label: const Text('انضم إلى الدورة')),
      if (entry != null) ...[Text('تقدمك: ${entry.completed.where((id) => course.materials.any((m) => m.id == id)).length} / ${course.materials.length} مواد'), const SizedBox(height: 12)],
      const SizedBox(height: 20), const Text('مواد الدورة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      if (course.materials.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(academy.isAdmin ? 'أضف أول فيديو أو مرجع لهذه الدورة.' : unlocked ? 'لم تُضف مواد بعد. ستظهر هنا عندما يرفعها المشرف.' : 'انضم إلى الدورة لعرض المواد المتاحة.')),
      for (final item in course.materials) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Icon(item.isVideo ? Icons.play_circle_outline : Icons.description_outlined, color: academyGreen), const SizedBox(width: 12), Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)))]), Text('${item.fileName} · ${(item.size / 1024 / 1024).toStringAsFixed(1)} ميجابايت', style: const TextStyle(fontSize: 12)),
        Wrap(spacing: 8, children: [
          TextButton.icon(onPressed: busy || !unlocked ? null : () => item.isVideo ? Navigator.push(context, MaterialPageRoute<void>(builder: (_) => VideoScreen(academy: academy, material: item))) : work(() => academy.openFile(item)), icon: Icon(item.isVideo ? Icons.play_arrow : Icons.download_outlined), label: Text(item.isVideo ? 'مشاهدة الفيديو' : 'فتح / تنزيل الملف')),
          if (entry != null) TextButton.icon(onPressed: busy || entry.completed.contains(item.id) ? null : () => work(() => academy.completeMaterial(item)), icon: Icon(entry.completed.contains(item.id) ? Icons.check_circle : Icons.task_alt), label: Text(entry.completed.contains(item.id) ? 'مكتملة' : 'أتممت هذه المادة')),
          if (academy.isAdmin) TextButton.icon(onPressed: busy ? null : () async { if (await confirm(context, 'حذف المادة؟', 'ستُحذف المادة وملفها من الدورة.')) await work(() => academy.deleteMaterial(item)); }, icon: const Icon(Icons.delete_outline), label: const Text('حذف')),
        ]), if (!unlocked) const Text('انضم إلى الدورة للوصول إلى هذه المادة.', style: TextStyle(fontSize: 12)),
      ]))),
    ]))));
  });
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, required this.academy, required this.courseId}); final Academy academy; final String courseId;
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}
class _UploadScreenState extends State<UploadScreen> {
  final title = TextEditingController(); PlatformFile? file; Uint8List? bytes; bool busy = false;
  @override
  void dispose() { title.dispose(); super.dispose(); }
  Future<void> choose({bool video = false}) async {
    setState(() => busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: video ? ['mp4', 'webm', 'mov'] : ['pdf', 'docx', 'pptx', 'png', 'jpg', 'jpeg'], withData: true);
      if (result != null) {
        final selected = result.files.single;
        if (selected.bytes == null) throw StateError('تعذر قراءة الملف');
        Academy.validateUpload(selected.name, selected.bytes!);
        if (mounted) setState(() { file = selected; bytes = selected.bytes; if (title.text.isEmpty) title.text = selected.name; });
      }
    } catch (e) { if (mounted) showMessage(context, friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> upload() async {
    if (file == null || bytes == null) { showMessage(context, 'اختر الملف أولًا'); return; }
    setState(() => busy = true);
    try { await widget.academy.upload(widget.courseId, title.text, file!.name, bytes!); if (mounted) { showMessage(context, widget.academy.isDemo ? 'حُفظت المادة على هذا الجهاز.' : 'رُفعت المادة إلى الدورة.'); Navigator.pop(context); } }
    catch (e) { if (mounted) showMessage(context, friendlyError(e)); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('رفع مادة للدورة')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: ListView(padding: const EdgeInsets.all(24), children: [
    if (widget.academy.isDemo) const DemoNotice(),
    TextField(controller: title, maxLength: 160, decoration: const InputDecoration(labelText: 'عنوان الفيديو أو الملف')), const SizedBox(height: 24),
    Wrap(spacing: 12, runSpacing: 12, children: [
      OutlinedButton.icon(onPressed: busy ? null : () => choose(video: true), icon: const Icon(Icons.play_circle_outline), label: const Text('رفع فيديو')),
      OutlinedButton.icon(onPressed: busy ? null : () => choose(), icon: const Icon(Icons.attach_file), label: const Text('رفع ملف')),
    ]),
    const SizedBox(height: 12), const Text('فيديو: MP4 أو WebM أو MOV. ملفات: PDF، Word، PowerPoint، وصور. الحد الأقصى 50 ميجابايت.'),
    if (file != null) Card(child: ListTile(leading: const Icon(Icons.insert_drive_file_outlined), title: Text(file!.name), subtitle: Text('${(file!.size / 1024 / 1024).toStringAsFixed(1)} ميجابايت'))),
    const SizedBox(height: 24), if (busy) const LinearProgressIndicator(), const SizedBox(height: 12),
    FilledButton.icon(onPressed: busy ? null : upload, icon: const Icon(Icons.cloud_upload_outlined), label: Text(busy ? 'جارٍ المعالجة…' : 'رفع وإضافة إلى الدورة')),
  ]))));
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key, required this.academy, required this.material}); final Academy academy; final CourseMaterial material;
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}
class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? controller; String? location, error;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() => error = null);
    VideoPlayerController? pending;
    String? pendingUrl;
    try {
      final url = await widget.academy.videoUrl(widget.material);
      pendingUrl = url;
      final video = localVideoController(url);
      pending = video;
      await video.initialize();
      if (!mounted) { await video.dispose(); widget.academy.media.release(url); return; }
      location = url; controller = video;
      video.addListener(update);
      setState(() {});
    } catch (_) {
      await pending?.dispose();
      if (pendingUrl != null) widget.academy.media.release(pendingUrl);
      if (mounted) setState(() => error = 'تعذر تشغيل الفيديو. تحقق من الاتصال وصيغة الفيديو.');
    }
  }
  void update() { if (mounted) setState(() {}); }
  @override
  void dispose() { controller?.removeListener(update); controller?.dispose(); if (location != null) widget.academy.media.release(location!); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final video = controller;
    return Scaffold(appBar: AppBar(title: Text(widget.material.title)), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: ListView(padding: const EdgeInsets.all(24), children: [
      if (error != null) ...[Text(error!), TextButton(onPressed: load, child: const Text('إعادة المحاولة'))]
      else if (video == null) const Padding(padding: EdgeInsets.all(80), child: Center(child: CircularProgressIndicator()))
      else ...[
        AspectRatio(aspectRatio: video.value.aspectRatio, child: VideoPlayer(video)),
        VideoProgressIndicator(video, allowScrubbing: true, padding: const EdgeInsets.symmetric(vertical: 20)),
        FilledButton.icon(onPressed: () => video.value.isPlaying ? video.pause() : video.play(), icon: Icon(video.value.isPlaying ? Icons.pause : Icons.play_arrow), label: Text(video.value.isPlaying ? 'إيقاف مؤقت' : 'تشغيل')),
        const SizedBox(height: 12), Text('${video.value.position.inMinutes}:${(video.value.position.inSeconds % 60).toString().padLeft(2, '0')} / ${video.value.duration.inMinutes}:${(video.value.duration.inSeconds % 60).toString().padLeft(2, '0')}', textAlign: TextAlign.center),
        if (video.value.hasError) const Text('حدث خطأ في التشغيل. جرّب فيديو MP4 بترميز يدعمه جهازك.'),
      ],
    ]))));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: ListView(padding: const EdgeInsets.all(24), children: [
    const SectionHeading('المظهر'),
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Row(children: [Icon(Icons.text_fields), SizedBox(width: 12), Text('حجم الخط')]),
      const SizedBox(height: 16),
      ListenableBuilder(listenable: uiPreferences, builder: (context, _) => Wrap(spacing: 8, children: [for (final item in [(.9, 'صغير'), (1.0, 'عادي'), (1.2, 'كبير')]) ChoiceChip(label: Text(item.$2), selected: uiPreferences.fontScale == item.$1, onSelected: (_) => uiPreferences.setScale(item.$1))])),
    ]))),
    const Card(child: ListTile(leading: Icon(Icons.language), title: Text('اللغة'), trailing: Text('العربية'))),
    const SectionHeading('عن التطبيق'),
    Card(child: ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('خصوصية بياناتك'), trailing: const Icon(Icons.chevron_left), onTap: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('خصوصية بياناتك'), content: const Text('بيانات الحساب والدورات تُحفظ في خدمة التطبيق عند الاتصال. التقدّم في المسارات الأساسية والملفات التجريبية وإعدادات الخط تُحفظ على جهازك. لا تشارك كلمة السر مع الآخرين.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))])))),
    Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('عن المحجة البيضاء'), trailing: const Icon(Icons.chevron_left), onTap: () => showAboutDialog(context: context, applicationName: brandName, applicationVersion: '1.0.0', applicationIcon: const Icon(Icons.auto_stories, color: brandPurple), children: [const Text('منصة لطلب العلم الشرعي، تضم الدورات والفيديوهات والمراجع وملفًا لتقدّم كل طالب.')]))),
    const SizedBox(height: 32), const Center(child: LogoMedallion(size: 160)),
  ]))));
}

class MaterialLibrary extends StatelessWidget {
  const MaterialLibrary({super.key, required this.academy, this.videos = false});
  final Academy academy;
  final bool videos;
  @override
  Widget build(BuildContext context) {
    final entries = [for (final course in academy.visibleCourses) for (final material in course.materials) if ((material.kind == 'video') == videos) (course, material)];
    return Scaffold(appBar: AppBar(title: Text(videos ? 'الفيديوهات' : 'المواد والمراجع')), body: ListenableBuilder(listenable: academy, builder: (context, _) => ListView(padding: const EdgeInsets.all(20), children: [
      if (entries.isEmpty) EmptyState(icon: videos ? Icons.play_circle_outline : Icons.folder_outlined, title: 'لا يوجد محتوى متاح بعد', description: 'ستظهر المواد المتاحة هنا عند إضافتها إلى الدورات.'),
      for (final entry in entries) Card(child: ListTile(leading: Icon(videos ? Icons.play_circle_outline : Icons.description_outlined, color: brandPink), title: Text(entry.$2.title), subtitle: Text(entry.$1.title), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => CourseScreen(academy: academy, courseId: entry.$1.id))))),
    ])));
  }
}
