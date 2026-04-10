// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Dispute _$DisputeFromJson(Map<String, dynamic> json) {
  return _Dispute.fromJson(json);
}

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  String get submissionId => throw _privateConstructorUsedError;
  String get submitterId => throw _privateConstructorUsedError;
  String get originalCategory => throw _privateConstructorUsedError;
  double get originalConfidence => throw _privateConstructorUsedError;
  String? get secondaryCategory => throw _privateConstructorUsedError;
  double? get secondaryConfidence => throw _privateConstructorUsedError;
  String? get resolvedCategory => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  String? get resolutionNote => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this Dispute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeCopyWith<Dispute> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeCopyWith<$Res> {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) then) =
      _$DisputeCopyWithImpl<$Res, Dispute>;
  @useResult
  $Res call({
    String id,
    String submissionId,
    String submitterId,
    String originalCategory,
    double originalConfidence,
    String? secondaryCategory,
    double? secondaryConfidence,
    String? resolvedCategory,
    String? resolvedBy,
    String? resolution,
    String? resolutionNote,
    String status,
    DateTime createdAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class _$DisputeCopyWithImpl<$Res, $Val extends Dispute>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? submitterId = null,
    Object? originalCategory = null,
    Object? originalConfidence = null,
    Object? secondaryCategory = freezed,
    Object? secondaryConfidence = freezed,
    Object? resolvedCategory = freezed,
    Object? resolvedBy = freezed,
    Object? resolution = freezed,
    Object? resolutionNote = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            submissionId: null == submissionId
                ? _value.submissionId
                : submissionId // ignore: cast_nullable_to_non_nullable
                      as String,
            submitterId: null == submitterId
                ? _value.submitterId
                : submitterId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalCategory: null == originalCategory
                ? _value.originalCategory
                : originalCategory // ignore: cast_nullable_to_non_nullable
                      as String,
            originalConfidence: null == originalConfidence
                ? _value.originalConfidence
                : originalConfidence // ignore: cast_nullable_to_non_nullable
                      as double,
            secondaryCategory: freezed == secondaryCategory
                ? _value.secondaryCategory
                : secondaryCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            secondaryConfidence: freezed == secondaryConfidence
                ? _value.secondaryConfidence
                : secondaryConfidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            resolvedCategory: freezed == resolvedCategory
                ? _value.resolvedCategory
                : resolvedCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolution: freezed == resolution
                ? _value.resolution
                : resolution // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolutionNote: freezed == resolutionNote
                ? _value.resolutionNote
                : resolutionNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
    _$DisputeImpl value,
    $Res Function(_$DisputeImpl) then,
  ) = __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String submissionId,
    String submitterId,
    String originalCategory,
    double originalConfidence,
    String? secondaryCategory,
    double? secondaryConfidence,
    String? resolvedCategory,
    String? resolvedBy,
    String? resolution,
    String? resolutionNote,
    String status,
    DateTime createdAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
    _$DisputeImpl _value,
    $Res Function(_$DisputeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? submitterId = null,
    Object? originalCategory = null,
    Object? originalConfidence = null,
    Object? secondaryCategory = freezed,
    Object? secondaryConfidence = freezed,
    Object? resolvedCategory = freezed,
    Object? resolvedBy = freezed,
    Object? resolution = freezed,
    Object? resolutionNote = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _$DisputeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        submissionId: null == submissionId
            ? _value.submissionId
            : submissionId // ignore: cast_nullable_to_non_nullable
                  as String,
        submitterId: null == submitterId
            ? _value.submitterId
            : submitterId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalCategory: null == originalCategory
            ? _value.originalCategory
            : originalCategory // ignore: cast_nullable_to_non_nullable
                  as String,
        originalConfidence: null == originalConfidence
            ? _value.originalConfidence
            : originalConfidence // ignore: cast_nullable_to_non_nullable
                  as double,
        secondaryCategory: freezed == secondaryCategory
            ? _value.secondaryCategory
            : secondaryCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        secondaryConfidence: freezed == secondaryConfidence
            ? _value.secondaryConfidence
            : secondaryConfidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        resolvedCategory: freezed == resolvedCategory
            ? _value.resolvedCategory
            : resolvedCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolution: freezed == resolution
            ? _value.resolution
            : resolution // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolutionNote: freezed == resolutionNote
            ? _value.resolutionNote
            : resolutionNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl({
    required this.id,
    required this.submissionId,
    required this.submitterId,
    required this.originalCategory,
    required this.originalConfidence,
    this.secondaryCategory,
    this.secondaryConfidence,
    this.resolvedCategory,
    this.resolvedBy,
    this.resolution,
    this.resolutionNote,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory _$DisputeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeImplFromJson(json);

  @override
  final String id;
  @override
  final String submissionId;
  @override
  final String submitterId;
  @override
  final String originalCategory;
  @override
  final double originalConfidence;
  @override
  final String? secondaryCategory;
  @override
  final double? secondaryConfidence;
  @override
  final String? resolvedCategory;
  @override
  final String? resolvedBy;
  @override
  final String? resolution;
  @override
  final String? resolutionNote;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'Dispute(id: $id, submissionId: $submissionId, submitterId: $submitterId, originalCategory: $originalCategory, originalConfidence: $originalConfidence, secondaryCategory: $secondaryCategory, secondaryConfidence: $secondaryConfidence, resolvedCategory: $resolvedCategory, resolvedBy: $resolvedBy, resolution: $resolution, resolutionNote: $resolutionNote, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.submitterId, submitterId) ||
                other.submitterId == submitterId) &&
            (identical(other.originalCategory, originalCategory) ||
                other.originalCategory == originalCategory) &&
            (identical(other.originalConfidence, originalConfidence) ||
                other.originalConfidence == originalConfidence) &&
            (identical(other.secondaryCategory, secondaryCategory) ||
                other.secondaryCategory == secondaryCategory) &&
            (identical(other.secondaryConfidence, secondaryConfidence) ||
                other.secondaryConfidence == secondaryConfidence) &&
            (identical(other.resolvedCategory, resolvedCategory) ||
                other.resolvedCategory == resolvedCategory) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.resolutionNote, resolutionNote) ||
                other.resolutionNote == resolutionNote) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    submissionId,
    submitterId,
    originalCategory,
    originalConfidence,
    secondaryCategory,
    secondaryConfidence,
    resolvedCategory,
    resolvedBy,
    resolution,
    resolutionNote,
    status,
    createdAt,
    resolvedAt,
  );

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeImplToJson(this);
  }
}

abstract class _Dispute implements Dispute {
  const factory _Dispute({
    required final String id,
    required final String submissionId,
    required final String submitterId,
    required final String originalCategory,
    required final double originalConfidence,
    final String? secondaryCategory,
    final double? secondaryConfidence,
    final String? resolvedCategory,
    final String? resolvedBy,
    final String? resolution,
    final String? resolutionNote,
    required final String status,
    required final DateTime createdAt,
    final DateTime? resolvedAt,
  }) = _$DisputeImpl;

  factory _Dispute.fromJson(Map<String, dynamic> json) = _$DisputeImpl.fromJson;

  @override
  String get id;
  @override
  String get submissionId;
  @override
  String get submitterId;
  @override
  String get originalCategory;
  @override
  double get originalConfidence;
  @override
  String? get secondaryCategory;
  @override
  double? get secondaryConfidence;
  @override
  String? get resolvedCategory;
  @override
  String? get resolvedBy;
  @override
  String? get resolution;
  @override
  String? get resolutionNote;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
