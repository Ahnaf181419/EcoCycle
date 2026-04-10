// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Classification _$ClassificationFromJson(Map<String, dynamic> json) {
  return _Classification.fromJson(json);
}

/// @nodoc
mixin _$Classification {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'submission_id')
  String get submissionId => throw _privateConstructorUsedError;
  String get approach => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_version')
  String get modelVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_response')
  Map<String, dynamic>? get rawResponse => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this Classification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Classification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassificationCopyWith<Classification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassificationCopyWith<$Res> {
  factory $ClassificationCopyWith(
    Classification value,
    $Res Function(Classification) then,
  ) = _$ClassificationCopyWithImpl<$Res, Classification>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_id') String submissionId,
    String approach,
    String category,
    String? subcategory,
    double confidence,
    @JsonKey(name: 'model_version') String modelVersion,
    @JsonKey(name: 'raw_response') Map<String, dynamic>? rawResponse,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ClassificationCopyWithImpl<$Res, $Val extends Classification>
    implements $ClassificationCopyWith<$Res> {
  _$ClassificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Classification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? approach = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? confidence = null,
    Object? modelVersion = null,
    Object? rawResponse = freezed,
    Object? timestamp = null,
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
            approach: null == approach
                ? _value.approach
                : approach // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            subcategory: freezed == subcategory
                ? _value.subcategory
                : subcategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            modelVersion: null == modelVersion
                ? _value.modelVersion
                : modelVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            rawResponse: freezed == rawResponse
                ? _value.rawResponse
                : rawResponse // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassificationImplCopyWith<$Res>
    implements $ClassificationCopyWith<$Res> {
  factory _$$ClassificationImplCopyWith(
    _$ClassificationImpl value,
    $Res Function(_$ClassificationImpl) then,
  ) = __$$ClassificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_id') String submissionId,
    String approach,
    String category,
    String? subcategory,
    double confidence,
    @JsonKey(name: 'model_version') String modelVersion,
    @JsonKey(name: 'raw_response') Map<String, dynamic>? rawResponse,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ClassificationImplCopyWithImpl<$Res>
    extends _$ClassificationCopyWithImpl<$Res, _$ClassificationImpl>
    implements _$$ClassificationImplCopyWith<$Res> {
  __$$ClassificationImplCopyWithImpl(
    _$ClassificationImpl _value,
    $Res Function(_$ClassificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Classification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? approach = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? confidence = null,
    Object? modelVersion = null,
    Object? rawResponse = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$ClassificationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        submissionId: null == submissionId
            ? _value.submissionId
            : submissionId // ignore: cast_nullable_to_non_nullable
                  as String,
        approach: null == approach
            ? _value.approach
            : approach // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        subcategory: freezed == subcategory
            ? _value.subcategory
            : subcategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        modelVersion: null == modelVersion
            ? _value.modelVersion
            : modelVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        rawResponse: freezed == rawResponse
            ? _value._rawResponse
            : rawResponse // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassificationImpl implements _Classification {
  const _$ClassificationImpl({
    required this.id,
    @JsonKey(name: 'submission_id') required this.submissionId,
    required this.approach,
    required this.category,
    this.subcategory,
    required this.confidence,
    @JsonKey(name: 'model_version') required this.modelVersion,
    @JsonKey(name: 'raw_response') final Map<String, dynamic>? rawResponse,
    required this.timestamp,
  }) : _rawResponse = rawResponse;

  factory _$ClassificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassificationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'submission_id')
  final String submissionId;
  @override
  final String approach;
  @override
  final String category;
  @override
  final String? subcategory;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'model_version')
  final String modelVersion;
  final Map<String, dynamic>? _rawResponse;
  @override
  @JsonKey(name: 'raw_response')
  Map<String, dynamic>? get rawResponse {
    final value = _rawResponse;
    if (value == null) return null;
    if (_rawResponse is EqualUnmodifiableMapView) return _rawResponse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'Classification(id: $id, submissionId: $submissionId, approach: $approach, category: $category, subcategory: $subcategory, confidence: $confidence, modelVersion: $modelVersion, rawResponse: $rawResponse, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.approach, approach) ||
                other.approach == approach) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.modelVersion, modelVersion) ||
                other.modelVersion == modelVersion) &&
            const DeepCollectionEquality().equals(
              other._rawResponse,
              _rawResponse,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    submissionId,
    approach,
    category,
    subcategory,
    confidence,
    modelVersion,
    const DeepCollectionEquality().hash(_rawResponse),
    timestamp,
  );

  /// Create a copy of Classification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassificationImplCopyWith<_$ClassificationImpl> get copyWith =>
      __$$ClassificationImplCopyWithImpl<_$ClassificationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassificationImplToJson(this);
  }
}

abstract class _Classification implements Classification {
  const factory _Classification({
    required final String id,
    @JsonKey(name: 'submission_id') required final String submissionId,
    required final String approach,
    required final String category,
    final String? subcategory,
    required final double confidence,
    @JsonKey(name: 'model_version') required final String modelVersion,
    @JsonKey(name: 'raw_response') final Map<String, dynamic>? rawResponse,
    required final DateTime timestamp,
  }) = _$ClassificationImpl;

  factory _Classification.fromJson(Map<String, dynamic> json) =
      _$ClassificationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'submission_id')
  String get submissionId;
  @override
  String get approach;
  @override
  String get category;
  @override
  String? get subcategory;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'model_version')
  String get modelVersion;
  @override
  @JsonKey(name: 'raw_response')
  Map<String, dynamic>? get rawResponse;
  @override
  DateTime get timestamp;

  /// Create a copy of Classification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassificationImplCopyWith<_$ClassificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
