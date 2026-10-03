import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'academy_models.dart';
import 'media_store.dart';

class Academy extends ChangeNotifier {
  Academy(this.preferences, {this.client, MediaStore? media}) : media = media ?? MediaStore();
  static const localKey = 'awnwasand.academy.v1';
  static bool _supabaseInitialized = false;
  static const maxUploadSize = 50 * 1024 * 1024;
  final SharedPreferences preferences;
  final SupabaseClient? client;
  final MediaStore media;
  StreamSubscription<AuthState>? _auth;
  bool get isDemo => client == null;
  StudentProfile? user;
  List<StudentProfile> students = [];
  List<AcademyCourse> courses = [];
  List<Enrollment> enrollments = [];
  String? setupIssue;
  List<AcademyCourse> get visibleCourses => courses.where((c) => user?.isAdmin == true || c.published).toList();
  bool get isAdmin => user?.isAdmin ?? false;
  Enrollment? enrollment(String courseId, [String? studentId]) {
    final matches = enrollments.where((e) => e.courseId == courseId && e.studentId == (studentId ?? user?.id));
    return matches.isEmpty ? null : matches.first;
  }

  static Future<Academy> load() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    SupabaseClient? client;
    if (url.isNotEmpty || key.isNotEmpty) {
      if (url.isEmpty || key.isEmpty) throw StateError('إعدادات الخدمة غير مكتملة');
      if (!_supabaseInitialized) {
        await Supabase.initialize(url: url, publishableKey: key);
        _supabaseInitialized = true;
      }
      client = Supabase.instance.client;
    }
    final academy = Academy(await SharedPreferences.getInstance(), client: client);
    await academy.restore();
    if (client != null) {
      academy._auth = client.auth.onAuthStateChange.listen((event) {
        if (event.event == AuthChangeEvent.signedOut) {
          academy.user = null;
          academy.courses = [];
          academy.students = [];
          academy.enrollments = [];
          academy.notifyListeners();
        }
      });
    }
    return academy;
  }

  Future<void> restore() async {
    if (!isDemo) {
      await checkSchema();
      if (setupIssue == null) await refresh();
      return;
    }
    final raw = preferences.getString(localKey);
    if (raw == null) {
      courses = [AcademyCourse(id: const Uuid().v4(), title: 'مدخل إلى القرآن الكريم', description: 'دورة تمهيدية لآداب التلاوة والتدبر. يستطيع المشرف إضافة دروس الفيديو والمرفقات هنا.', teacher: 'فريق عون وسند', published: true)];
      return;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    students = (json['students'] as List).map((x) => StudentProfile.fromJson(Map<String, dynamic>.from(x as Map))).toList();
    courses = (json['courses'] as List).map((x) => AcademyCourse.fromJson(Map<String, dynamic>.from(x as Map))).toList();
    enrollments = (json['enrollments'] as List).map((x) => Enrollment.fromJson(Map<String, dynamic>.from(x as Map))).toList();
    final active = json['active'] as String?;
    if (active == 'demo-admin') {
      user = const StudentProfile(id: 'demo-admin', name: 'المشرف التجريبي', role: 'admin');
    } else {
      final matches = students.where((s) => s.id == active);
      user = matches.isEmpty ? null : matches.first;
    }
  }

  Future<void> checkSchema() async {
    if (isDemo) return;
    setupIssue = null;
    for (final entry in {'profiles':'id', 'courses':'id', 'course_materials':'id', 'enrollments':'course_id'}.entries) {
      try {
        await client!.from(entry.key).select(entry.value).limit(1);
      } on PostgrestException catch (error) {
        if (error.code == '42501') continue; // Private tables deny anonymous reads.
        setupIssue = 'المنصة متصلة، لكن تجهيز الحسابات والدورات لم يكتمل بعد. يُرجى المحاولة لاحقًا.';
        break;
      } catch (_) {
        setupIssue = 'تعذر الاتصال بخدمة الحسابات. تحقق من اتصالك ثم حاول مجددًا.';
        break;
      }
    }
    notifyListeners();
  }

  Future<void> persist() async {
    if (isDemo) {
      final ok = await preferences.setString(localKey, jsonEncode({
        'students': students.map((s) => s.toJson()).toList(),
        'courses': courses.map((c) => c.toJson(withMaterials: true)).toList(),
        'enrollments': enrollments.map((e) => e.toJson()).toList(), 'active': user?.id,
      }));
      if (!ok) throw StateError('تعذر حفظ البيانات على الجهاز');
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    if (isDemo) { notifyListeners(); return; }
    final id = client!.auth.currentUser?.id;
    if (id == null) { user = null; notifyListeners(); return; }
    final profile = await client!.from('profiles').select().eq('id', id).single();
    user = StudentProfile.fromJson(profile);
    courses = (await client!.from('courses').select('*,course_materials(*)').order('created_at', ascending: false)).map(AcademyCourse.fromJson).toList();
    enrollments = (await client!.from('enrollments').select()).map(Enrollment.fromJson).toList();
    students = isAdmin
      ? (await client!.from('profiles').select().eq('role', 'student').order('name')).map(StudentProfile.fromJson).toList()
      : [user!];
    notifyListeners();
  }

  Future<bool> signUp(String name, String email, String password) async {
    if (setupIssue != null) throw StateError(setupIssue!);
    if (name.trim().length < 2 || name.trim().length > 60) throw ArgumentError('أدخل اسمًا من حرفين إلى 60 حرفًا');
    if (isDemo) {
      final profile = StudentProfile(id: const Uuid().v4(), name: name.trim());
      students.add(profile); user = profile; await persist(); return true;
    }
    if (password.length < 8) throw ArgumentError('كلمة المرور لا تقل عن 8 أحرف');
    final response = await client!.auth.signUp(email: email.trim(), password: password, data: {'name': name.trim()});
    if (response.session == null) return false;
    await refresh(); return true;
  }

  Future<void> signIn(String email, String password) async {
    if (setupIssue != null) throw StateError(setupIssue!);
    if (isDemo) throw StateError('استخدم اختيار الملف التجريبي');
    await client!.auth.signInWithPassword(email: email.trim(), password: password);
    await refresh();
  }

  Future<void> selectDemo(String id) async {
    if (!isDemo) throw StateError('غير متاح في النسخة المتصلة');
    user = id == 'demo-admin' ? const StudentProfile(id: 'demo-admin', name: 'المشرف التجريبي', role: 'admin') : students.firstWhere((s) => s.id == id);
    await persist();
  }

  Future<void> signOut() async {
    if (!isDemo) await client!.auth.signOut();
    user = null; await persist();
  }

  Future<void> saveProfile(String name, String level, String bio) async {
    if (user == null) throw StateError('سجل الدخول أولًا');
    if (name.trim().length < 2 || name.length > 60 || bio.length > 1000) throw ArgumentError('تحقق من الاسم والنبذة');
    if (!isDemo) {
      await client!.from('profiles').update({'name': name.trim(), 'level': level, 'bio': bio.trim()}).eq('id', user!.id);
      await refresh(); return;
    }
    user = StudentProfile(id: user!.id, name: name.trim(), email: user!.email, level: level, bio: bio.trim(), role: user!.role);
    students = students.map((s) => s.id == user!.id ? user! : s).toList(); await persist();
  }

  void requireAdmin() { if (!isAdmin) throw StateError('هذه العملية للمشرف فقط'); }
  static void validateCourse(AcademyCourse course) {
    if (course.title.trim().length < 3 || course.title.length > 120 || course.description.trim().length < 10 || course.description.length > 5000 || course.teacher.length > 120) {
      throw ArgumentError('اسم الدورة من 3 إلى 120 حرفًا، ووصفها من 10 إلى 5000 حرف');
    }
  }
  Future<void> saveCourse(AcademyCourse course) async {
    requireAdmin(); validateCourse(course);
    if (!isDemo) { await client!.from('courses').upsert(course.toJson()); await refresh(); return; }
    final matches = courses.where((c) => c.id == course.id);
    final materials = matches.isEmpty ? <CourseMaterial>[] : matches.first.materials;
    courses = [course.withMaterials(materials), ...courses.where((c) => c.id != course.id)]; await persist();
  }
  Future<void> deleteCourse(AcademyCourse course) async {
    requireAdmin();
    if (!isDemo) {
      await client!.from('courses').delete().eq('id', course.id);
      await refresh();
      if (course.materials.isNotEmpty) await client!.storage.from('course-media').remove(course.materials.map((m) => m.path).toList());
      return;
    }
    courses.removeWhere((c) => c.id == course.id);
    enrollments.removeWhere((e) => e.courseId == course.id);
    await persist();
    for (final m in course.materials) { await media.remove(m.path); }
  }

  static String mimeFor(String name) => switch (name.split('.').last.toLowerCase()) {
    'mp4' => 'video/mp4', 'mov' => 'video/quicktime', 'webm' => 'video/webm',
    'pdf' => 'application/pdf', 'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'png' => 'image/png', 'jpg' || 'jpeg' => 'image/jpeg',
    _ => throw ArgumentError('نوع الملف غير مدعوم'),
  };
  static void validateUpload(String name, Uint8List bytes) {
    mimeFor(name);
    if (bytes.isEmpty || bytes.length > maxUploadSize) throw ArgumentError('اختر ملفًا لا يتجاوز 50 ميجابايت');
  }
  Future<void> upload(String courseId, String title, String fileName, Uint8List bytes) async {
    requireAdmin(); validateUpload(fileName, bytes);
    if (title.trim().isEmpty || title.length > 160) throw ArgumentError('أدخل عنوانًا للمادة');
    final course = courses.firstWhere((c) => c.id == courseId);
    final id = const Uuid().v4(), mime = mimeFor(fileName);
    final path = isDemo ? id : '$courseId/$id.${fileName.split('.').last.toLowerCase()}';
    final item = CourseMaterial(id: id, courseId: courseId, title: title.trim(), fileName: fileName, kind: mime.startsWith('video/') ? 'video' : 'file', mime: mime, size: bytes.length, path: path);
    if (!isDemo) {
      await client!.storage.from('course-media').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mime));
      try { await client!.from('course_materials').insert(item.toJson()); }
      catch (_) { await client!.storage.from('course-media').remove([path]); rethrow; }
      await refresh(); return;
    }
    await media.put(path, bytes);
    courses = courses.map((c) => c.id == courseId ? course.withMaterials([...course.materials, item]) : c).toList();
    await persist();
  }
  Future<void> deleteMaterial(CourseMaterial item) async {
    requireAdmin();
    if (!isDemo) {
      await client!.from('course_materials').delete().eq('id', item.id); await refresh();
      await client!.storage.from('course-media').remove([item.path]); return;
    }
    courses = courses.map((c) => c.withMaterials(c.materials.where((m) => m.id != item.id).toList())).toList();
    await persist(); await media.remove(item.path);
  }
  Future<void> enroll(String courseId) async {
    if (user == null || isAdmin) throw StateError('الدخول كطالب مطلوب');
    if (!courses.any((c) => c.id == courseId && c.published)) throw StateError('الدورة غير منشورة');
    if (enrollment(courseId) != null) return;
    final entry = Enrollment(studentId: user!.id, courseId: courseId);
    if (!isDemo) { await client!.from('enrollments').insert(entry.toJson()); await refresh(); return; }
    enrollments.add(entry); await persist();
  }
  Future<void> completeMaterial(CourseMaterial item) async {
    final current = enrollment(item.courseId);
    if (current == null) throw StateError('انضم إلى الدورة أولًا');
    final updated = Enrollment(studentId: current.studentId, courseId: current.courseId, completed: {...current.completed, item.id}.toList());
    if (!isDemo) {
      await client!.from('enrollments').update({'completed_materials': updated.completed}).eq('student_id', user!.id).eq('course_id', item.courseId);
      await refresh(); return;
    }
    enrollments = enrollments.map((e) => e.studentId == updated.studentId && e.courseId == updated.courseId ? updated : e).toList(); await persist();
  }
  void requireMaterialAccess(CourseMaterial item) {
    final course = courses.firstWhere((c) => c.id == item.courseId);
    if (!isAdmin && (!course.published || enrollment(course.id) == null)) throw StateError('انضم إلى الدورة للوصول للمادة');
  }
  Future<String> videoUrl(CourseMaterial item) async {
    requireMaterialAccess(item);
    return isDemo ? media.videoUrl(item.path, item.mime) : client!.storage.from('course-media').createSignedUrl(item.path, 3600);
  }
  Future<void> openFile(CourseMaterial item) async {
    requireMaterialAccess(item);
    if (isDemo) { await media.open(item.path, item.fileName, item.mime); return; }
    final url = await client!.storage.from('course-media').createSignedUrl(item.path, 300);
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) throw StateError('تعذر فتح الملف');
  }
  @override
  void dispose() { _auth?.cancel(); super.dispose(); }
}
