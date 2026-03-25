// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brand.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Brand _$BrandFromJson(Map<String, dynamic> json) {
  return _Brand.fromJson(json);
}

/// @nodoc
mixin _$Brand {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get logoAsset => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;

  /// Serializes this Brand to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrandCopyWith<Brand> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrandCopyWith<$Res> {
  factory $BrandCopyWith(Brand value, $Res Function(Brand) then) = _$BrandCopyWithImpl<$Res, Brand>;
  @useResult
  $Res call({String id, String name, String slug, String country, String logoAsset, bool isPremium, List<String> categories, String? website});
}

/// @nodoc
class _$BrandCopyWithImpl<$Res, $Val extends Brand> implements $BrandCopyWith<$Res> {
  _$BrandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? country = null,
    Object? logoAsset = null,
    Object? isPremium = null,
    Object? categories = null,
    Object? website = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            logoAsset: null == logoAsset
                ? _value.logoAsset
                : logoAsset // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BrandImplCopyWith<$Res> implements $BrandCopyWith<$Res> {
  factory _$$BrandImplCopyWith(_$BrandImpl value, $Res Function(_$BrandImpl) then) = __$$BrandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String slug, String country, String logoAsset, bool isPremium, List<String> categories, String? website});
}

/// @nodoc
class __$$BrandImplCopyWithImpl<$Res> extends _$BrandCopyWithImpl<$Res, _$BrandImpl> implements _$$BrandImplCopyWith<$Res> {
  __$$BrandImplCopyWithImpl(_$BrandImpl _value, $Res Function(_$BrandImpl) _then) : super(_value, _then);

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? country = null,
    Object? logoAsset = null,
    Object? isPremium = null,
    Object? categories = null,
    Object? website = freezed,
  }) {
    return _then(
      _$BrandImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        logoAsset: null == logoAsset
            ? _value.logoAsset
            : logoAsset // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BrandImpl implements _Brand {
  const _$BrandImpl({
    required this.id,
    required this.name,
    required this.slug,
    required this.country,
    required this.logoAsset,
    required this.isPremium,
    required final List<String> categories,
    this.website,
  }) : _categories = categories;

  factory _$BrandImpl.fromJson(Map<String, dynamic> json) => _$$BrandImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String country;
  @override
  final String logoAsset;
  @override
  final bool isPremium;
  final List<String> _categories;
  @override
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  final String? website;

  @override
  String toString() {
    return 'Brand(id: $id, name: $name, slug: $slug, country: $country, logoAsset: $logoAsset, isPremium: $isPremium, categories: $categories, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrandImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.logoAsset, logoAsset) || other.logoAsset == logoAsset) &&
            (identical(other.isPremium, isPremium) || other.isPremium == isPremium) &&
            const DeepCollectionEquality().equals(other._categories, _categories) &&
            (identical(other.website, website) || other.website == website));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug, country, logoAsset, isPremium, const DeepCollectionEquality().hash(_categories), website);

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrandImplCopyWith<_$BrandImpl> get copyWith => __$$BrandImplCopyWithImpl<_$BrandImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrandImplToJson(this);
  }
}

abstract class _Brand implements Brand {
  const factory _Brand({
    required final String id,
    required final String name,
    required final String slug,
    required final String country,
    required final String logoAsset,
    required final bool isPremium,
    required final List<String> categories,
    final String? website,
  }) = _$BrandImpl;

  factory _Brand.fromJson(Map<String, dynamic> json) = _$BrandImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String get country;
  @override
  String get logoAsset;
  @override
  bool get isPremium;
  @override
  List<String> get categories;
  @override
  String? get website;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrandImplCopyWith<_$BrandImpl> get copyWith => throw _privateConstructorUsedError;
}
