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
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  String? get imageHash => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  String get primaryApproach => throw _privateConstructorUsedError;
  SubmissionState get state => throw _privateConstructorUsedError;
  int get pointsAwarded => throw _privateConstructorUsedError;
  String get idempotencyKey => throw _privateConstructorUsedError;
  String? get flaggedReason => throw _privateConstructorUsedError;
  String? get duplicateOf => throw _privateConstructorUsedError;
  DateTime? get classifiedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
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
    String userId,
    String username,
    String imageUrl,
    String storagePath,
    String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    String primaryApproach,
    SubmissionState state,
    int pointsAwarded,
    String idempotencyKey,
    String? flaggedReason,
    String? duplicateOf,
    DateTime? classifiedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    String userId,
    String username,
    String imageUrl,
    String storagePath,
    String? imageHash,
    String? category,
    String? subcategory,
    double? confidence,
    String primaryApproach,
    SubmissionState state,
    int pointsAwarded,
    String idempotencyKey,
    String? flaggedReason,
    String? duplicateOf,
    DateTime? classifiedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    required this.userId,
    required this.username,
    required this.imageUrl,
    required this.storagePath,
    this.imageHash,
    this.category,
    this.subcategory,
    this.confidence,
    this.primaryApproach = 'gemini',
    required this.state,
    this.pointsAwarded = 0,
    required this.idempotencyKey,
    this.flaggedReason,
    this.duplicateOf,
    this.classifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String username;
  @override
  final String imageUrl;
  @override
  final String storagePath;
  @override
  final String? imageHash;
  @override
  final String? category;
  @override
  final String? subcategory;
  @override
  final double? confidence;
  @override
  @JsonKey()
  final String primaryApproach;
  @override
  final SubmissionState state;
  @override
  @JsonKey()
  final int pointsAwarded;
  @override
  final String idempotencyKey;
  @override
  final String? flaggedReason;
  @override
  final String? duplicateOf;
  @override
  final DateTime? classifiedAt;
  @override
  final DateTime createdAt;
  @override
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
    required final String userId,
    required final String username,
    required final String imageUrl,
    required final String storagePath,
    final String? imageHash,
    final String? category,
    final String? subcategory,
    final double? confidence,
    final String primaryApproach,
    required final SubmissionState state,
    final int pointsAwarded,
    required final String idempotencyKey,
    final String? flaggedReason,
    final String? duplicateOf,
    final DateTime? classifiedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubmissionImpl;

  factory _Submission.fromJson(Map<String, dynamic> json) =
      _$SubmissionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get username;
  @override
  String get imageUrl;
  @override
  String get storagePath;
  @override
  String? get imageHash;
  @override
  String? get category;
  @override
  String? get subcategory;
  @override
  double? get confidence;
  @override
  String get primaryApproach;
  @override
  SubmissionState get state;
  @override
  int get pointsAwarded;
  @override
  String get idempotencyKey;
  @override
  String? get flaggedReason;
  @override
  String? get duplicateOf;
  @override
  DateTime? get classifiedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
