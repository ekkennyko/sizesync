import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';

class LocalSizeChartRepository implements SizeChartRepository {
  LocalSizeChartRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<Map<String, dynamic>> getSizeChart(String brandId) async {
    return _dataSource.loadJson('assets/data/size_charts/$brandId.json');
  }
}
