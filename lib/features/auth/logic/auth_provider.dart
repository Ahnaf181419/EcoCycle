import 'dart:async';
import 'package:flutter/foundation.dart';
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
  StreamSubscription<dynamic>? _authSubscription;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    _authSubscription = _repository.authStateChanges.listen((event) async {
      debugPrint('[Auth] onAuthStateChange event: ${event.event}');
      final session = event.session;
      if (session != null) {
        debugPrint('[Auth] Session found for user: ${session.user.id}');
        UserProfile? profile;
        try {
          profile = await _repository.getCurrentUserProfile();
          debugPrint('[Auth] Profile fetched: ${profile?.username ?? "null"}');
        } catch (e) {
          debugPrint('[Auth] Profile fetch error: $e');
        }
        if (mounted) {
          state = state.copyWith(
            isAuthenticated: true,
            user: profile,
            isLoading: false,
            error: null,
          );
        }
      } else {
        debugPrint('[Auth] No session — unauthenticated');
        if (mounted) {
          state = state.copyWith(
            isAuthenticated: false,
            user: null,
            isLoading: false,
            error: null,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signIn(email: email, password: password);
      debugPrint('[Auth] signIn completed — fetching profile directly');
      await _fetchProfileAndSetAuthenticated();
    } catch (e) {
      debugPrint('[Auth] signIn error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
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
      debugPrint('[Auth] register completed — fetching profile directly');
      await _fetchProfileAndSetAuthenticated();
    } catch (e) {
      debugPrint('[Auth] register error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      rethrow;
    }
  }

  Future<void> _fetchProfileAndSetAuthenticated() async {
    UserProfile? profile;
    try {
      profile = await _repository.getCurrentUserProfile();
      debugPrint('[Auth] Direct profile fetch: ${profile?.username ?? "null"}');
    } catch (e) {
      debugPrint('[Auth] Direct profile fetch error: $e');
    }
    if (mounted) {
      state = state.copyWith(
        isAuthenticated: true,
        user: profile,
        isLoading: false,
        error: null,
      );
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
