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
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'storage_path') required String storagePath,
    @JsonKey(name: 'image_hash') String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    @JsonKey(name: 'primary_approach')
    @Default('gemini')
    String primaryApproach,
    required SubmissionState state,
    @JsonKey(name: 'points_awarded') @Default(0) int pointsAwarded,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'flagged_reason') String? flaggedReason,
    @JsonKey(name: 'duplicate_of') String? duplicateOf,
    @JsonKey(name: 'classified_at') DateTime? classifiedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);
}
