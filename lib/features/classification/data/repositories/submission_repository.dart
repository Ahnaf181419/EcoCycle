import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission_model.dart';
import '../models/classification_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class SubmissionRepository {
  final SupabaseClient _client;

  SubmissionRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<List<Submission>> getSubmissionHistory({int limit = 20}) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);

    return _client
        .from(SupabaseTables.submissions)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .limit(limit)
        .map(
          (rows) =>
              rows.reversed.map((row) => Submission.fromJson(row)).toList(),
        );
  }

  Stream<Submission?> watchSubmission(String submissionId) {
    return _client
        .from(SupabaseTables.submissions)
        .stream(primaryKey: ['id'])
        .eq('id', submissionId)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return null;
          return Submission.fromJson(rows.first);
        });
  }

  Future<Submission?> getSubmission(String submissionId) async {
    final response = await _client
        .from(SupabaseTables.submissions)
        .select()
        .eq('id', submissionId)
        .maybeSingle();

    if (response == null) return null;
    return Submission.fromJson(response);
  }

  Future<List<Classification>> getClassifications(String submissionId) async {
    final response = await _client
        .from(SupabaseTables.classifications)
        .select()
        .eq('submission_id', submissionId);

    return response.map((row) => Classification.fromJson(row)).toList();
  }

  Stream<List<Submission>> getRecentSubmissions({int limit = 10}) {
    return _client
        .from(SupabaseTables.submissions)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(limit)
        .map(
          (rows) =>
              rows.reversed.map((row) => Submission.fromJson(row)).toList(),
        );
  }
}
