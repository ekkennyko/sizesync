// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversion_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConversionRecord _$ConversionRecordFromJson(Map<String, dynamic> json) {
  return _ConversionRecord.fromJson(json);
}

/// @nodoc
mixin _$ConversionRecord {
  String get fromBrandSlug => throw _privateConstructorUsedError;
  String get toBrandSlug => throw _privateConstructorUsedError;
  String get categorySlug => throw _privateConstructorUsedError;
  String get fromSize => throw _privateConstructorUsedError;
  String get toSize => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ConversionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversionRecordCopyWith<ConversionRecord> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversionRecordCopyWith<$Res> {
  factory $ConversionRecordCopyWith(ConversionRecord value, $Res Function(ConversionRecord) then) = _$ConversionRecordCopyWithImpl<$Res, ConversionRecord>;
  @useResult
  $Res call({String fromBrandSlug, String toBrandSlug, String categorySlug, String fromSize, String toSize, DateTime timestamp});
}

/// @nodoc
class _$ConversionRecordCopyWithImpl<$Res, $Val extends ConversionRecord> implements $ConversionRecordCopyWith<$Res> {
  _$ConversionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromBrandSlug = null,
    Object? toBrandSlug = null,
    Object? categorySlug = null,
    Object? fromSize = null,
    Object? toSize = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            fromBrandSlug: null == fromBrandSlug
                ? _value.fromBrandSlug
                : fromBrandSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            toBrandSlug: null == toBrandSlug
                ? _value.toBrandSlug
                : toBrandSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            categorySlug: null == categorySlug
                ? _value.categorySlug
                : categorySlug // ignore: cast_nullable_to_non_nullable
                      as String,
            fromSize: null == fromSize
                ? _value.fromSize
                : fromSize // ignore: cast_nullable_to_non_nullable
                      as String,
            toSize: null == toSize
                ? _value.toSize
                : toSize // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ConversionRecordImplCopyWith<$Res> implements $ConversionRecordCopyWith<$Res> {
  factory _$$ConversionRecordImplCopyWith(_$ConversionRecordImpl value, $Res Function(_$ConversionRecordImpl) then) =
      __$$ConversionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fromBrandSlug, String toBrandSlug, String categorySlug, String fromSize, String toSize, DateTime timestamp});
}

/// @nodoc
class __$$ConversionRecordImplCopyWithImpl<$Res> extends _$ConversionRecordCopyWithImpl<$Res, _$ConversionRecordImpl>
    implements _$$ConversionRecordImplCopyWith<$Res> {
  __$$ConversionRecordImplCopyWithImpl(_$ConversionRecordImpl _value, $Res Function(_$ConversionRecordImpl) _then) : super(_value, _then);

  /// Create a copy of ConversionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromBrandSlug = null,
    Object? toBrandSlug = null,
    Object? categorySlug = null,
    Object? fromSize = null,
    Object? toSize = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ConversionRecordImpl(
        fromBrandSlug: null == fromBrandSlug
            ? _value.fromBrandSlug
            : fromBrandSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        toBrandSlug: null == toBrandSlug
            ? _value.toBrandSlug
            : toBrandSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        categorySlug: null == categorySlug
            ? _value.categorySlug
            : categorySlug // ignore: cast_nullable_to_non_nullable
                  as String,
        fromSize: null == fromSize
            ? _value.fromSize
            : fromSize // ignore: cast_nullable_to_non_nullable
                  as String,
        toSize: null == toSize
            ? _value.toSize
            : toSize // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ConversionRecordImpl implements _ConversionRecord {
  const _$ConversionRecordImpl({
    required this.fromBrandSlug,
    required this.toBrandSlug,
    required this.categorySlug,
    required this.fromSize,
    required this.toSize,
    required this.timestamp,
  });

  factory _$ConversionRecordImpl.fromJson(Map<String, dynamic> json) => _$$ConversionRecordImplFromJson(json);

  @override
  final String fromBrandSlug;
  @override
  final String toBrandSlug;
  @override
  final String categorySlug;
  @override
  final String fromSize;
  @override
  final String toSize;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ConversionRecord(fromBrandSlug: $fromBrandSlug, toBrandSlug: $toBrandSlug, categorySlug: $categorySlug, fromSize: $fromSize, toSize: $toSize, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversionRecordImpl &&
            (identical(other.fromBrandSlug, fromBrandSlug) || other.fromBrandSlug == fromBrandSlug) &&
            (identical(other.toBrandSlug, toBrandSlug) || other.toBrandSlug == toBrandSlug) &&
            (identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug) &&
            (identical(other.fromSize, fromSize) || other.fromSize == fromSize) &&
            (identical(other.toSize, toSize) || other.toSize == toSize) &&
            (identical(other.timestamp, timestamp) || other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fromBrandSlug, toBrandSlug, categorySlug, fromSize, toSize, timestamp);

  /// Create a copy of ConversionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversionRecordImplCopyWith<_$ConversionRecordImpl> get copyWith => __$$ConversionRecordImplCopyWithImpl<_$ConversionRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversionRecordImplToJson(this);
  }
}

abstract class _ConversionRecord implements ConversionRecord {
  const factory _ConversionRecord({
    required final String fromBrandSlug,
    required final String toBrandSlug,
    required final String categorySlug,
    required final String fromSize,
    required final String toSize,
    required final DateTime timestamp,
  }) = _$ConversionRecordImpl;

  factory _ConversionRecord.fromJson(Map<String, dynamic> json) = _$ConversionRecordImpl.fromJson;

  @override
  String get fromBrandSlug;
  @override
  String get toBrandSlug;
  @override
  String get categorySlug;
  @override
  String get fromSize;
  @override
  String get toSize;
  @override
  DateTime get timestamp;

  /// Create a copy of ConversionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversionRecordImplCopyWith<_$ConversionRecordImpl> get copyWith => throw _privateConstructorUsedError;
}
