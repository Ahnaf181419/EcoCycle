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

    if (updates.isNotEmpty) {
      await _client
          .from(SupabaseTables.profiles)
          .update(updates)
          .eq('uid', uid);
    }
  }

  Future<void> updatePrivacy(bool isPrivate) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _client
        .from(SupabaseTables.profiles)
        .update({'is_private': isPrivate})
        .eq('uid', uid);
  }

  Future<void> deleteAccount() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _client.from(SupabaseTables.profiles).delete().eq('uid', uid);
    await _client.auth.signOut();
  }
}
