import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sizesync/data/models/gender_data.dart';

part 'brand_file.freezed.dart';
part 'brand_file.g.dart';

@freezed
class BrandFile with _$BrandFile {
  const factory BrandFile({
    @JsonKey(name: 'brand_slug') required String brandSlug,
    @JsonKey(name: 'brand_name') required String brandName,
    @JsonKey(name: 'last_updated') required String lastUpdated,
    required String source,
    GenderData? women,
    GenderData? men,
  }) = _BrandFile;

  factory BrandFile.fromJson(Map<String, dynamic> json) => _$BrandFileFromJson(json);
}
