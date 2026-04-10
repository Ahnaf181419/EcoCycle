// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    _$DisputeImpl(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      submitterId: json['submitter_id'] as String,
      originalCategory: json['original_category'] as String,
      originalConfidence: (json['original_confidence'] as num).toDouble(),
      secondaryCategory: json['secondary_category'] as String?,
      secondaryConfidence: (json['secondary_confidence'] as num?)?.toDouble(),
      resolvedCategory: json['resolved_category'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolution: json['resolution'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submission_id': instance.submissionId,
      'submitter_id': instance.submitterId,
      'original_category': instance.originalCategory,
      'original_confidence': instance.originalConfidence,
      'secondary_category': instance.secondaryCategory,
      'secondary_confidence': instance.secondaryConfidence,
      'resolved_category': instance.resolvedCategory,
      'resolved_by': instance.resolvedBy,
      'resolution': instance.resolution,
      'resolution_note': instance.resolutionNote,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
    };
