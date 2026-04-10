// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    _$DisputeImpl(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      submitterId: json['submitterId'] as String,
      originalCategory: json['originalCategory'] as String,
      originalConfidence: (json['originalConfidence'] as num).toDouble(),
      secondaryCategory: json['secondaryCategory'] as String?,
      secondaryConfidence: (json['secondaryConfidence'] as num?)?.toDouble(),
      resolvedCategory: json['resolvedCategory'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolution: json['resolution'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submissionId': instance.submissionId,
      'submitterId': instance.submitterId,
      'originalCategory': instance.originalCategory,
      'originalConfidence': instance.originalConfidence,
      'secondaryCategory': instance.secondaryCategory,
      'secondaryConfidence': instance.secondaryConfidence,
      'resolvedCategory': instance.resolvedCategory,
      'resolvedBy': instance.resolvedBy,
      'resolution': instance.resolution,
      'resolutionNote': instance.resolutionNote,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };
