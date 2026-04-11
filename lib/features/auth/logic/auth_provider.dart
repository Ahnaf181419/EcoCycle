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

/// Gated debug logger — stays silent in release builds.
void _log(String message) {
  if (kDebugMode) debugPrint('[Auth] $message');
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<dynamic>? _authSubscription;
  bool _handlingExplicitAuth = false;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authSubscription = _repository.authStateChanges.listen(
      (event) async {
        _log('onAuthStateChange event: ${event.event}');
        final session = event.session;

        // Fallback: if stream says no session, check if currentSession exists
        // This handles race condition where stream fires before session is restored
        if (session == null) {
          final currentSession = _repository.currentSession;
          if (currentSession != null) {
            _log('Using currentSession from repository (stream delay)');
            if (_handlingExplicitAuth) {
              _handlingExplicitAuth = false;
              return;
            }
            await _fetchProfileAndSetAuthenticated();
            return;
          }
        }

        if (session != null) {
          _log('Session found');
          if (_handlingExplicitAuth) {
            _handlingExplicitAuth = false;
            return;
          }
          await _fetchProfileAndSetAuthenticated();
        } else {
          _log('No session — unauthenticated');
          if (_handlingExplicitAuth) {
            _handlingExplicitAuth = false;
          }
          if (mounted) {
            state = state.copyWith(
              isAuthenticated: false,
              user: null,
              isLoading: false,
              error: null,
            );
          }
        }
      },
      onError: (error) {
        _log('Stream error: $error');
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
            error: error.toString(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    _handlingExplicitAuth = true;
    try {
      await _repository.signIn(email: email, password: password);
      _log('signIn completed — fetching profile directly');
      await _fetchProfileAndSetAuthenticated();
    } catch (e) {
      _log('signIn error: $e');
      _handlingExplicitAuth = false;
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
    _handlingExplicitAuth = true;
    try {
      await _repository.register(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      _log('register completed — fetching profile directly');
      await _fetchProfileAndSetAuthenticated();
    } catch (e) {
      _log('register error: $e');
      _handlingExplicitAuth = false;
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      rethrow;
    }
  }

  /// Fetches the current user's profile and transitions to authenticated.
  ///
  /// IMPORTANT: if the profile fetch fails we do NOT mark the user as
  /// authenticated. Downstream code relies on `isAuthenticated == true` implying
  /// `user != null`; violating that invariant silently demotes admins to
  /// citizens and causes `user!.uid` crashes.
  Future<void> _fetchProfileAndSetAuthenticated() async {
    UserProfile? profile;
    try {
      profile = await _repository.getCurrentUserProfile();
      _log('Profile fetched successfully');
    } catch (e, st) {
      _log('Profile fetch error: $e\n$st');
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: 'Could not load your profile. Please sign in again.',
        );
      }
      return;
    }

    if (profile == null) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: 'Profile not found. Please sign in again.',
        );
      }
      return;
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
    try {
      await _repository.signOut();
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: null,
        );
      }
    } catch (e) {
      _log('signOut error: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void updateUserProfile(UserProfile profile) {
    state = state.copyWith(user: profile);
  }

  /// Re-fetches the current user's profile and pushes it into auth state.
  /// Use after mutations (privacy toggle, display name change, etc.) so
  /// downstream consumers see the new values immediately.
  Future<void> refreshProfile() async {
    try {
      final profile = await _repository.getCurrentUserProfile();
      if (profile != null && mounted) {
        state = state.copyWith(user: profile);
      }
    } catch (e) {
      _log('refreshProfile error: $e');
    }
  }
}
