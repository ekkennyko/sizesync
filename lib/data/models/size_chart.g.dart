// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'size_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SizeEntryImpl _$$SizeEntryImplFromJson(Map<String, dynamic> json) => _$SizeEntryImpl(
  label: json['label'] as String,
  us: json['us'] as String?,
  uk: json['uk'] as String?,
  eu: json['eu'] as String?,
  asia: json['asia'] as String?,
  bustMinCm: (json['bustMinCm'] as num?)?.toDouble(),
  bustMaxCm: (json['bustMaxCm'] as num?)?.toDouble(),
  waistMinCm: (json['waistMinCm'] as num?)?.toDouble(),
  waistMaxCm: (json['waistMaxCm'] as num?)?.toDouble(),
  hipsMinCm: (json['hipsMinCm'] as num?)?.toDouble(),
  hipsMaxCm: (json['hipsMaxCm'] as num?)?.toDouble(),
  footLengthCm: (json['footLengthCm'] as num?)?.toDouble(),
  shoulderWidthCm: (json['shoulderWidthCm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$SizeEntryImplToJson(_$SizeEntryImpl instance) => <String, dynamic>{
  'label': instance.label,
  'us': instance.us,
  'uk': instance.uk,
  'eu': instance.eu,
  'asia': instance.asia,
  'bustMinCm': instance.bustMinCm,
  'bustMaxCm': instance.bustMaxCm,
  'waistMinCm': instance.waistMinCm,
  'waistMaxCm': instance.waistMaxCm,
  'hipsMinCm': instance.hipsMinCm,
  'hipsMaxCm': instance.hipsMaxCm,
  'footLengthCm': instance.footLengthCm,
  'shoulderWidthCm': instance.shoulderWidthCm,
};

_$SizeChartImpl _$$SizeChartImplFromJson(Map<String, dynamic> json) => _$SizeChartImpl(
  brandSlug: json['brandSlug'] as String,
  categorySlug: json['categorySlug'] as String,
  garmentType: json['garmentType'] as String,
  sizes: (json['sizes'] as List<dynamic>).map((e) => SizeEntry.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$$SizeChartImplToJson(_$SizeChartImpl instance) => <String, dynamic>{
  'brandSlug': instance.brandSlug,
  'categorySlug': instance.categorySlug,
  'garmentType': instance.garmentType,
  'sizes': instance.sizes,
};
