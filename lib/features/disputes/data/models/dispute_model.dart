// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute_model.freezed.dart';
part 'dispute_model.g.dart';

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    @JsonKey(name: 'submission_id') required String submissionId,
    @JsonKey(name: 'submitter_id') required String submitterId,
    @JsonKey(name: 'original_category') required String originalCategory,
    @JsonKey(name: 'original_confidence') required double originalConfidence,
    @JsonKey(name: 'secondary_category') String? secondaryCategory,
    @JsonKey(name: 'secondary_confidence') double? secondaryConfidence,
    @JsonKey(name: 'resolved_category') String? resolvedCategory,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    String? resolution,
    @JsonKey(name: 'resolution_note') String? resolutionNote,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}
