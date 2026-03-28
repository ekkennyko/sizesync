import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/models/conversion_result.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';

class LocalSizeChartRepository implements SizeChartRepository {
  LocalSizeChartRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<SizeChart?> getChartForCategory({required String brandSlug, required String gender, required String categorySlug}) async {
    final charts = await _dataSource.loadSizeChartsForGender(brandSlug: brandSlug, gender: gender);
    return charts.where((c) => c.applicableCategories.contains(categorySlug)).firstOrNull;
  }

  @override
  Future<ConversionResult?> convertSize({
    required String fromBrandSlug,
    required String toBrandSlug,
    required String gender,
    required String chartId,
    required String sizeLabel,
  }) async {
    final fromChart = await _dataSource.loadSizeChart(brandSlug: fromBrandSlug, gender: gender, chartId: chartId);
    final toChart = await _dataSource.loadSizeChart(brandSlug: toBrandSlug, gender: gender, chartId: chartId);
    if (fromChart == null || toChart == null) return null;

    final fromEntry = fromChart.sizes.where((s) => s.label == sizeLabel).firstOrNull;
    if (fromEntry == null) return null;

    SizeEntry? match;
    String matchMethod = 'eu';

    match = toChart.sizes.where((s) => s.eu.any(fromEntry.eu.contains)).firstOrNull;

    if (match == null) {
      matchMethod = 'us';
      match = toChart.sizes.where((s) => s.us.any(fromEntry.us.contains)).firstOrNull;
    }

    if (match == null) {
      matchMethod = 'uk';
      match = toChart.sizes.where((s) => s.uk.any(fromEntry.uk.contains)).firstOrNull;
    }

    if (match == null) {
      matchMethod = 'nearest';
      final sorted = [...toChart.sizes]..sort((a, b) => a.order.compareTo(b.order));
      match = sorted.reduce((a, b) => (a.order - fromEntry.order).abs() <= (b.order - fromEntry.order).abs() ? a : b);
    }

    return ConversionResult(fromSize: fromEntry, toSize: match, matchMethod: matchMethod, confidence: matchMethod == 'nearest' ? 0.5 : 1.0);
  }

  @override
  Future<SizeEntry?> recommendSize({required String brandSlug, required String gender, required String chartId, required UserProfile profile}) async {
    final chart = await _dataSource.loadSizeChart(brandSlug: brandSlug, gender: gender, chartId: chartId);
    if (chart == null) return null;

    final sorted = [...chart.sizes]..sort((a, b) => a.order.compareTo(b.order));
    final matchIndex = sorted.indexWhere((e) => _entryMatchesProfile(e, profile, gender));
    if (matchIndex == -1) return null;

    final adjustment = switch (profile.preferredFit) {
      'tight' => -1,
      'loose' => 1,
      _ => 0,
    };

    final targetIndex = (matchIndex + adjustment).clamp(0, sorted.length - 1);
    return sorted[targetIndex];
  }

  bool _entryMatchesProfile(SizeEntry entry, UserProfile profile, String gender) {
    var checksPerformed = 0;

    final primaryCm = gender == 'men' ? profile.chestCm : profile.bustCm;
    final primaryKey = gender == 'men' ? 'chest' : 'bust';
    if (primaryCm != null && entry.values[primaryKey] != null) {
      final range = entry.values[primaryKey]!;
      checksPerformed++;
      if (primaryCm < range.min || primaryCm > range.max) return false;
    }

    if (profile.waistCm != null && entry.values['waist'] != null) {
      final range = entry.values['waist']!;
      checksPerformed++;
      if (profile.waistCm! < range.min || profile.waistCm! > range.max) return false;
    }

    if (profile.hipsCm != null && entry.values['hips'] != null) {
      final range = entry.values['hips']!;
      checksPerformed++;
      if (profile.hipsCm! < range.min || profile.hipsCm! > range.max) return false;
    }

    if (profile.footLengthCm != null && entry.values['foot'] != null) {
      final range = entry.values['foot']!;
      checksPerformed++;
      if (profile.footLengthCm! < range.min || profile.footLengthCm! > range.max) return false;
    }

    return checksPerformed > 0;
  }
}
