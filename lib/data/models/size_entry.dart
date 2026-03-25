import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sizesync/data/models/measurement_range.dart';

part 'size_entry.freezed.dart';
part 'size_entry.g.dart';

@freezed
class SizeEntry with _$SizeEntry {
  const factory SizeEntry({
    required String label,
    required int order,
    @Default(<String>[]) List<String> eu,
    @Default(<String>[]) List<String> us,
    @Default(<String>[]) List<String> uk,
    @Default(<String, MeasurementRange>{}) Map<String, MeasurementRange> values,
  }) = _SizeEntry;

  factory SizeEntry.fromJson(Map<String, dynamic> json) => _$SizeEntryFromJson(json);
}
