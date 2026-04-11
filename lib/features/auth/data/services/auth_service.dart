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

      // Profile creation is handled by the database trigger (handle_new_user)
      // No need to create profile here -- the trigger fires on auth.users INSERT

      return response;
    } on AuthException catch (e) {
      throw AuthError.fromSupabaseMessage(e.message);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching user profile: $e');
    }
  }
}
