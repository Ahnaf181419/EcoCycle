// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  submissionId: json['submissionId'] as String?,
  points: (json['points'] as num).toInt(),
  type: json['type'] as String,
  idempotencyKey: json['idempotencyKey'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'submissionId': instance.submissionId,
      'points': instance.points,
      'type': instance.type,
      'idempotencyKey': instance.idempotencyKey,
      'createdAt': instance.createdAt.toIso8601String(),
    };
