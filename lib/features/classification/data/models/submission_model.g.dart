// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionImpl _$$SubmissionImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String? ?? '',
      imageUrl: json['image_url'] as String,
      storagePath: json['storage_path'] as String,
      imageHash: json['image_hash'] as String?,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      primaryApproach: json['primary_approach'] as String? ?? 'gemini',
      state: $enumDecode(_$SubmissionStateEnumMap, json['state']),
      pointsAwarded: (json['points_awarded'] as num?)?.toInt() ?? 0,
      idempotencyKey: json['idempotency_key'] as String,
      flaggedReason: json['flagged_reason'] as String?,
      duplicateOf: json['duplicate_of'] as String?,
      classifiedAt: json['classified_at'] == null
          ? null
          : DateTime.parse(json['classified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SubmissionImplToJson(_$SubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'username': instance.username,
      'image_url': instance.imageUrl,
      'storage_path': instance.storagePath,
      'image_hash': instance.imageHash,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'confidence': instance.confidence,
      'primary_approach': instance.primaryApproach,
      'state': _$SubmissionStateEnumMap[instance.state]!,
      'points_awarded': instance.pointsAwarded,
      'idempotency_key': instance.idempotencyKey,
      'flagged_reason': instance.flaggedReason,
      'duplicate_of': instance.duplicateOf,
      'classified_at': instance.classifiedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$SubmissionStateEnumMap = {
  SubmissionState.submitted: 'SUBMITTED',
  SubmissionState.classified: 'CLASSIFIED',
  SubmissionState.verified: 'VERIFIED',
  SubmissionState.rewarded: 'REWARDED',
  SubmissionState.disputed: 'DISPUTED',
  SubmissionState.resolved: 'RESOLVED',
  SubmissionState.rejected: 'REJECTED',
  SubmissionState.flaggedDuplicate: 'FLAGGED_DUPLICATE',
};
