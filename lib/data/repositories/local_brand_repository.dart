import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';

class LocalBrandRepository implements BrandRepository {
  LocalBrandRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<List<Map<String, dynamic>>> getBrands() async {
    final list = await _dataSource.loadJsonList('assets/data/brands.json');
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getBrandById(String id) async {
    final brands = await getBrands();
    try {
      return brands.firstWhere((b) => b['id'] == id);
    } on StateError {
      return null;
    }
  }
}
