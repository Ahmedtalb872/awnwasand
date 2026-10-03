import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class LessonProgress {
  const LessonProgress({this.bestScore = 0, this.attempts = 0, this.completed = false});
  final int bestScore;
  final int attempts;
  final bool completed;
  Map<String, dynamic> toJson() => {'bestScore': bestScore, 'attempts': attempts, 'completed': completed};
  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
    bestScore: (json['bestScore'] as int?) ?? 0,
    attempts: (json['attempts'] as int?) ?? 0,
    completed: (json['completed'] as bool?) ?? false,
  );
}

class LearningStore extends ChangeNotifier {
  LearningStore(this.preferences, {this.profileId = 'default'});
  static const storageKey = 'awnwasand.learning.v1';
  final String profileId;
  String get key => profileId == 'default' ? storageKey : '$storageKey.$profileId';
  final SharedPreferences preferences;
  String name = 'متعلم';
  int dailyGoal = 1;
  final Map<String, LessonProgress> progress = {};
  final Set<String> bookmarks = {};
  final Map<String, Set<String>> activity = {};
  bool recoveredCorruptData = false;

  static Future<LearningStore> load({String profileId = 'default'}) async {
    final store = LearningStore(await SharedPreferences.getInstance(), profileId: profileId);
    final raw = store.preferences.getString(store.key);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        store.name = (json['name'] as String?) ?? 'متعلم';
        store.dailyGoal = ((json['goal'] as int?) ?? 1).clamp(1, 5).toInt();
        (json['progress'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
          store.progress[key] = LessonProgress.fromJson(Map<String, dynamic>.from(value as Map));
        });
        store.bookmarks.addAll(List<String>.from(json['bookmarks'] as List? ?? []));
        (json['activity'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
          store.activity[key] = List<String>.from(value as List).toSet();
        });
      } catch (_) {
        // Keep a copy for recovery rather than overwriting unreadable data silently.
        await store.preferences.setString('${store.key}.backup', raw);
        store.name = 'متعلم';
        store.dailyGoal = 1;
        store.progress.clear();
        store.bookmarks.clear();
        store.activity.clear();
        store.recoveredCorruptData = true;
      }
    }
    return store;
  }

  static String dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  int todayCount([DateTime? date]) => activity[dateKey(date ?? DateTime.now())]?.length ?? 0;
  bool isDone(String id) => progress[id]?.completed ?? false;
  int get completedCount => progress.values.where((p) => p.completed).length;
  int get attempts => progress.values.fold(0, (total, p) => total + p.attempts);

  Future<void> save() async {
    final ok = await preferences.setString(key, jsonEncode({
      'name': name, 'goal': dailyGoal,
      'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
      'bookmarks': bookmarks.toList(),
      'activity': activity.map((key, value) => MapEntry(key, value.toList())),
    }));
    notifyListeners();
    if (!ok) throw StateError('تعذر حفظ البيانات على الجهاز');
  }

  Future<int> submit(Lesson lesson, List<int> answers, {DateTime? date}) async {
    final score = lesson.grade(answers);
    final previous = progress[lesson.id] ?? const LessonProgress();
    progress[lesson.id] = LessonProgress(
      bestScore: score > previous.bestScore ? score : previous.bestScore,
      attempts: previous.attempts + 1,
      completed: previous.completed || score >= 70,
    );
    if (score >= 70) {
      activity.putIfAbsent(dateKey(date ?? DateTime.now()), () => <String>{}).add(lesson.id);
    }
    await save();
    return score;
  }

  Future<void> toggleBookmark(String id) async {
    if (!bookmarks.remove(id)) bookmarks.add(id);
    await save();
  }

  Future<void> updateProfile(String value, int goal) async {
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 60 || goal < 1 || goal > 5) {
      throw ArgumentError('أدخل اسمًا من حرفين إلى 60 حرفًا وهدفًا من 1 إلى 5');
    }
    name = trimmed;
    dailyGoal = goal;
    await save();
  }

  Future<void> reset() async {
    final ok = await preferences.remove(key);
    if (!ok) throw StateError('تعذر حذف البيانات');
    name = 'متعلم';
    dailyGoal = 1;
    progress.clear();
    bookmarks.clear();
    activity.clear();
    notifyListeners();
  }
}
