import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awnwasand/models.dart';
import 'package:awnwasand/learning_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Curriculum curriculum;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    curriculum = Curriculum.decode(File('assets/curriculum.json').readAsStringSync());
  });

  test('curriculum has references, valid answers, and stable unique IDs', () {
    expect(curriculum.tracks.length, 6);
    expect(curriculum.lessons.length, 12);
    expect(curriculum.lessons.map((l) => l.id).toSet().length, 12);
    for (final lesson in curriculum.lessons) {
      expect(curriculum.tracks.any((t) => t.id == lesson.track), isTrue);
      expect(Uri.parse(lesson.sourceUrl).scheme, 'https');
      expect(lesson.paragraphs, isNotEmpty);
      for (final question in lesson.questions) {
        expect(question.answer, inInclusiveRange(0, question.options.length - 1));
      }
    }
  });

  test('quiz rejects incomplete and invalid answers', () {
    final lesson = curriculum.lessons.first;
    expect(() => lesson.grade([1]), throwsArgumentError);
    expect(() => lesson.grade([-1, 0]), throwsArgumentError);
    expect(lesson.grade(lesson.questions.map((q) => q.answer).toList()), 100);
  });

  test('failed attempts do not complete a lesson', () async {
    final store = await LearningStore.load();
    final lesson = curriculum.lessons.first;
    expect(await store.submit(lesson, [0, 2]), 0);
    expect(store.isDone(lesson.id), isFalse);
    expect(store.todayCount(), 0);
    store.dispose();
  });

  test('best score and completion persist without duplicate daily credit', () async {
    final store = await LearningStore.load();
    final lesson = curriculum.lessons.first;
    final date = DateTime(2026, 10, 3);
    final answers = lesson.questions.map((q) => q.answer).toList();
    await store.submit(lesson, answers, date: date);
    await store.submit(lesson, answers, date: date);
    await store.submit(lesson, [0, 2], date: date);
    expect(store.todayCount(date), 1);
    expect(store.progress[lesson.id]!.attempts, 3);
    expect(store.progress[lesson.id]!.bestScore, 100);
    final restored = await LearningStore.load();
    expect(restored.isDone(lesson.id), isTrue);
    expect(restored.todayCount(date), 1);
    expect(restored.todayCount(DateTime(2026, 10, 4)), 0);
    store.dispose(); restored.dispose();
  });

  test('profile and bookmarks persist and reset removes them', () async {
    final store = await LearningStore.load();
    await store.updateProfile('أحمد', 3);
    await store.toggleBookmark('faith-1');
    final restored = await LearningStore.load();
    expect(restored.name, 'أحمد');
    expect(restored.dailyGoal, 3);
    expect(restored.bookmarks, contains('faith-1'));
    await restored.toggleBookmark('faith-1');
    expect(restored.bookmarks, isEmpty);
    await restored.reset();
    expect((await LearningStore.load()).name, 'متعلم');
    store.dispose(); restored.dispose();
  });

  test('invalid profile is rejected', () async {
    final store = await LearningStore.load();
    await expectLater(store.updateProfile('أ', 2), throwsArgumentError);
    await expectLater(store.updateProfile('أحمد', 0), throwsArgumentError);
    store.dispose();
  });

  test('corrupt data is backed up and recovered visibly', () async {
    SharedPreferences.setMockInitialValues({LearningStore.storageKey: 'invalid-json'});
    final store = await LearningStore.load();
    expect(store.recoveredCorruptData, isTrue);
    expect(store.progress, isEmpty);
    expect(store.preferences.getString('${LearningStore.storageKey}.backup'), 'invalid-json');
    store.dispose();
  });
}
