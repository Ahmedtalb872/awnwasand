import '../models/subject.dart';
import '../services/supabase_service.dart';

class SubjectsRepository {
  Future<List<Subject>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('subjects')
        .select()
        .order('created_at');
    return rows.map(Subject.fromMap).toList();
  }
}
