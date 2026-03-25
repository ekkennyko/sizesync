// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversionRecordImpl _$$ConversionRecordImplFromJson(Map<String, dynamic> json) => _$ConversionRecordImpl(
  fromBrandSlug: json['fromBrandSlug'] as String,
  toBrandSlug: json['toBrandSlug'] as String,
  categorySlug: json['categorySlug'] as String,
  fromSize: json['fromSize'] as String,
  toSize: json['toSize'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$ConversionRecordImplToJson(_$ConversionRecordImpl instance) => <String, dynamic>{
  'fromBrandSlug': instance.fromBrandSlug,
  'toBrandSlug': instance.toBrandSlug,
  'categorySlug': instance.categorySlug,
  'fromSize': instance.fromSize,
  'toSize': instance.toSize,
  'timestamp': instance.timestamp.toIso8601String(),
};
