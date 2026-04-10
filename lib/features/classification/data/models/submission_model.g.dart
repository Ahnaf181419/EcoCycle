// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionImpl _$$SubmissionImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      imageUrl: json['imageUrl'] as String,
      storagePath: json['storagePath'] as String,
      imageHash: json['imageHash'] as String?,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      primaryApproach: json['primaryApproach'] as String? ?? 'gemini',
      state: $enumDecode(_$SubmissionStateEnumMap, json['state']),
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      idempotencyKey: json['idempotencyKey'] as String,
      flaggedReason: json['flaggedReason'] as String?,
      duplicateOf: json['duplicateOf'] as String?,
      classifiedAt: json['classifiedAt'] == null
          ? null
          : DateTime.parse(json['classifiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubmissionImplToJson(_$SubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'imageUrl': instance.imageUrl,
      'storagePath': instance.storagePath,
      'imageHash': instance.imageHash,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'confidence': instance.confidence,
      'primaryApproach': instance.primaryApproach,
      'state': _$SubmissionStateEnumMap[instance.state]!,
      'pointsAwarded': instance.pointsAwarded,
      'idempotencyKey': instance.idempotencyKey,
      'flaggedReason': instance.flaggedReason,
      'duplicateOf': instance.duplicateOf,
      'classifiedAt': instance.classifiedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
