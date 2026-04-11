import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/user_repository.dart';
import '../../auth/logic/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserProfileProvider =
    StreamProvider.autoDispose<UserProfile?>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.currentUserProfile;
});

final userProfileProvider =
    StreamProvider.autoDispose.family<UserProfile?, String>((
  ref,
  uid,
) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.userProfileStream(uid);
});

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(
    userRepository: ref.watch(userRepositoryProvider),
    ref: ref,
  );
});

class ProfileEditState {
  final bool isLoading;
  final String? error;
  final bool success;

  const ProfileEditState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProfileEditState copyWith({bool? isLoading, String? error, bool? success}) {
    return ProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final UserRepository _userRepository;
  final Ref _ref;

  ProfileEditNotifier({
    required UserRepository userRepository,
    required Ref ref,
  })  : _userRepository = userRepository,
        _ref = ref,
        super(const ProfileEditState());

  Future<void> updateDisplayName(String displayName) async {
    final uid = _ref.read(authProvider).user?.uid;
    if (uid == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'You must be signed in to edit your profile.',
        success: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updateProfile(displayName: displayName);
      final updatedProfile = await _userRepository.getUserProfile(uid);
      if (!mounted) return;
      if (updatedProfile != null) {
        _ref.read(authProvider.notifier).updateUserProfile(updatedProfile);
      }
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    final uid = _ref.read(authProvider).user?.uid;
    if (uid == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'You must be signed in to edit your profile.',
        success: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updateProfile(photoUrl: photoUrl);
      final updatedProfile = await _userRepository.getUserProfile(uid);
      if (!mounted) return;
      if (updatedProfile != null) {
        _ref.read(authProvider.notifier).updateUserProfile(updatedProfile);
      }
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const ProfileEditState();
  }
}
