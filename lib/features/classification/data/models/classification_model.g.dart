// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassificationImpl _$$ClassificationImplFromJson(Map<String, dynamic> json) =>
    _$ClassificationImpl(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      approach: json['approach'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion: json['model_version'] as String,
      rawResponse: json['raw_response'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ClassificationImplToJson(
  _$ClassificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'submission_id': instance.submissionId,
  'approach': instance.approach,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'confidence': instance.confidence,
  'model_version': instance.modelVersion,
  'raw_response': instance.rawResponse,
  'timestamp': instance.timestamp.toIso8601String(),
};
