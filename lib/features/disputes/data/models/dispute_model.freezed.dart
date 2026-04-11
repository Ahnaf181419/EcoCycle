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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Dispute _$DisputeFromJson(Map<String, dynamic> json) {
  return _Dispute.fromJson(json);
}

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'submission_id')
  String get submissionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'submitter_id')
  String get submitterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_category')
  String get originalCategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_confidence')
  double get originalConfidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'secondary_category')
  String? get secondaryCategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'secondary_confidence')
  double? get secondaryConfidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_category')
  String? get resolvedCategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolution_note')
  String? get resolutionNote => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
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
  $Res call(
      {String id,
      @JsonKey(name: 'submission_id') String submissionId,
      @JsonKey(name: 'submitter_id') String submitterId,
      @JsonKey(name: 'original_category') String originalCategory,
      @JsonKey(name: 'original_confidence') double originalConfidence,
      @JsonKey(name: 'secondary_category') String? secondaryCategory,
      @JsonKey(name: 'secondary_confidence') double? secondaryConfidence,
      @JsonKey(name: 'resolved_category') String? resolvedCategory,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      String? resolution,
      @JsonKey(name: 'resolution_note') String? resolutionNote,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt});
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
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
          _$DisputeImpl value, $Res Function(_$DisputeImpl) then) =
      __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'submission_id') String submissionId,
      @JsonKey(name: 'submitter_id') String submitterId,
      @JsonKey(name: 'original_category') String originalCategory,
      @JsonKey(name: 'original_confidence') double originalConfidence,
      @JsonKey(name: 'secondary_category') String? secondaryCategory,
      @JsonKey(name: 'secondary_confidence') double? secondaryConfidence,
      @JsonKey(name: 'resolved_category') String? resolvedCategory,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      String? resolution,
      @JsonKey(name: 'resolution_note') String? resolutionNote,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt});
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
      _$DisputeImpl _value, $Res Function(_$DisputeImpl) _then)
      : super(_value, _then);

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
    return _then(_$DisputeImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl(
      {required this.id,
      @JsonKey(name: 'submission_id') required this.submissionId,
      @JsonKey(name: 'submitter_id') required this.submitterId,
      @JsonKey(name: 'original_category') required this.originalCategory,
      @JsonKey(name: 'original_confidence') required this.originalConfidence,
      @JsonKey(name: 'secondary_category') this.secondaryCategory,
      @JsonKey(name: 'secondary_confidence') this.secondaryConfidence,
      @JsonKey(name: 'resolved_category') this.resolvedCategory,
      @JsonKey(name: 'resolved_by') this.resolvedBy,
      this.resolution,
      @JsonKey(name: 'resolution_note') this.resolutionNote,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'resolved_at') this.resolvedAt});

  factory _$DisputeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'submission_id')
  final String submissionId;
  @override
  @JsonKey(name: 'submitter_id')
  final String submitterId;
  @override
  @JsonKey(name: 'original_category')
  final String originalCategory;
  @override
  @JsonKey(name: 'original_confidence')
  final double originalConfidence;
  @override
  @JsonKey(name: 'secondary_category')
  final String? secondaryCategory;
  @override
  @JsonKey(name: 'secondary_confidence')
  final double? secondaryConfidence;
  @override
  @JsonKey(name: 'resolved_category')
  final String? resolvedCategory;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
  @override
  final String? resolution;
  @override
  @JsonKey(name: 'resolution_note')
  final String? resolutionNote;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'resolved_at')
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
      resolvedAt);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeImplToJson(
      this,
    );
  }
}

abstract class _Dispute implements Dispute {
  const factory _Dispute(
      {required final String id,
      @JsonKey(name: 'submission_id') required final String submissionId,
      @JsonKey(name: 'submitter_id') required final String submitterId,
      @JsonKey(name: 'original_category')
      required final String originalCategory,
      @JsonKey(name: 'original_confidence')
      required final double originalConfidence,
      @JsonKey(name: 'secondary_category') final String? secondaryCategory,
      @JsonKey(name: 'secondary_confidence') final double? secondaryConfidence,
      @JsonKey(name: 'resolved_category') final String? resolvedCategory,
      @JsonKey(name: 'resolved_by') final String? resolvedBy,
      final String? resolution,
      @JsonKey(name: 'resolution_note') final String? resolutionNote,
      required final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'resolved_at')
      final DateTime? resolvedAt}) = _$DisputeImpl;

  factory _Dispute.fromJson(Map<String, dynamic> json) = _$DisputeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'submission_id')
  String get submissionId;
  @override
  @JsonKey(name: 'submitter_id')
  String get submitterId;
  @override
  @JsonKey(name: 'original_category')
  String get originalCategory;
  @override
  @JsonKey(name: 'original_confidence')
  double get originalConfidence;
  @override
  @JsonKey(name: 'secondary_category')
  String? get secondaryCategory;
  @override
  @JsonKey(name: 'secondary_confidence')
  double? get secondaryConfidence;
  @override
  @JsonKey(name: 'resolved_category')
  String? get resolvedCategory;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy;
  @override
  String? get resolution;
  @override
  @JsonKey(name: 'resolution_note')
  String? get resolutionNote;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
