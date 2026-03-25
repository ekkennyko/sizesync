import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sizesync/data/models/size_entry.dart';

part 'size_chart.freezed.dart';
part 'size_chart.g.dart';

@freezed
class SizeChart with _$SizeChart {
  const factory SizeChart({
    @JsonKey(name: 'chart_id') required String chartId,
    required String name,
    @JsonKey(name: 'garment_type') required String garmentType,
    @JsonKey(name: 'applicable_categories') required List<String> applicableCategories,
    required List<String> measurements,
    required String unit,
    required List<SizeEntry> sizes,
  }) = _SizeChart;

  factory SizeChart.fromJson(Map<String, dynamic> json) => _$SizeChartFromJson(json);
}
