/// درس مصوَّر ضمن إحدى مواد منصة "المحجة البيضاء" العلمية.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.durationLabel,
    this.summary = '',
    this.content = '',
    this.quranText,
    this.quranReference,
    this.hasPdf = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      durationLabel: map['duration_label'] as String? ?? '--:--',
      summary: map['summary'] as String? ?? '',
      content: map['content'] as String? ?? '',
      quranText: map['quran_text'] as String?,
      quranReference: map['quran_reference'] as String?,
      hasPdf: map['pdf_url'] != null,
    );
  }

  final String id;
  final String title;
  final String category;
  final String durationLabel;
  final String summary;
  final String content;
  final String? quranText;
  final String? quranReference;
  final bool hasPdf;
}
