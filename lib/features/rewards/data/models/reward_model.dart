import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward_model.freezed.dart';
part 'reward_model.g.dart';

@freezed
class Reward with _$Reward {
  const factory Reward({
    required String id,
    required String userId,
    String? submissionId,
    required int points,
    required String type,
    required String idempotencyKey,
    required DateTime createdAt,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}
