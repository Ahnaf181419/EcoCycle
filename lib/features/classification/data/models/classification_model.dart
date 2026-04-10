import 'package:freezed_annotation/freezed_annotation.dart';

part 'classification_model.freezed.dart';
part 'classification_model.g.dart';

@freezed
class Classification with _$Classification {
  const factory Classification({
    required String id,
    required String submissionId,
    required String approach,
    required String category,
    String? subcategory,
    required double confidence,
    required String modelVersion,
    Map<String, dynamic>? rawResponse,
    required DateTime timestamp,
  }) = _Classification;

  factory Classification.fromJson(Map<String, dynamic> json) =>
      _$ClassificationFromJson(json);
}
