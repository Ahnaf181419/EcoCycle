import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String uid,
    required String username,
    required String email,
    required String displayName,
    String? photoUrl,
    @Default('citizen') String role,
    @Default(0) int points,
    @Default(0) int redeemedPoints,
    @Default(0) int classificationCount,
    @Default(0) int correctCount,
    @Default(false) bool isPrivate,
    @Default(0) int followerCount,
    @Default(0) int followingCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  int get availablePoints => points - redeemedPoints;
  double get accuracyRate =>
      classificationCount == 0 ? 0.0 : correctCount / classificationCount;
}
