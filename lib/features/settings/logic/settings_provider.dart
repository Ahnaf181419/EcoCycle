import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/logic/auth_provider.dart';
import '../../social/data/repositories/user_repository.dart';
import '../../social/logic/profile_provider.dart';

final settingsRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(userRepositoryProvider);
});

final privacyToggleProvider = StateNotifierProvider.autoDispose<
    PrivacyToggleNotifier, PrivacyToggleState>((ref) {
  return PrivacyToggleNotifier(
    userRepository: ref.watch(settingsRepositoryProvider),
    ref: ref,
  );
});

class PrivacyToggleState {
  static const _sentinel = Object();

  final bool isLoading;
  final String? error;
  final bool success;

  const PrivacyToggleState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  PrivacyToggleState copyWith({
    bool? isLoading,
    Object? error = _sentinel,
    bool? success,
  }) {
    return PrivacyToggleState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      success: success ?? this.success,
    );
  }
}

class PrivacyToggleNotifier extends StateNotifier<PrivacyToggleState> {
  final UserRepository _userRepository;
  final Ref _ref;

  PrivacyToggleNotifier({
    required UserRepository userRepository,
    required Ref ref,
  })  : _userRepository = userRepository,
        _ref = ref,
        super(const PrivacyToggleState());

  Future<void> togglePrivacy(bool isPrivate) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updatePrivacy(isPrivate);
      // Push the new profile into auth state so the Settings UI (which reads
      // `user?.isPrivate`) reflects the change immediately.
      await _ref.read(authProvider.notifier).refreshProfile();
      if (!mounted) return;
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final deleteAccountProvider = StateNotifierProvider.autoDispose<
    DeleteAccountNotifier, DeleteAccountState>((ref) {
  return DeleteAccountNotifier(
    userRepository: ref.watch(settingsRepositoryProvider),
  );
});

class DeleteAccountState {
  static const _sentinel = Object();

  final bool isLoading;
  final String? error;
  final bool success;

  const DeleteAccountState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    Object? error = _sentinel,
    bool? success,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      success: success ?? this.success,
    );
  }
}

class DeleteAccountNotifier extends StateNotifier<DeleteAccountState> {
  final UserRepository _userRepository;

  DeleteAccountNotifier({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const DeleteAccountState());

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.deleteAccount();
      if (!mounted) return true;
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
