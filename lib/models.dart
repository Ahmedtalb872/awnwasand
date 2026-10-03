import 'dart:convert';

class LearningTrack {
  const LearningTrack({required this.id, required this.title, required this.description});
  final String id;
  final String title;
  final String description;

  factory LearningTrack.fromJson(Map<String, dynamic> json) => LearningTrack(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
  );
}

class Question {
  const Question({required this.prompt, required this.options, required this.answer, required this.explanation});
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanation;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    prompt: json['prompt'] as String,
    options: List<String>.from(json['options'] as List),
    answer: json['answer'] as int,
    explanation: json['explanation'] as String,
  );
}

class Lesson {
  const Lesson({required this.id, required this.track, required this.title, required this.minutes, required this.paragraphs, required this.source, required this.sourceUrl, required this.task, required this.questions});
  final String id;
  final String track;
  final String title;
  final int minutes;
  final List<String> paragraphs;
  final String source;
  final String sourceUrl;
  final String task;
  final List<Question> questions;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    track: json['track'] as String,
    title: json['title'] as String,
    minutes: json['minutes'] as int,
    paragraphs: List<String>.from(json['paragraphs'] as List),
    source: json['source'] as String,
    sourceUrl: json['source_url'] as String,
    task: json['task'] as String,
    questions: (json['questions'] as List).map((q) => Question.fromJson(Map<String, dynamic>.from(q as Map))).toList(),
  );

  int grade(List<int> answers) {
    if (answers.length != questions.length || questions.isEmpty) {
      throw ArgumentError('أجب عن جميع الأسئلة');
    }
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] < 0 || answers[i] >= questions[i].options.length) {
        throw ArgumentError('إجابة غير صالحة');
      }
      if (answers[i] == questions[i].answer) correct++;
    }
    return (correct * 100 / questions.length).round();
  }
}

class Curriculum {
  const Curriculum(this.tracks, this.lessons);
  final List<LearningTrack> tracks;
  final List<Lesson> lessons;

  factory Curriculum.decode(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    return Curriculum(
      (json['tracks'] as List).map((t) => LearningTrack.fromJson(Map<String, dynamic>.from(t as Map))).toList(),
      (json['lessons'] as List).map((l) => Lesson.fromJson(Map<String, dynamic>.from(l as Map))).toList(),
    );
  }

  List<Lesson> forTrack(String id) => lessons.where((l) => l.track == id).toList();
}
