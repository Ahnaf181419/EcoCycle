import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dispute_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class DisputeRepository {
  final SupabaseClient _client;

  DisputeRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConstants.client;

  Stream<List<Dispute>> getPendingDisputes({int limit = 50}) {
    return _client
        .from(SupabaseTables.disputes)
        .stream(primaryKey: ['id'])
        .eq('status', 'PENDING')
        .order('created_at', ascending: false)
        .limit(limit)
        .map(
          (rows) => rows.map((row) {
            return Dispute.fromJson(row);
          }).toList(),
        );
  }

  Stream<Dispute?> getDispute(String disputeId) {
    return _client
        .from(SupabaseTables.disputes)
        .stream(primaryKey: ['id'])
        .eq('id', disputeId)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return null;
          return Dispute.fromJson(rows.first);
        });
  }

  Future<String?> getSubmissionImageUrl(String submissionId) async {
    final response = await _client
        .from(SupabaseTables.submissions)
        .select('image_url')
        .eq('id', submissionId)
        .maybeSingle();

    if (response == null) return null;
    return response['image_url'] as String?;
  }

  Future<int> getPendingDisputeCount() async {
    final response = await _client.rpc('count_pending_disputes').select();
    return response.first['count'] as int? ?? 0;
  }
}
