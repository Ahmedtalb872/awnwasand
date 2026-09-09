import '../models/profile_stats.dart';
import '../services/supabase_service.dart';

class ProfileRepository {
  Future<ProfileStats> fetchStats() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return const ProfileStats();

    final row = await SupabaseService.client
        .from('profiles')
        .select('completed_courses, followed_lessons, knowledge_points')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return const ProfileStats();
    return ProfileStats.fromMap(row);
  }
}
