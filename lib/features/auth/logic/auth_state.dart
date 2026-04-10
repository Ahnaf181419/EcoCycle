import 'package:freezed_annotation/freezed_annotation.dart';
import '../../social/data/models/user_profile_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    UserProfile? user,
    String? error,
  }) = _AuthState;

  const AuthState._();
}
