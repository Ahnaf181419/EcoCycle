import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute_model.freezed.dart';
part 'dispute_model.g.dart';

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String submissionId,
    required String submitterId,
    required String originalCategory,
    required double originalConfidence,
    String? secondaryCategory,
    double? secondaryConfidence,
    String? resolvedCategory,
    String? resolvedBy,
    String? resolution,
    String? resolutionNote,
    required String status,
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}
