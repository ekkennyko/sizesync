import 'package:freezed_annotation/freezed_annotation.dart';

part 'size_chart.freezed.dart';
part 'size_chart.g.dart';

@freezed
class SizeEntry with _$SizeEntry {
  const factory SizeEntry({
    required String label,
    String? us,
    String? uk,
    String? eu,
    String? asia,
    double? bustMinCm,
    double? bustMaxCm,
    double? waistMinCm,
    double? waistMaxCm,
    double? hipsMinCm,
    double? hipsMaxCm,
    double? footLengthCm,
    double? shoulderWidthCm,
  }) = _SizeEntry;

  factory SizeEntry.fromJson(Map<String, dynamic> json) => _$SizeEntryFromJson(json);
}

@freezed
class SizeChart with _$SizeChart {
  const factory SizeChart({required String brandSlug, required String categorySlug, required String garmentType, required List<SizeEntry> sizes}) = _SizeChart;

  factory SizeChart.fromJson(Map<String, dynamic> json) => _$SizeChartFromJson(json);
}
