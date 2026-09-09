import '../models/quiz_question.dart';
import '../services/supabase_service.dart';

class QuizRepository {
  Future<List<QuizQuestion>> fetchForLesson(String lessonId) async {
    final rows = await SupabaseService.client
        .from('quiz_questions')
        .select()
        .eq('lesson_id', lessonId)
        .order('created_at');
    return rows.map(QuizQuestion.fromMap).toList();
  }
}
