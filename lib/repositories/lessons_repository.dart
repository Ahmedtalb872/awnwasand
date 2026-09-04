import '../models/lesson.dart';
import '../services/supabase_service.dart';

class LessonsRepository {
  Future<List<Lesson>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('lessons')
        .select()
        .order('created_at');
    return rows.map(Lesson.fromMap).toList();
  }
}
