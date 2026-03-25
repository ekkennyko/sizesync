import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversion_record.freezed.dart';
part 'conversion_record.g.dart';

@freezed
class ConversionRecord with _$ConversionRecord {
  const factory ConversionRecord({
    required String fromBrandSlug,
    required String toBrandSlug,
    required String categorySlug,
    required String fromSize,
    required String toSize,
    required DateTime timestamp,
  }) = _ConversionRecord;

  factory ConversionRecord.fromJson(Map<String, dynamic> json) => _$ConversionRecordFromJson(json);
}
