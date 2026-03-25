import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';

class LocalSizeChartRepository implements SizeChartRepository {
  LocalSizeChartRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<List<SizeChart>> getSizeCharts(String brandSlug, String categorySlug) async {
    final charts = await _dataSource.loadSizeChart(brandSlug);
    return charts.where((c) => c.categorySlug == categorySlug).toList();
  }

  @override
  Future<SizeEntry?> convertSize({required String fromBrandSlug, required String toBrandSlug, required String categorySlug, required String sizeLabel}) async {
    final fromCharts = await _dataSource.loadSizeChart(fromBrandSlug);
    final toCharts = await _dataSource.loadSizeChart(toBrandSlug);

    final fromChart = fromCharts.where((c) => c.categorySlug == categorySlug).firstOrNull;
    final toChart = toCharts.where((c) => c.categorySlug == categorySlug).firstOrNull;
    if (fromChart == null || toChart == null) return null;

    final fromEntry = fromChart.sizes.where((s) => s.label == sizeLabel).firstOrNull;
    if (fromEntry == null) return null;

    SizeEntry? match;

    if (fromEntry.eu != null) {
      final fromEu = _primaryEuNumber(fromEntry.eu!);
      match = toChart.sizes.where((s) => s.eu != null && _primaryEuNumber(s.eu!) == fromEu).firstOrNull;
    }

    if (match == null && fromEntry.us != null) {
      match = toChart.sizes.where((s) => s.us == fromEntry.us).firstOrNull;
    }

    if (match == null && fromEntry.uk != null) {
      match = toChart.sizes.where((s) => s.uk == fromEntry.uk).firstOrNull;
    }

    return match;
  }

  @override
  Future<SizeEntry?> recommendSize({required String brandSlug, required String categorySlug, required UserProfile profile}) async {
    final charts = await _dataSource.loadSizeChart(brandSlug);
    final chart = charts.where((c) => c.categorySlug == categorySlug).firstOrNull;
    if (chart == null) return null;

    final matchIndex = chart.sizes.indexWhere((e) => _entryMatchesProfile(e, profile));
    if (matchIndex == -1) return null;

    final adjustment = switch (profile.preferredFit) {
      'tight' => -1,
      'loose' => 1,
      _ => 0,
    };

    final targetIndex = (matchIndex + adjustment).clamp(0, chart.sizes.length - 1);
    return chart.sizes[targetIndex];
  }

  String _primaryEuNumber(String eu) => eu.split('/').first.trim();

  bool _entryMatchesProfile(SizeEntry entry, UserProfile profile) {
    var checksPerformed = 0;

    if (profile.bustCm != null && entry.bustMinCm != null && entry.bustMaxCm != null) {
      checksPerformed++;
      if (profile.bustCm! < entry.bustMinCm! || profile.bustCm! > entry.bustMaxCm!) return false;
    }
    if (profile.waistCm != null && entry.waistMinCm != null && entry.waistMaxCm != null) {
      checksPerformed++;
      if (profile.waistCm! < entry.waistMinCm! || profile.waistCm! > entry.waistMaxCm!) return false;
    }
    if (profile.hipsCm != null && entry.hipsMinCm != null && entry.hipsMaxCm != null) {
      checksPerformed++;
      if (profile.hipsCm! < entry.hipsMinCm! || profile.hipsCm! > entry.hipsMaxCm!) return false;
    }
    if (profile.footLengthCm != null && entry.footLengthCm != null) {
      checksPerformed++;
      if (profile.footLengthCm! != entry.footLengthCm!) return false;
    }

    return checksPerformed > 0;
  }
}
