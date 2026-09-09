import '../models/lesson.dart';
import '../services/supabase_service.dart';

class LessonsRepository {
  Future<List<Lesson>> fetchAll({String? category}) async {
    final query = SupabaseService.client.from('lessons').select();
    final rows = await (category == null
            ? query
            : query.eq('category', category))
        .order('created_at');
    return rows.map(Lesson.fromMap).toList();
  }

  Future<List<Lesson>> fetchLatest({int limit = 4}) async {
    final rows = await SupabaseService.client
        .from('lessons')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(Lesson.fromMap).toList();
  }
}
