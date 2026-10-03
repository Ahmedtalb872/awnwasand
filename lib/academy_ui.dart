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

const academyGreen = brandPurple;
const academyGold = brandPink;
void showMessage(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
String friendlyError(Object error) {
  if (error is AuthException) {
    if (error.code == 'phone_provider_disabled' || error.message.toLowerCase().contains('phone provider')) return 'التسجيل برقم الهاتف غير مفعّل بعد. يجب تفعيل Phone في إعدادات Supabase.';
    if (error.code == 'phone_not_confirmed') return 'تأكيد الهاتف مفعّل على الخادم. تواصل مع الإدارة لتجهيز الدخول برقم الهاتف وكلمة السر.';
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
  const WelcomeScreen({super.key, required this.academy});
  final Academy academy;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), phone = TextEditingController(), password = TextEditingController();
  bool register = false, busy = false;
  String? error;
  @override
  void dispose() { name.dispose(); phone.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    try {
      if (widget.academy.isDemo || register) {
        final active = await widget.academy.signUp(name.text, phone.text, password.text);
        if (!active && mounted) setState(() => error = 'أُنشئ الحساب، لكن تأكيد الهاتف مفعّل على الخادم. تواصل مع الإدارة لتجهيز الدخول برقم الهاتف وكلمة السر.');
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
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1160), child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    BrandPanel(child: Column(children: [
      const BrandLogo(), const SizedBox(height: 24),
      const Text('ابدأ رحلتك في طلب العلم', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.5)),
      const SizedBox(height: 16),
      const Text('منصة تعليمية للعلوم الشرعية. تعلّم من الدروس والدورات، وتابع تقدّمك، واحتفظ بمراجعك في مكان واحد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.8)),
      const SizedBox(height: 24),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: brandPink, foregroundColor: brandPurple), onPressed: busy ? null : () => setState(() { register = true; error = null; }), icon: const Icon(Icons.person_add_alt_1), label: const Text('إنشاء حساب')),
        OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)), onPressed: busy ? null : () => setState(() { register = false; error = null; }), icon: const Icon(Icons.login), label: const Text('تسجيل الدخول')),
      ]),
    ])),
    const SizedBox(height: 22),
    Wrap(alignment: WrapAlignment.center, spacing: 16, runSpacing: 12, children: const [Feature(icon: Icons.person_outline, title: 'ملف لكل طالب'), Feature(icon: Icons.play_circle_outline, title: 'دورات وفيديوهات'), Feature(icon: Icons.folder_outlined, title: 'مراجع ومرفقات')]),
    const SizedBox(height: 24),
    if (widget.academy.isDemo) const DemoNotice(),
    if (widget.academy.setupIssue != null) Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Icon(Icons.construction_outlined, color: academyGreen),
      Text(widget.academy.setupIssue!, textAlign: TextAlign.center),
      TextButton(onPressed: busy ? null : () async {
        setState(() => busy = true);
        await widget.academy.checkSchema();
        if (mounted) setState(() => busy = false);
      }, child: const Text('التحقق مجددًا')),
    ]))),
    Align(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.academy.isDemo ? 'أنشئ ملف طالب للتجربة' : register ? 'أنشئ حساب الطالب' : 'مرحبًا بعودتك', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 20),
      if (widget.academy.isDemo || register) TextFormField(controller: name, maxLength: 60, decoration: const InputDecoration(labelText: 'اسم الطالب'), validator: (value) => (value?.trim().length ?? 0) < 2 ? 'أدخل اسمًا من حرفين على الأقل' : null),
      if (!widget.academy.isDemo) ...[
        const SizedBox(height: 12), TextFormField(controller: phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, autofillHints: const [AutofillHints.telephoneNumber], decoration: const InputDecoration(labelText: 'رقم الهاتف', hintText: '+212612345678', helperText: 'أدخل رمز البلد قبل الرقم، مثل +212'), validator: (value) { try { Academy.normalizePhone(value ?? ''); return null; } on ArgumentError catch (e) { return e.message.toString(); } }),
        const SizedBox(height: 16), TextFormField(controller: password, obscureText: true, autofillHints: [register ? AutofillHints.newPassword : AutofillHints.password], decoration: const InputDecoration(labelText: 'كلمة السر'), validator: (value) => (value?.length ?? 0) < 8 ? '8 أحرف على الأقل' : null),
      ],
      if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 16), FilledButton(onPressed: busy || widget.academy.setupIssue != null ? null : submit, child: Text(busy ? 'جارٍ المتابعة…' : widget.academy.isDemo ? 'إنشاء ملف وبدء التعلم' : register ? 'إنشاء حساب' : 'تسجيل الدخول')),
      if (!widget.academy.isDemo) TextButton(onPressed: busy ? null : () => setState(() { register = !register; error = null; }), child: Text(register ? 'لدي حساب بالفعل' : 'ليس لدي حساب؛ إنشاء حساب')),
      if (widget.academy.isDemo) ...[
        const SizedBox(height: 16),
        for (final student in widget.academy.students) OutlinedButton.icon(onPressed: busy ? null : () => select(student.id), icon: const Icon(Icons.person_outline), label: Text('متابعة ملف ${student.name}')),
        const Divider(height: 28), OutlinedButton.icon(onPressed: busy ? null : () => select('demo-admin'), icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('تجربة لوحة الإدارة')),
      ],
    ])))))),
    const SizedBox(height: 24), const Text('نتعلّم لنرتقي · محتوى تمهيدي يُراجع مع معلّم', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
  ]))))));
}

class Feature extends StatelessWidget {
  const Feature({super.key, required this.icon, required this.title});
  final IconData icon; final String title;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffe9e3e6))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 22, color: academyGreen), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))]),
  );
}
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xfffff0cc), borderRadius: BorderRadius.circular(12)), child: const Text('نسخة تجريبية: ملفات الطلاب والدورات والمرفقات محفوظة على هذا الجهاز فقط. لوحة الإدارة هنا متاحة للتجربة؛ المشاركة بين الأجهزة تحتاج ربط الخدمة السحابية.', style: TextStyle(fontSize: 12)));
}

class StudentArea extends StatefulWidget {
  const StudentArea({super.key, required this.academy, required this.learningBuilder});
  final Academy academy; final Widget Function(LearningStore) learningBuilder;
  @override
  State<StudentArea> createState() => _StudentAreaState();
}
class _StudentAreaState extends State<StudentArea> {
  int selected = 0;
  LearningStore? learning;
  String search = '';
  bool loading = false;
  Academy get academy => widget.academy;
  @override
  void initState() { super.initState(); loadLearning(); }
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
  Widget title(String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)));
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
    final count = course.materials.length;
    final completed = enrollment?.completed.length ?? 0;
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => openCourse(course), child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      Container(width: 58, height: 66, decoration: BoxDecoration(color: const Color(0xfff5e1e4), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.menu_book_outlined, color: academyGreen, size: 30)),
      const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(course.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 6),
        Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8),
        Text('${course.level} · ${course.teacher}', style: const TextStyle(fontSize: 12)),
        if (enrollment != null) ...[const SizedBox(height: 12), LinearProgressIndicator(value: count == 0 ? 0 : (completed / count).clamp(0.0, 1.0).toDouble()), const SizedBox(height: 6), Text('$completed / $count مواد مكتملة', style: const TextStyle(fontSize: 12))],
      ])), const SizedBox(width: 8), const Icon(Icons.chevron_left, color: academyGreen),
    ]))));
  }
  Widget home() {
    final enrolled = academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).toList();
    final next = enrolled.where((c) => academy.enrollment(c.id)!.completed.length < c.materials.length).firstOrNull;
    final progress = next == null || next.materials.isEmpty ? 0.0 : (academy.enrollment(next.id)!.completed.length / next.materials.length).clamp(0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      title('السلام عليكم، ${academy.user!.name}'),
      const Text('بارك الله في طلبك للعلم، ووفّقك لما يحب ويرضى.'), const SizedBox(height: 20),
      BrandPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const Icon(Icons.menu_book, color: academyGold), const SizedBox(width: 10), Expanded(child: Text(academy.isAdmin ? 'إدارة رحلات التعلّم' : 'تابع تعلّمك', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 20), Text(next?.title ?? 'خطوة جديدة نحو العلم', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10), Text(academy.isAdmin ? 'أضف دورة، جهّز موادها، ثم انشرها للطلاب.' : next?.description ?? 'انضم إلى دورة أو تابع مساراتك التعليمية.', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.7)),
        if (next != null) ...[const SizedBox(height: 18), LinearProgressIndicator(value: progress), const SizedBox(height: 8), Text('${(progress * 100).round()}% مكتمل', style: const TextStyle(color: Colors.white))],
        const SizedBox(height: 20), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: academyGold, foregroundColor: academyGreen), onPressed: () { if (next != null && !academy.isAdmin) { openCourse(next); } else { setState(() => selected = academy.isAdmin ? 3 : 1); } }, icon: const Icon(Icons.arrow_forward), label: Text(academy.isAdmin ? 'فتح لوحة الإدارة' : next != null ? 'متابعة الدورة' : 'استكشف الدورات')),
      ])),
      title('مساراتك الأساسية'),
      Card(child: ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('القرآن والسنة والعبادات والأخلاق'), subtitle: Text('${learning?.completedCount ?? 0} من 12 درسًا مكتملًا على هذا الجهاز'), trailing: const Icon(Icons.chevron_left), onTap: learning == null ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => widget.learningBuilder(learning!))))),
      title('الدورات المتاحة'), ...academy.visibleCourses.map(courseCard),
      if (academy.visibleCourses.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('ستظهر الدورات هنا عندما ينشرها المشرف.'))),
    ]);
  }
  Widget coursesPage() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [title('الدورات التعليمية'), TextField(decoration: const InputDecoration(labelText: 'ابحث عن دورة', prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => search = value.trim())), const SizedBox(height: 14),
    ...academy.visibleCourses.where((c) => '${c.title} ${c.description} ${c.teacher}'.contains(search)).map(courseCard),
    if (!academy.visibleCourses.any((c) => '${c.title} ${c.description} ${c.teacher}'.contains(search))) const Padding(padding: EdgeInsets.all(30), child: Text('لا توجد دورات مطابقة حاليًا.')),
  ]);
  Widget profilePage() {
    final user = academy.user!;
    final entries = academy.enrollments.where((e) => e.studentId == user.id).toList();
    final total = academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).fold<int>(0, (n, c) => n + c.materials.length);
    final completed = entries.fold<int>(0, (n, e) => n + e.completed.length);
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      title('ملف الطالب'), Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        CircleAvatar(radius: 42, backgroundColor: academyGreen, child: Text(user.name.substring(0, 1), style: const TextStyle(fontSize: 38, color: Colors.white))), const SizedBox(height: 12),
        Text(user.name, style: Theme.of(context).textTheme.headlineSmall), if (user.phone.isNotEmpty) Text(user.phone, textDirection: TextDirection.ltr), Text('المستوى: ${user.level}'), if (user.bio.isNotEmpty) Text(user.bio),
        TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProfileEditor(academy: academy))), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل ملفي')),
      ]))),
      const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 12, children: [Feature(icon: Icons.school_outlined, title: '${entries.length} دورات'), Feature(icon: Icons.task_alt, title: '${entries.fold<int>(0, (n,e) => n + e.completed.length)} مواد أنجزتها')]),
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('تقدّمك الدراسي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        LinearProgressIndicator(value: progress, minHeight: 8), const SizedBox(height: 10),
        Text(total == 0 ? 'ابدأ بدورة لتتابع تقدّمك هنا.' : '${(progress * 100).round()}% · $completed من $total مواد مكتملة'),
      ]))),
      title('الدورات المسجّل بها'), ...academy.visibleCourses.where((c) => academy.enrollment(c.id) != null).map(courseCard),
      const SizedBox(height: 16), Text(academy.isDemo ? 'هذا الملف تجريبي ومحفوظ على جهازك.' : 'ملفك والدورات المسجّل بها محفوظة في حسابك. نتائج المسارات الأساسية محفوظة على هذا الجهاز.', style: const TextStyle(fontSize: 12)),
    ]);
  }
  Widget adminPage() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    title('لوحة الإدارة'), const Align(alignment: AlignmentDirectional.centerStart, child: Chip(avatar: Icon(Icons.verified_user_outlined, size: 18), label: Text('المشرف'))),
    Wrap(spacing: 12, runSpacing: 12, children: [Feature(icon: Icons.school_outlined, title: '${academy.courses.length} دورات'), Feature(icon: Icons.people_outline, title: '${academy.students.length} طلاب'), Feature(icon: Icons.folder_outlined, title: '${academy.courses.fold<int>(0, (n,c) => n+c.materials.length)} مواد')]),
    const SizedBox(height: 18), FilledButton.icon(onPressed: () => editCourse(), icon: const Icon(Icons.add), label: const Text('إضافة دورة جديدة')),
    title('إدارة الدورات'),
    for (final course in academy.courses) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('${course.published ? 'منشورة للطلاب' : 'مسودة'} · ${course.materials.length} مواد'),
      Wrap(spacing: 8, children: [TextButton.icon(onPressed: () => openCourse(course), icon: const Icon(Icons.upload_file_outlined), label: const Text('الفيديوهات والملفات')), TextButton.icon(onPressed: () => editCourse(course), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الدورة')), TextButton.icon(onPressed: loading ? null : () async {
        final yes = await confirm(context, 'حذف الدورة؟', 'ستُحذف الدورة وموادها وتسجيلات الطلاب بها.');
        if (yes) await action(() => academy.deleteCourse(course));
      }, icon: const Icon(Icons.delete_outline), label: const Text('حذف'))]),
    ]))),
    title('ملفات الطلاب'),
    if (academy.students.isEmpty) const Text('لا توجد ملفات طلاب بعد.'),
    for (final student in academy.students) Card(child: ListTile(leading: const Icon(Icons.person_outline), title: Text(student.name), subtitle: Text('${student.level} · ${academy.enrollments.where((e) => e.studentId == student.id).length} دورات'), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => StudentDetails(academy: academy, student: student))))),
  ]);
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: academy, builder: (context, _) {
    if (academy.user == null) return const SizedBox.shrink();
    return Scaffold(appBar: AppBar(title: const BrandHeading(), actions: [IconButton(tooltip: 'تحديث', onPressed: loading ? null : () => action(academy.refresh), icon: const Icon(Icons.refresh)), IconButton(tooltip: 'تسجيل الخروج', onPressed: loading ? null : () => action(academy.signOut), icon: const Icon(Icons.logout))]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: SingleChildScrollView(key: ValueKey(selected), padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [if (academy.isDemo) const DemoNotice(), if (loading) const LinearProgressIndicator(), selected == 0 ? home() : selected == 1 ? coursesPage() : selected == 2 ? profilePage() : adminPage()])))),
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
