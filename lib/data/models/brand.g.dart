// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandImpl _$$BrandImplFromJson(Map<String, dynamic> json) => _$BrandImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  country: json['country'] as String,
  logoAsset: json['logoAsset'] as String,
  isPremium: json['isPremium'] as bool,
  categories: (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
  website: json['website'] as String?,
);

Map<String, dynamic> _$$BrandImplToJson(_$BrandImpl instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'country': instance.country,
  'logoAsset': instance.logoAsset,
  'isPremium': instance.isPremium,
  'categories': instance.categories,
  'website': instance.website,
};
