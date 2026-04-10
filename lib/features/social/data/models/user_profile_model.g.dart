// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] as String? ?? 'citizen',
      points: (json['points'] as num?)?.toInt() ?? 0,
      redeemedPoints: (json['redeemed_points'] as num?)?.toInt() ?? 0,
      classificationCount: (json['classification_count'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      isPrivate: json['is_private'] as bool? ?? false,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'email': instance.email,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
      'role': instance.role,
      'points': instance.points,
      'redeemed_points': instance.redeemedPoints,
      'classification_count': instance.classificationCount,
      'correct_count': instance.correctCount,
      'is_private': instance.isPrivate,
      'follower_count': instance.followerCount,
      'following_count': instance.followingCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
