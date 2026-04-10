// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Submission _$SubmissionFromJson(Map<String, dynamic> json) {
  return _Submission.fromJson(json);
}

/// @nodoc
mixin _$Submission {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'storage_path')
  String get storagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_hash')
  String? get imageHash => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_approach')
  String get primaryApproach => throw _privateConstructorUsedError;
  SubmissionState get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_awarded')
  int get pointsAwarded => throw _privateConstructorUsedError;
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'flagged_reason')
  String? get flaggedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'duplicate_of')
  String? get duplicateOf => throw _privateConstructorUsedError;
  @JsonKey(name: 'classified_at')
  DateTime? get classifiedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Submission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionCopyWith<Submission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionCopyWith<$Res> {
  factory $SubmissionCopyWith(
    Submission value,
    $Res Function(Submission) then,
  ) = _$SubmissionCopyWithImpl<$Res, Submission>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String username,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'storage_path') String storagePath,
    @JsonKey(name: 'image_hash') String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    @JsonKey(name: 'primary_approach') String primaryApproach,
    SubmissionState state,
    @JsonKey(name: 'points_awarded') int pointsAwarded,
    @JsonKey(name: 'idempotency_key') String idempotencyKey,
    @JsonKey(name: 'flagged_reason') String? flaggedReason,
    @JsonKey(name: 'duplicate_of') String? duplicateOf,
    @JsonKey(name: 'classified_at') DateTime? classifiedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$SubmissionCopyWithImpl<$Res, $Val extends Submission>
    implements $SubmissionCopyWith<$Res> {
  _$SubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? imageUrl = null,
    Object? storagePath = null,
    Object? imageHash = freezed,
    Object? category = freezed,
    Object? subcategory = freezed,
    Object? confidence = freezed,
    Object? primaryApproach = null,
    Object? state = null,
    Object? pointsAwarded = null,
    Object? idempotencyKey = null,
    Object? flaggedReason = freezed,
    Object? duplicateOf = freezed,
    Object? classifiedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            storagePath: null == storagePath
                ? _value.storagePath
                : storagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            imageHash: freezed == imageHash
                ? _value.imageHash
                : imageHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            subcategory: freezed == subcategory
                ? _value.subcategory
                : subcategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            primaryApproach: null == primaryApproach
                ? _value.primaryApproach
                : primaryApproach // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as SubmissionState,
            pointsAwarded: null == pointsAwarded
                ? _value.pointsAwarded
                : pointsAwarded // ignore: cast_nullable_to_non_nullable
                      as int,
            idempotencyKey: null == idempotencyKey
                ? _value.idempotencyKey
                : idempotencyKey // ignore: cast_nullable_to_non_nullable
                      as String,
            flaggedReason: freezed == flaggedReason
                ? _value.flaggedReason
                : flaggedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            duplicateOf: freezed == duplicateOf
                ? _value.duplicateOf
                : duplicateOf // ignore: cast_nullable_to_non_nullable
                      as String?,
            classifiedAt: freezed == classifiedAt
                ? _value.classifiedAt
                : classifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionImplCopyWith<$Res>
    implements $SubmissionCopyWith<$Res> {
  factory _$$SubmissionImplCopyWith(
    _$SubmissionImpl value,
    $Res Function(_$SubmissionImpl) then,
  ) = __$$SubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String username,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'storage_path') String storagePath,
    @JsonKey(name: 'image_hash') String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    @JsonKey(name: 'primary_approach') String primaryApproach,
    SubmissionState state,
    @JsonKey(name: 'points_awarded') int pointsAwarded,
    @JsonKey(name: 'idempotency_key') String idempotencyKey,
    @JsonKey(name: 'flagged_reason') String? flaggedReason,
    @JsonKey(name: 'duplicate_of') String? duplicateOf,
    @JsonKey(name: 'classified_at') DateTime? classifiedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubmissionImplCopyWithImpl<$Res>
    extends _$SubmissionCopyWithImpl<$Res, _$SubmissionImpl>
    implements _$$SubmissionImplCopyWith<$Res> {
  __$$SubmissionImplCopyWithImpl(
    _$SubmissionImpl _value,
    $Res Function(_$SubmissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? imageUrl = null,
    Object? storagePath = null,
    Object? imageHash = freezed,
    Object? category = freezed,
    Object? subcategory = freezed,
    Object? confidence = freezed,
    Object? primaryApproach = null,
    Object? state = null,
    Object? pointsAwarded = null,
    Object? idempotencyKey = null,
    Object? flaggedReason = freezed,
    Object? duplicateOf = freezed,
    Object? classifiedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubmissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        storagePath: null == storagePath
            ? _value.storagePath
            : storagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        imageHash: freezed == imageHash
            ? _value.imageHash
            : imageHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        subcategory: freezed == subcategory
            ? _value.subcategory
            : subcategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: freezed == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        primaryApproach: null == primaryApproach
            ? _value.primaryApproach
            : primaryApproach // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as SubmissionState,
        pointsAwarded: null == pointsAwarded
            ? _value.pointsAwarded
            : pointsAwarded // ignore: cast_nullable_to_non_nullable
                  as int,
        idempotencyKey: null == idempotencyKey
            ? _value.idempotencyKey
            : idempotencyKey // ignore: cast_nullable_to_non_nullable
                  as String,
        flaggedReason: freezed == flaggedReason
            ? _value.flaggedReason
            : flaggedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        duplicateOf: freezed == duplicateOf
            ? _value.duplicateOf
            : duplicateOf // ignore: cast_nullable_to_non_nullable
                  as String?,
        classifiedAt: freezed == classifiedAt
            ? _value.classifiedAt
            : classifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionImpl implements _Submission {
  const _$SubmissionImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.username,
    @JsonKey(name: 'image_url') required this.imageUrl,
    @JsonKey(name: 'storage_path') required this.storagePath,
    @JsonKey(name: 'image_hash') this.imageHash,
    this.category,
    this.subcategory,
    this.confidence,
    @JsonKey(name: 'primary_approach') this.primaryApproach = 'gemini',
    required this.state,
    @JsonKey(name: 'points_awarded') this.pointsAwarded = 0,
    @JsonKey(name: 'idempotency_key') required this.idempotencyKey,
    @JsonKey(name: 'flagged_reason') this.flaggedReason,
    @JsonKey(name: 'duplicate_of') this.duplicateOf,
    @JsonKey(name: 'classified_at') this.classifiedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$SubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String username;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'storage_path')
  final String storagePath;
  @override
  @JsonKey(name: 'image_hash')
  final String? imageHash;
  @override
  final String? category;
  @override
  final String? subcategory;
  @override
  final double? confidence;
  @override
  @JsonKey(name: 'primary_approach')
  final String primaryApproach;
  @override
  final SubmissionState state;
  @override
  @JsonKey(name: 'points_awarded')
  final int pointsAwarded;
  @override
  @JsonKey(name: 'idempotency_key')
  final String idempotencyKey;
  @override
  @JsonKey(name: 'flagged_reason')
  final String? flaggedReason;
  @override
  @JsonKey(name: 'duplicate_of')
  final String? duplicateOf;
  @override
  @JsonKey(name: 'classified_at')
  final DateTime? classifiedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Submission(id: $id, userId: $userId, username: $username, imageUrl: $imageUrl, storagePath: $storagePath, imageHash: $imageHash, category: $category, subcategory: $subcategory, confidence: $confidence, primaryApproach: $primaryApproach, state: $state, pointsAwarded: $pointsAwarded, idempotencyKey: $idempotencyKey, flaggedReason: $flaggedReason, duplicateOf: $duplicateOf, classifiedAt: $classifiedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.imageHash, imageHash) ||
                other.imageHash == imageHash) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.primaryApproach, primaryApproach) ||
                other.primaryApproach == primaryApproach) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pointsAwarded, pointsAwarded) ||
                other.pointsAwarded == pointsAwarded) &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey) &&
            (identical(other.flaggedReason, flaggedReason) ||
                other.flaggedReason == flaggedReason) &&
            (identical(other.duplicateOf, duplicateOf) ||
                other.duplicateOf == duplicateOf) &&
            (identical(other.classifiedAt, classifiedAt) ||
                other.classifiedAt == classifiedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    username,
    imageUrl,
    storagePath,
    imageHash,
    category,
    subcategory,
    confidence,
    primaryApproach,
    state,
    pointsAwarded,
    idempotencyKey,
    flaggedReason,
    duplicateOf,
    classifiedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      __$$SubmissionImplCopyWithImpl<_$SubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionImplToJson(this);
  }
}

abstract class _Submission implements Submission {
  const factory _Submission({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String username,
    @JsonKey(name: 'image_url') required final String imageUrl,
    @JsonKey(name: 'storage_path') required final String storagePath,
    @JsonKey(name: 'image_hash') final String? imageHash,
    final String? category,
    final String? subcategory,
    final double? confidence,
    @JsonKey(name: 'primary_approach') final String primaryApproach,
    required final SubmissionState state,
    @JsonKey(name: 'points_awarded') final int pointsAwarded,
    @JsonKey(name: 'idempotency_key') required final String idempotencyKey,
    @JsonKey(name: 'flagged_reason') final String? flaggedReason,
    @JsonKey(name: 'duplicate_of') final String? duplicateOf,
    @JsonKey(name: 'classified_at') final DateTime? classifiedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$SubmissionImpl;

  factory _Submission.fromJson(Map<String, dynamic> json) =
      _$SubmissionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get username;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'storage_path')
  String get storagePath;
  @override
  @JsonKey(name: 'image_hash')
  String? get imageHash;
  @override
  String? get category;
  @override
  String? get subcategory;
  @override
  double? get confidence;
  @override
  @JsonKey(name: 'primary_approach')
  String get primaryApproach;
  @override
  SubmissionState get state;
  @override
  @JsonKey(name: 'points_awarded')
  int get pointsAwarded;
  @override
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey;
  @override
  @JsonKey(name: 'flagged_reason')
  String? get flaggedReason;
  @override
  @JsonKey(name: 'duplicate_of')
  String? get duplicateOf;
  @override
  @JsonKey(name: 'classified_at')
  DateTime? get classifiedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
