import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awnwasand/academy.dart';
import 'package:awnwasand/academy_models.dart';
import 'package:awnwasand/learning_store.dart';
import 'package:awnwasand/media_store.dart';

class MemoryMedia extends MediaStore {
  final files = <String, Uint8List>{};
  @override
  Future<void> put(String id, Uint8List bytes) async { files[id] = bytes; }
  @override
  Future<Uint8List> read(String id) async => files[id]!;
  @override
  Future<void> remove(String id) async { files.remove(id); }
  @override
  Future<String> videoUrl(String id, String mime) async => 'memory:$id';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<Academy> academy() async {
    final instance = Academy(await SharedPreferences.getInstance(), media: MemoryMedia());
    await instance.restore();
    addTearDown(instance.dispose);
    return instance;
  }
  test('student cannot create courses or upload materials', () async {
    final repo = await academy();
    await repo.signUp('طالب أول', '', '');
    await expectLater(repo.saveCourse(const AcademyCourse(id: 'test', title: 'دورة جديدة', description: 'وصف تعليمي للدورة')), throwsStateError);
    await expectLater(repo.upload(repo.courses.first.id, 'ملف', 'lesson.pdf', Uint8List.fromList([1,2])), throwsStateError);
  });
  test('admin creates, edits, publishes and persists course materials', () async {
    final repo = await academy();
    await repo.selectDemo('demo-admin');
    const course = AcademyCourse(id: 'test-course', title: 'دورة السيرة', description: 'محطات تعليمية من السيرة النبوية', published: false);
    await repo.saveCourse(course);
    await repo.upload(course.id, 'مرجع الدرس', 'lesson.pdf', Uint8List.fromList([37,80,68,70]));
    final saved = repo.courses.firstWhere((c) => c.id == course.id);
    expect(saved.materials.length, 1);
    expect((repo.media as MemoryMedia).files.length, 1);
    await repo.saveCourse(AcademyCourse(id: saved.id, title: saved.title, description: saved.description, published: true));
    expect(repo.courses.first.materials.length, 1);
    final restored = await academy();
    expect(restored.courses.first.published, isTrue);
    expect(restored.courses.first.materials.first.title, 'مرجع الدرس');
  });
  test('student enrollment, material access and progress are isolated', () async {
    final repo = await academy();
    await repo.selectDemo('demo-admin');
    final id = repo.courses.first.id;
    await repo.upload(id, 'درس فيديو', 'lesson.mp4', Uint8List.fromList([1,2,3]));
    final material = repo.courses.first.materials.first;
    await repo.signUp('طالب أول', '', '');
    final first = repo.user!.id;
    expect(() => repo.requireMaterialAccess(material), throwsStateError);
    await repo.enroll(id);
    repo.requireMaterialAccess(material);
    await repo.completeMaterial(material);
    await repo.completeMaterial(material);
    expect(repo.enrollment(id)!.completed.length, 1);
    await repo.signUp('طالب ثان', '', '');
    expect(repo.enrollment(id), isNull);
    expect(() => repo.requireMaterialAccess(material), throwsStateError);
    await repo.selectDemo(first);
    expect(repo.enrollment(id)!.completed, [material.id]);
  });
  test('draft courses cannot be enrolled in by students', () async {
    final repo = await academy();
    await repo.selectDemo('demo-admin');
    await repo.saveCourse(const AcademyCourse(id: 'draft', title: 'دورة غير منشورة', description: 'وصف دورة في طور الإعداد'));
    await repo.signUp('طالب جديد', '', '');
    expect(repo.visibleCourses.any((c) => c.id == 'draft'), isFalse);
    await expectLater(repo.enroll('draft'), throwsStateError);
  });
  test('file validation rejects unsafe extensions and empty content', () {
    expect(() => Academy.validateUpload('attack.html', Uint8List.fromList([1])), throwsArgumentError);
    expect(() => Academy.validateUpload('lesson.pdf', Uint8List(0)), throwsArgumentError);
    expect(Academy.mimeFor('lesson.MP4'), 'video/mp4');
  });
  test('deleting a course removes registrations and its binary files', () async {
    final repo = await academy();
    await repo.selectDemo('demo-admin');
    final id = repo.courses.first.id;
    await repo.upload(id, 'ملف الدرس', 'lesson.pdf', Uint8List.fromList([1,2]));
    await repo.signUp('طالب جديد', '', '');
    await repo.enroll(id);
    await repo.selectDemo('demo-admin');
    await repo.deleteCourse(repo.courses.first);
    expect(repo.enrollments, isEmpty);
    expect((repo.media as MemoryMedia).files, isEmpty);
  });
  test('lesson progress is stored separately for each student', () async {
    final first = await LearningStore.load(profileId: 'one');
    await first.toggleBookmark('faith-1');
    final second = await LearningStore.load(profileId: 'two');
    expect(second.bookmarks, isEmpty);
    expect((await LearningStore.load(profileId: 'one')).bookmarks, contains('faith-1'));
    first.dispose(); second.dispose();
  });
}
