import '../services/supabase_service.dart';

class DonationsRepository {
  Future<void> donate({
    String? projectId,
    required int amount,
    required String paymentMethod,
  }) async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    await SupabaseService.client.from('donations').insert({
      'user_id': userId,
      'project_id': projectId,
      'amount': amount,
      'payment_method': paymentMethod,
    });
  }
}
