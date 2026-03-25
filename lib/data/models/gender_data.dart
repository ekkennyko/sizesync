import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sizesync/data/models/size_chart.dart';

part 'gender_data.freezed.dart';
part 'gender_data.g.dart';

@freezed
class GenderData with _$GenderData {
  const factory GenderData({@JsonKey(name: 'size_charts') required List<SizeChart> sizeCharts}) = _GenderData;

  factory GenderData.fromJson(Map<String, dynamic> json) => _$GenderDataFromJson(json);
}
