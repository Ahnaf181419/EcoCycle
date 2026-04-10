// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Follow _$FollowFromJson(Map<String, dynamic> json) {
  return _Follow.fromJson(json);
}

/// @nodoc
mixin _$Follow {
  @JsonKey(name: 'follower_id')
  String get followerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'followee_id')
  String get followeeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Follow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowCopyWith<Follow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowCopyWith<$Res> {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) then) =
      _$FollowCopyWithImpl<$Res, Follow>;
  @useResult
  $Res call({
    @JsonKey(name: 'follower_id') String followerId,
    @JsonKey(name: 'followee_id') String followeeId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$FollowCopyWithImpl<$Res, $Val extends Follow>
    implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followerId = null,
    Object? followeeId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            followerId: null == followerId
                ? _value.followerId
                : followerId // ignore: cast_nullable_to_non_nullable
                      as String,
            followeeId: null == followeeId
                ? _value.followeeId
                : followeeId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowImplCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$FollowImplCopyWith(
    _$FollowImpl value,
    $Res Function(_$FollowImpl) then,
  ) = __$$FollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'follower_id') String followerId,
    @JsonKey(name: 'followee_id') String followeeId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$FollowImplCopyWithImpl<$Res>
    extends _$FollowCopyWithImpl<$Res, _$FollowImpl>
    implements _$$FollowImplCopyWith<$Res> {
  __$$FollowImplCopyWithImpl(
    _$FollowImpl _value,
    $Res Function(_$FollowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followerId = null,
    Object? followeeId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FollowImpl(
        followerId: null == followerId
            ? _value.followerId
            : followerId // ignore: cast_nullable_to_non_nullable
                  as String,
        followeeId: null == followeeId
            ? _value.followeeId
            : followeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowImpl implements _Follow {
  const _$FollowImpl({
    @JsonKey(name: 'follower_id') required this.followerId,
    @JsonKey(name: 'followee_id') required this.followeeId,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$FollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowImplFromJson(json);

  @override
  @JsonKey(name: 'follower_id')
  final String followerId;
  @override
  @JsonKey(name: 'followee_id')
  final String followeeId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Follow(followerId: $followerId, followeeId: $followeeId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowImpl &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.followeeId, followeeId) ||
                other.followeeId == followeeId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, followerId, followeeId, createdAt);

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
      __$$FollowImplCopyWithImpl<_$FollowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowImplToJson(this);
  }
}

abstract class _Follow implements Follow {
  const factory _Follow({
    @JsonKey(name: 'follower_id') required final String followerId,
    @JsonKey(name: 'followee_id') required final String followeeId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$FollowImpl;

  factory _Follow.fromJson(Map<String, dynamic> json) = _$FollowImpl.fromJson;

  @override
  @JsonKey(name: 'follower_id')
  String get followerId;
  @override
  @JsonKey(name: 'followee_id')
  String get followeeId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
