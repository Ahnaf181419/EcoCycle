// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  submissionId: json['submission_id'] as String?,
  points: (json['points'] as num).toInt(),
  type: json['type'] as String,
  idempotencyKey: json['idempotency_key'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'submission_id': instance.submissionId,
      'points': instance.points,
      'type': instance.type,
      'idempotency_key': instance.idempotencyKey,
      'created_at': instance.createdAt.toIso8601String(),
    };
