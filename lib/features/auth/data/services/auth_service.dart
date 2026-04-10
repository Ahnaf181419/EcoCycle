import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_error.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<dynamic> get authStateChanges => _client.auth.onAuthStateChange;

  dynamic get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthError.fromSupabaseMessage(e.message);
    }
  }

  Future<AuthResponse> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'display_name': displayName},
      );

      if (response.user != null) {
        await _createUserProfile(
          uid: response.user!.id,
          email: email,
          username: username,
          displayName: displayName,
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthError.fromSupabaseMessage(e.message);
    }
  }

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
  }) async {
    final now = DateTime.now().toUtc();
    final profile = UserProfile(
      uid: uid,
      username: username,
      email: email,
      displayName: displayName,
      role: 'citizen',
      points: 0,
      redeemedPoints: 0,
      classificationCount: 0,
      correctCount: 0,
      isPrivate: false,
      followerCount: 0,
      followingCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _client.from(SupabaseTables.profiles).insert(profile.toJson());
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('uid', user.id)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile.fromJson(response);
  }
}
