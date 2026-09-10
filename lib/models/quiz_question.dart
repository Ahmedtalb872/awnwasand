/// سؤال ضمن اختبار درس من دروس "المحجة البيضاء".
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'] as List? ?? const [];
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: rawOptions.map((o) => o.toString()).toList(),
      correctIndex: map['correct_index'] as int? ?? 0,
    );
  }

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
}
