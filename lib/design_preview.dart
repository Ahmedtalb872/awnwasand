// Isolated visual preview. Sample data never reaches the connected application.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'academy.dart';
import 'academy_models.dart';
import 'academy_ui.dart';
import 'brand.dart';
import 'ui_preferences.dart';
import 'main.dart' show LearningHome;
import 'models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final screen = Uri.base.queryParameters['screen'] ?? 'welcome';
  final academy = Academy(preferences);
  await academy.restore();
  final curriculum = Curriculum.decode(await rootBundle.loadString('assets/curriculum.json'));
  Widget home;
  if (screen == 'splash') {
    home = const BrandedSplash();
  } else if (screen == 'settings') {
    home = const SettingsScreen();
  } else if (screen == 'welcome') {
    home = WelcomeScreen(academy: academy);
  } else if (screen == 'signup' || screen == 'login') {
    // No live credentials or requests are used by the signup screenshot.
    home = WelcomeScreen(academy: Academy(preferences, client: SupabaseClient('https://preview.invalid', 'preview-only')), startWithAuth: true, initialRegister: screen == 'signup');
  } else {
    academy.students = const [StudentProfile(id: 'preview-student', name: 'أحمد محمد'), StudentProfile(id: 'preview-student-2', name: 'يوسف أحمد')];
    academy.user = screen == 'admin' ? const StudentProfile(id: 'preview-admin', name: 'المشرف', role: 'admin') : academy.students.first;
    academy.courses = [
      AcademyCourse(id: 'preview-fiqh', title: 'مدخل إلى الفقه', description: 'تعرّف إلى مبادئ الفقه وآداب طلب العلم، خطوة بخطوة.', teacher: 'فريق المحجة البيضاء', published: true, materials: [for (var i = 0; i < 3; i++) CourseMaterial(id: 'preview-material-$i', courseId: 'preview-fiqh', title: 'الدرس ${i + 1}', fileName: 'lesson.pdf', kind: 'file', mime: 'application/pdf', size: 1024, path: 'preview/$i.pdf')]),
      const AcademyCourse(id: 'preview-quran', title: 'علوم القرآن', description: 'تأمل معاني القرآن، وتعرّف إلى أصول التفسير وآداب التلاوة.', teacher: 'فريق المحجة البيضاء', published: true),
      const AcademyCourse(id: 'preview-seerah', title: 'السيرة النبوية', description: 'محطات من السيرة، ودروس نستضيء بها في حياتنا.', teacher: 'فريق المحجة البيضاء', published: true),
    ];
    academy.enrollments = const [Enrollment(studentId: 'preview-student', courseId: 'preview-fiqh', completed: ['preview-material-0'])];
    home = screen == 'materials' ? MaterialLibrary(academy: academy) : StudentArea(academy: academy, initialSelected: screen == 'profile' ? 2 : screen == 'admin' ? 3 : screen == 'courses' ? 1 : 0, learningBuilder: (store) => LearningHome(curriculum: curriculum, store: store));
  }
  runApp(ListenableBuilder(listenable: uiPreferences, builder: (context, _) => MaterialApp(builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(uiPreferences.fontScale)), child: child!),debugShowCheckedModeBanner: false, theme: academyTheme(), locale: const Locale('ar'), supportedLocales: const [Locale('ar')], localizationsDelegates: GlobalMaterialLocalizations.delegates, home: home)));
}
