import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';

class LocalSizeChartRepository implements SizeChartRepository {
  LocalSizeChartRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<List<SizeChart>> getSizeChart(String brandSlug) => _dataSource.loadSizeChart(brandSlug);
}
