import '../models/project.dart';
import '../services/supabase_service.dart';

class ProjectsRepository {
  Future<List<CharityProject>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('projects')
        .select()
        .order('created_at');
    return rows.map(CharityProject.fromMap).toList();
  }
}
