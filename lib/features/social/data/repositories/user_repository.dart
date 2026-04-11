import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<UserProfile?> get currentUserProfile {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(null);

    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return null;
          return UserProfile.fromJson(rows.first);
        });
  }

  Stream<UserProfile?> userProfileStream(String uid) {
    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return null;
          return UserProfile.fromJson(rows.first);
        });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('uid', uid)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    if (updates.isEmpty) {
      throw ArgumentError('At least one field must be provided for update');
    }

    await _client
        .from(SupabaseTables.profiles)
        .update(updates)
        .eq('uid', uid);
  }

  Future<void> updatePrivacy(bool isPrivate) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _client
        .from(SupabaseTables.profiles)
        .update({'is_private': isPrivate})
        .eq('uid', uid);
  }

  // TODO: This should ideally be an atomic server-side operation to avoid
  // inconsistent state if one step fails.
  Future<void> deleteAccount() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      await _client.auth.signOut();
    } catch (e) {
      // Re-throw since we can't safely proceed if sign-out fails
      rethrow;
    }

    try {
      await _client.from(SupabaseTables.profiles).delete().eq('uid', uid);
    } catch (e) {
      // Profile deletion failed after sign-out; state may be inconsistent
      rethrow;
    }
  }
}
