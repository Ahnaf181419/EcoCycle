import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/auth_service.dart';
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class AuthRepository {
  final AuthService _authService;
  final SupabaseClient _client;

  AuthRepository({required AuthService authService, SupabaseClient? client})
    : _authService = authService,
      _client = client ?? SupabaseConstants.client;

  Stream<dynamic> get authStateChanges => _authService.authStateChanges;

  dynamic get currentUser => _authService.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) {
    return _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }

  Future<void> signOut() => _authService.signOut();

  Stream<UserProfile?> userProfileStream(String uid) {
    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .map((rows) {
          if (rows.isEmpty) return null;
          return UserProfile.fromJson(rows.first);
        });
  }

  Future<UserProfile?> getCurrentUserProfile() {
    return _authService.getCurrentUserProfile();
  }
}
