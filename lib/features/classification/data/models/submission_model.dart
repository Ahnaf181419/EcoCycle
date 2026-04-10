import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_model.freezed.dart';
part 'submission_model.g.dart';

enum SubmissionState {
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('CLASSIFIED')
  classified,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('REWARDED')
  rewarded,
  @JsonValue('DISPUTED')
  disputed,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('FLAGGED_DUPLICATE')
  flaggedDuplicate,
}

@freezed
class Submission with _$Submission {
  const factory Submission({
    required String id,
    required String userId,
    required String username,
    required String imageUrl,
    required String storagePath,
    String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    @Default('gemini') String primaryApproach,
    required SubmissionState state,
    @Default(0) int pointsAwarded,
    required String idempotencyKey,
    String? flaggedReason,
    String? duplicateOf,
    DateTime? classifiedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);
}
