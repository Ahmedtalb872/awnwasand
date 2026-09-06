import '../models/member.dart';
import '../services/supabase_service.dart';

class MembersRepository {
  Future<List<AssociationMember>> fetchMembers() async {
    final rows = await SupabaseService.client
        .from('members')
        .select()
        .eq('is_affiliate', false)
        .order('created_at');
    return rows.map(AssociationMember.fromMap).toList();
  }

  Future<List<AssociationMember>> fetchAffiliates() async {
    final rows = await SupabaseService.client
        .from('members')
        .select()
        .eq('is_affiliate', true)
        .order('created_at');
    return rows.map(AssociationMember.fromMap).toList();
  }
}
