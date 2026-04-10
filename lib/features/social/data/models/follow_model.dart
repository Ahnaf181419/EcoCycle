import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_model.freezed.dart';
part 'follow_model.g.dart';

@freezed
class Follow with _$Follow {
  const factory Follow({
    required String followerId,
    required String followeeId,
    required DateTime createdAt,
  }) = _Follow;

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
}
