import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../social/data/repositories/user_repository.dart';

final settingsRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final privacyToggleProvider =
    StateNotifierProvider<PrivacyToggleNotifier, PrivacyToggleState>((ref) {
      return PrivacyToggleNotifier(
        userRepository: ref.watch(settingsRepositoryProvider),
      );
    });

class PrivacyToggleState {
  final bool isLoading;
  final String? error;
  final bool success;

  const PrivacyToggleState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  PrivacyToggleState copyWith({bool? isLoading, String? error, bool? success}) {
    return PrivacyToggleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? false,
    );
  }
}

class PrivacyToggleNotifier extends StateNotifier<PrivacyToggleState> {
  final UserRepository _userRepository;

  PrivacyToggleNotifier({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const PrivacyToggleState());

  Future<void> togglePrivacy(bool isPrivate) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updatePrivacy(isPrivate);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, DeleteAccountState>((ref) {
      return DeleteAccountNotifier(
        userRepository: ref.watch(settingsRepositoryProvider),
      );
    });

class DeleteAccountState {
  final bool isLoading;
  final String? error;
  final bool success;

  const DeleteAccountState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  DeleteAccountState copyWith({bool? isLoading, String? error, bool? success}) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? false,
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
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
