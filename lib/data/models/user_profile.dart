import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default('women') String gender,
    double? bustCm,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? footLengthCm,
    double? shoulderWidthCm,
    double? heightCm,
    double? weightKg,
    @Default('regular') String preferredFit,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
