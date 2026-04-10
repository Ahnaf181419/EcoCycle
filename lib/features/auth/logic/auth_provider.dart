import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/auth_service.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../social/data/models/user_profile_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(authService: ref.watch(authServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    _repository.authStateChanges.listen((user) async {
      if (user != null) {
        final profile = await _repository.getCurrentUserProfile();
        state = state.copyWith(
          isAuthenticated: true,
          user: profile,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signIn(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.register(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
  }

  void updateUserProfile(UserProfile profile) {
    state = state.copyWith(user: profile);
  }
}
