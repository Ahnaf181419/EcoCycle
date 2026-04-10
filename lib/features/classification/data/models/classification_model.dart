import 'package:freezed_annotation/freezed_annotation.dart';

part 'classification_model.freezed.dart';
part 'classification_model.g.dart';

@freezed
class Classification with _$Classification {
  const factory Classification({
    required String id,
    @JsonKey(name: 'submission_id') required String submissionId,
    required String approach,
    required String category,
    String? subcategory,
    required double confidence,
    @JsonKey(name: 'model_version') required String modelVersion,
    @JsonKey(name: 'raw_response') Map<String, dynamic>? rawResponse,
    required DateTime timestamp,
  }) = _Classification;

  factory Classification.fromJson(Map<String, dynamic> json) =>
      _$ClassificationFromJson(json);
}
