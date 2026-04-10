import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/user_repository.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/logic/auth_state.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.currentUserProfile;
});

final userProfileProvider = StreamProvider.family<UserProfile?, String>((
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
        authState: ref.watch(authProvider),
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
  final AuthState authState;

  ProfileEditNotifier({
    required UserRepository userRepository,
    required this.authState,
  }) : _userRepository = userRepository,
       super(const ProfileEditState());

  Future<void> updateDisplayName(String displayName) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updateProfile(displayName: displayName);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _userRepository.updateProfile(photoUrl: photoUrl);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const ProfileEditState();
  }
}
