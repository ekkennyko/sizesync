import 'package:freezed_annotation/freezed_annotation.dart';

part 'measurement_range.freezed.dart';
part 'measurement_range.g.dart';

@freezed
class MeasurementRange with _$MeasurementRange {
  const factory MeasurementRange({required double min, required double max}) = _MeasurementRange;

  factory MeasurementRange.fromJson(Map<String, dynamic> json) => _$MeasurementRangeFromJson(json);
}
