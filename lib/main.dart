import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'learning_store.dart';
import 'models.dart';
import 'academy.dart';
import 'academy_ui.dart';

const forest = Color(0xff123e35);
const gold = Color(0xffd5b477);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AwnWasandApp());
}

class AwnWasandApp extends StatelessWidget {
  const AwnWasandApp({super.key, this.curriculum, this.store, this.academy});
  final Curriculum? curriculum;
  final LearningStore? store;
  final Academy? academy;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'عون وسند',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: forest),
      scaffoldBackgroundColor: const Color(0xfff7f8f3),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff7f8f3), foregroundColor: forest),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    ),
    home: curriculum != null && academy != null
      ? AcademyPortal(academy: academy!, learningBuilder: (store) => LearningHome(curriculum: curriculum!, store: store))
      : curriculum != null && store != null
      ? LearningHome(curriculum: curriculum!, store: store!)
      : const Bootstrap(),
  );
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  Curriculum? curriculum;
  Academy? academy;
  Object? error;

  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() => error = null);
    try {
      final data = Curriculum.decode(await rootBundle.loadString('assets/curriculum.json'));
      final saved = await Academy.load();
      if (!mounted) { saved.dispose(); return; }
      setState(() { curriculum = data; academy = saved; });
    } catch (e) { if (mounted) setState(() => error = e); }
  }

  @override
  void dispose() { academy?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (academy != null && curriculum != null) return AcademyPortal(academy: academy!, learningBuilder: (store) => LearningHome(curriculum: curriculum!, store: store));
    return Scaffold(body: Center(child: error == null
      ? const CircularProgressIndicator()
      : Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('تعذر تحميل المحتوى. حاول مجددًا.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: load, child: const Text('إعادة المحاولة')),
        ])));
  }
}

void message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

IconData trackIcon(String id) => switch (id) {
  'faith' => Icons.auto_awesome_outlined,
  'quran' => Icons.menu_book_outlined,
  'worship' => Icons.mosque_outlined,
  'hadith' => Icons.history_edu_outlined,
  'seerah' => Icons.route_outlined,
  _ => Icons.favorite_border,
};

class LearningHome extends StatefulWidget {
  const LearningHome({super.key, required this.curriculum, required this.store});
  final Curriculum curriculum;
  final LearningStore store;
  @override
  State<LearningHome> createState() => _LearningHomeState();
}

class _LearningHomeState extends State<LearningHome> {
  int selected = 0;
  String query = '';
  String? track;
  bool savedOnly = false;
  Curriculum get data => widget.curriculum;
  LearningStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    if (store.recoveredCorruptData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) message(context, 'تعذر قراءة بياناتك السابقة. احتُفظ بنسخة احتياطية محلية.');
      });
    }
  }

  void openLesson(Lesson lesson) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson, store: store)));
  void openTrack(LearningTrack item) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TrackScreen(track: item, lessons: data.forTrack(item.id), store: store)));

  Widget heading(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Text(text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)));
  Widget trackCards() => LayoutBuilder(builder: (context, constraints) {
    final columns = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 580 ? 2 : 1;
    final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
    return Wrap(spacing: 16, runSpacing: 16, children: data.tracks.map((t) => SizedBox(width: width, child: Card(
      margin: EdgeInsets.zero,
      child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => openTrack(t), child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(trackIcon(t.id), color: forest, size: 32),
        const SizedBox(height: 14), Text(t.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), Text(t.description), const SizedBox(height: 20),
        Text('${data.forTrack(t.id).where((l) => store.isDone(l.id)).length} / ${data.forTrack(t.id).length} دروس مكتملة', style: const TextStyle(color: forest)),
      ]))),
    ))).toList());
  });

  Widget home() {
    final next = data.lessons.firstWhere((l) => !store.isDone(l.id), orElse: () => data.lessons.first);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('رحلة علم تُضيء حياتك', style: TextStyle(color: gold)),
        const SizedBox(height: 16),
        const Text('تعلّم دينك.\nوابنِ أثرًا يدوم.', style: TextStyle(fontSize: 34, height: 1.5, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        const Text('دروس موثّقة في القرآن والسنة والعبادات والأخلاق. تعلّم، اختبر فهمك، وطبّق ما تعلمت.', style: TextStyle(color: Colors.white70, height: 1.8)),
        const SizedBox(height: 22),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: forest), onPressed: () => openLesson(next), icon: const Icon(Icons.arrow_forward), label: Text(store.completedCount == 0 ? 'ابدأ التعلم الآن' : 'تابع رحلتك')),
      ])),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: [metric('${data.tracks.length}', 'مسارات'), metric('${data.lessons.length}', 'دروس'), metric('${store.completedCount}', 'أنجزتها')]),
      heading('مسارات التعلم'), trackCards(),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('من العلم إلى العمل', style: TextStyle(fontWeight: FontWeight.bold, color: forest)),
        const SizedBox(height: 8), Text('خطوتك القادمة: ${next.title}'),
        const SizedBox(height: 8), const Text('اختر وقتًا قصيرًا يوميًا؛ الاستمرار يصنع الأثر.'),
      ]))),
      const Padding(padding: EdgeInsets.all(12), child: Text('المحتوى تمهيدي، يُراجع مع معلّم. المسائل الفقهية الخاصة تُعرض على أهل العلم.', style: TextStyle(fontSize: 12))),
    ]);
  }

  Widget metric(String value, String label) => Container(width: 110, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [Text(value, style: const TextStyle(fontSize: 28, color: forest, fontWeight: FontWeight.bold)), Text(label)]));

  Widget library() {
    final list = data.lessons.where((l) => (!savedOnly || store.bookmarks.contains(l.id)) && (track == null || l.track == track) && '${l.title} ${l.paragraphs.join(' ')}'.contains(query)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      heading('مكتبة الدروس'),
      TextField(decoration: const InputDecoration(labelText: 'ابحث عن درس أو موضوع', prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => query = value.trim())),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(value: track ?? 'all', decoration: const InputDecoration(labelText: 'المسار'), items: [const DropdownMenuItem(value: 'all', child: Text('كل المسارات')), ...data.tracks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))], onChanged: (value) => setState(() => track = value == 'all' ? null : value)),
      const SizedBox(height: 12),
      Align(alignment: AlignmentDirectional.centerStart, child: FilterChip(label: const Text('المحفوظات فقط'), selected: savedOnly, onSelected: (value) => setState(() => savedOnly = value))),
      const SizedBox(height: 12),
      if (list.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Text('لا توجد دروس مطابقة. جرّب بحثًا آخر أو احفظ درسًا للعودة إليه.')),
      ...list.map((l) => LessonTile(lesson: l, store: store, onTap: () => openLesson(l))),
    ]);
  }

  Future<void> editProfile() async {
    final controller = TextEditingController(text: store.name);
    var goal = store.dailyGoal;
    final accepted = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, change) => AlertDialog(
      title: const Text('ملفي وهدفي'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: controller, maxLength: 60, decoration: const InputDecoration(labelText: 'اسم المتعلم')),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(value: goal, decoration: const InputDecoration(labelText: 'دروس في اليوم'), items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} درس'))), onChanged: (value) => change(() => goal = value ?? 1)),
        const SizedBox(height: 12), const Text('ملف محلي على هذا الجهاز؛ لا يتطلب بريدًا أو كلمة مرور.', style: TextStyle(fontSize: 12)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ'))],
    )));
    if (accepted == true) {
      try { await store.updateProfile(controller.text, goal); }
      catch (_) { if (mounted) message(context, 'تعذر الحفظ. تأكد أن الاسم من حرفين إلى 60 حرفًا.'); }
    }
    // Dialog route finishes its exit animation before disposing its text controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }

  Future<void> reset() async {
    final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('حذف التقدم المحلي؟'), content: const Text('ستُحذف النتائج والمحفوظات والهدف من هذا الجهاز. لا يمكن التراجع.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))]));
    if (accepted == true) {
      try { await store.reset(); }
      catch (_) { if (mounted) message(context, 'تعذر حذف البيانات. حاول مجددًا.'); }
    }
  }

  Widget progressPage() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    heading('رحلتك يا ${store.name}'),
    Wrap(spacing: 12, runSpacing: 12, children: [metric('${store.completedCount}', 'مكتملة'), metric('${store.attempts}', 'محاولات'), metric('${store.bookmarks.length}', 'محفوظات')]),
    const SizedBox(height: 20),
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('الهدف اليومي: ${store.todayCount()} / ${store.dailyGoal} دروس'),
      const SizedBox(height: 12), LinearProgressIndicator(value: (store.todayCount() / store.dailyGoal).clamp(0.0, 1.0).toDouble()),
      const SizedBox(height: 12), const Text('تُحتسب الدروس التي اجتزت اختبارها اليوم، دون تكرار، بتوقيت جهازك.'),
      TextButton.icon(onPressed: editProfile, icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الاسم والهدف')),
    ]))),
    heading('تقدم المسارات'), trackCards(), heading('إنجازاتي'),
    ...data.tracks.where((t) => data.forTrack(t.id).every((l) => store.isDone(l.id))).map((t) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const Icon(Icons.workspace_premium_outlined, color: forest, size: 40),
      Text('أتممت مسار ${t.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(store.name), const Text('سجل إنجاز شخصي داخل التطبيق؛ ليس شهادة علمية معتمدة.', textAlign: TextAlign.center),
    ])))),
    if (!data.tracks.any((t) => data.forTrack(t.id).every((l) => store.isDone(l.id)))) const Text('أكمل مسارًا ليظهر سجل إنجازك هنا.'),
    const SizedBox(height: 24), const Text('بياناتك محفوظة محليًا. حذف التطبيق أو بيانات المتصفح قد يحذف تقدمك. لا توجد مزامنة بين الأجهزة.', style: TextStyle(fontSize: 12)),
    Align(alignment: AlignmentDirectional.centerStart, child: TextButton.icon(onPressed: reset, icon: const Icon(Icons.delete_outline), label: const Text('حذف بياناتي المحلية'))),
  ]);

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) => Scaffold(
    appBar: AppBar(title: const Text('عون وسند', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(onPressed: editProfile, tooltip: 'ملفي وهدفي', icon: const Icon(Icons.person_outline))]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: SingleChildScrollView(key: ValueKey(selected), padding: const EdgeInsets.all(20), child: selected == 0 ? home() : selected == 1 ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [heading('مسارات التعلم'), trackCards()]) : selected == 2 ? library() : progressPage()))),
    bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (value) => setState(() => selected = value), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
      NavigationDestination(icon: Icon(Icons.route_outlined), label: 'المسارات'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'المكتبة'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'تقدمي'),
    ]),
  ));
}

class LessonTile extends StatelessWidget {
  const LessonTile({super.key, required this.lesson, required this.store, required this.onTap});
  final Lesson lesson;
  final LearningStore store;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: Icon(store.isDone(lesson.id) ? Icons.check_circle : Icons.menu_book_outlined, color: forest), title: Text(lesson.title), subtitle: Text('${lesson.minutes} دقائق · ${store.isDone(lesson.id) ? 'مكتمل' : 'درس واختبار'}'), trailing: const Icon(Icons.chevron_left), onTap: onTap));
}

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key, required this.track, required this.lessons, required this.store});
  final LearningTrack track;
  final List<Lesson> lessons;
  final LearningStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (context, _) => Scaffold(appBar: AppBar(title: Text(track.title)), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView(padding: const EdgeInsets.all(20), children: [
    Text(track.description, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 20),
    ...lessons.map((l) => LessonTile(lesson: l, store: store, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: l, store: store))))),
  ])))));
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson, required this.store});
  final Lesson lesson;
  final LearningStore store;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late List<int?> answers;
  int? score;
  bool busy = false;
  @override
  void initState() { super.initState(); answers = List<int?>.filled(widget.lesson.questions.length, null); }

  Future<void> submit() async {
    if (answers.any((a) => a == null)) { message(context, 'أجب عن جميع الأسئلة أولًا'); return; }
    setState(() => busy = true);
    try {
      final result = await widget.store.submit(widget.lesson, answers.cast<int>());
      if (mounted) setState(() => score = result);
    } catch (_) { if (mounted) message(context, 'تعذر حفظ النتيجة. حاول مرة أخرى.'); }
    finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> openSource() async {
    try {
      final ok = await launchUrl(Uri.parse(widget.lesson.sourceUrl), mode: LaunchMode.externalApplication);
      if (!ok && mounted) message(context, 'تعذر فتح المصدر. تحقق من اتصالك بالإنترنت.');
    } catch (_) { if (mounted) message(context, 'تعذر فتح المصدر على هذا الجهاز.'); }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Scaffold(appBar: AppBar(title: Text(l.title), actions: [ListenableBuilder(listenable: widget.store, builder: (context, _) => IconButton(tooltip: 'حفظ الدرس', onPressed: () async {
      try { await widget.store.toggleBookmark(l.id); }
      catch (_) { if (context.mounted) message(context, 'تعذر حفظ الدرس'); }
    }, icon: Icon(widget.store.bookmarks.contains(l.id) ? Icons.bookmark : Icons.bookmark_border)))]), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView(padding: const EdgeInsets.all(24), children: [
      Text(l.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), Text('${l.minutes} دقائق · المستوى التمهيدي'), const SizedBox(height: 22),
      ...l.paragraphs.map((p) => Padding(padding: const EdgeInsets.only(bottom: 20), child: SelectableText(p, style: const TextStyle(fontSize: 18, height: 1.9)))),
      OutlinedButton.icon(onPressed: openSource, icon: const Icon(Icons.open_in_new), label: Text(l.source)),
      const SizedBox(height: 8), const Text('الشرح صياغة تعليمية. راجع النص الأصلي في المصدر المرتبط.', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 20), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('خطوة عملية', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(l.task)]))),
      const SizedBox(height: 24), Text('اختبر فهمك', style: Theme.of(context).textTheme.headlineSmall),
      const Text('يُكتمل الدرس عند تحقيق 70٪ على الأقل.'),
      ...List.generate(l.questions.length, (i) {
        final q = l.questions[i];
        return Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('${i + 1}. ${q.prompt}', style: const TextStyle(fontWeight: FontWeight.bold))),
          ...List.generate(q.options.length, (j) => RadioListTile<int>(value: j, groupValue: answers[i], onChanged: busy || score != null ? null : (value) => setState(() => answers[i] = value), title: Text(q.options[j]))),
          if (score != null) Padding(padding: const EdgeInsets.all(16), child: Text('${answers[i] == q.answer ? '✓' : '○'} ${q.explanation}\nالإجابة الصحيحة: ${q.options[q.answer]}', style: const TextStyle(color: forest))),
        ])));
      }),
      if (score == null) FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'جارٍ الحفظ…' : 'تحقق من إجاباتي')),
      if (score != null) ...[
        Text('$score٪ — ${score! >= 70 ? 'أحسنت! حُفظ إنجازك.' : 'راجع الدرس وحاول مجددًا.'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16), OutlinedButton(onPressed: () => setState(() { score = null; answers = List<int?>.filled(l.questions.length, null); }), child: const Text('إعادة الاختبار')),
      ],
      const SizedBox(height: 30),
    ]))));
  }
}
