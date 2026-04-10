// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward_model.freezed.dart';
part 'reward_model.g.dart';

@freezed
class Reward with _$Reward {
  const factory Reward({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'submission_id') String? submissionId,
    required int points,
    required String type,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}
