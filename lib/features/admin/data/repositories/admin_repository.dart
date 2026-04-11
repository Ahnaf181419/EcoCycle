import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  // TODO: Supabase stream does not support pagination offset. Consider a
  // server-side paginated query for large user bases. The limit parameter caps
  // the number of rows returned; callers should be aware of this ceiling.
  Stream<List<UserProfile>> getAllUsers({int limit = 100}) {
    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map(
          (rows) =>
              rows.map((row) => UserProfile.fromJson(row)).toList(),
        );
  }

  // TODO: Replace with a server-side function for true count query.
  // Supabase stream doesn't support count; selecting only primary key to reduce data transfer.
  Stream<int> getTotalUsers() {
    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .map((rows) => rows.length);
  }

  // TODO: Replace with a server-side function for true count query.
  // Supabase stream doesn't support count; selecting only primary key to reduce data transfer.
  Stream<int> getTotalSubmissions() {
    return _client
        .from(SupabaseTables.submissions)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.length);
  }

  // TODO: Replace with a server-side function for true count query.
  Stream<int> getPendingDisputesCount() {
    return _client
        .from(SupabaseTables.disputes)
        .stream(primaryKey: ['id'])
        .eq('status', 'PENDING')
        .map((rows) => rows.length);
  }

  Stream<List<AuditLogEntry>> getRecentAuditLog({int limit = 20}) {
    return _client
        .from(SupabaseTables.auditLog)
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(limit)
        .map(
          (rows) =>
              rows.map((row) => AuditLogEntry.fromJson(row)).toList(),
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
