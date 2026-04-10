// ignore_for_file: invalid_annotation_target

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
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @Default('citizen') String role,
    @Default(0) int points,
    @JsonKey(name: 'redeemed_points') @Default(0) int redeemedPoints,
    @JsonKey(name: 'classification_count') @Default(0) int classificationCount,
    @JsonKey(name: 'correct_count') @Default(0) int correctCount,
    @JsonKey(name: 'is_private') @Default(false) bool isPrivate,
    @JsonKey(name: 'follower_count') @Default(0) int followerCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  int get availablePoints => points - redeemedPoints;
  double get accuracyRate =>
      classificationCount == 0 ? 0.0 : correctCount / classificationCount;
}
