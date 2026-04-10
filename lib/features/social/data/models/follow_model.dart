import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_model.freezed.dart';
part 'follow_model.g.dart';

@freezed
class Follow with _$Follow {
  const factory Follow({
    @JsonKey(name: 'follower_id') required String followerId,
    @JsonKey(name: 'followee_id') required String followeeId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Follow;

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
}
