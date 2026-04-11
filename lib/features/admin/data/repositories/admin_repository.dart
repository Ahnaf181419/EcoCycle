import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConstants.client;

  Future<void> _verifyAdminRole() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Unauthorized: User not authenticated');
    }

    final response = await _client
        .from(SupabaseTables.profiles)
        .select('role')
        .eq('uid', user.id)
        .maybeSingle();

    if (response?['role'] != 'admin') {
      throw Exception('Unauthorized: Admin access required');
    }
  }

  Stream<List<UserProfile>> getAllUsers({int limit = 50}) async* {
    await _verifyAdminRole();
    final user = _client.auth.currentUser;
    if (user == null) {
      yield* Stream.error(StateError('Unauthorized: User not authenticated'));
      return;
    }

    yield* _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map(
          (rows) => rows.map((row) => UserProfile.fromJson(row)).toList(),
        );
  }

  Future<List<UserProfile>> getUsersPage({
    int offset = 0,
    int limit = 20,
  }) async {
    await _verifyAdminRole();
    final rows = await _client
        .from(SupabaseTables.profiles)
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map((row) => UserProfile.fromJson(row)).toList();
  }

  Future<int> getTotalUsers() async {
    await _verifyAdminRole();
    final response = await _client.rpc('count_users').select();
    return response.firstOrNull?['count'] as int? ?? 0;
  }

  Future<int> getTotalSubmissions() async {
    await _verifyAdminRole();
    final response = await _client.rpc('count_submissions').select();
    return response.firstOrNull?['count'] as int? ?? 0;
  }

  Future<int> getPendingDisputesCount() async {
    await _verifyAdminRole();
    final response = await _client.rpc('count_pending_disputes').select();
    return response.firstOrNull?['count'] as int? ?? 0;
  }

  Stream<List<AuditLogEntry>> getRecentAuditLog({int limit = 20}) async* {
    await _verifyAdminRole();
    yield* _client
        .from(SupabaseTables.auditLog)
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(limit)
        .map(
          (rows) => rows.map((row) => AuditLogEntry.fromJson(row)).toList(),
        );
  }
}

class AuditLogEntry {
  final String eventType;
  final String actorId;
  final String actorRole;
  final String targetType;
  final String targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.eventType,
    required this.actorId,
    required this.actorRole,
    required this.targetType,
    required this.targetId,
    required this.details,
    required this.timestamp,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      eventType: json['event_type'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? '',
      actorRole: json['actor_role'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      details: (json['details'] as Map<String, dynamic>?) ?? {},
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
