// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) => _$UserProfileImpl(
  bustCm: (json['bustCm'] as num?)?.toDouble(),
  waistCm: (json['waistCm'] as num?)?.toDouble(),
  hipsCm: (json['hipsCm'] as num?)?.toDouble(),
  footLengthCm: (json['footLengthCm'] as num?)?.toDouble(),
  shoulderWidthCm: (json['shoulderWidthCm'] as num?)?.toDouble(),
  heightCm: (json['heightCm'] as num?)?.toDouble(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  preferredFit: json['preferredFit'] as String? ?? 'regular',
);

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) => <String, dynamic>{
  'bustCm': instance.bustCm,
  'waistCm': instance.waistCm,
  'hipsCm': instance.hipsCm,
  'footLengthCm': instance.footLengthCm,
  'shoulderWidthCm': instance.shoulderWidthCm,
  'heightCm': instance.heightCm,
  'weightKg': instance.weightKg,
  'preferredFit': instance.preferredFit,
};
