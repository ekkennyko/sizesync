import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';

class LocalBrandRepository implements BrandRepository {
  LocalBrandRepository(this._dataSource);

  final AssetDataSource _dataSource;

  @override
  Future<List<Brand>> getBrands() => _dataSource.loadBrands();

  @override
  Future<Brand?> getBrandById(String id) async {
    final brands = await _dataSource.loadBrands();
    try {
      return brands.firstWhere((b) => b.id == id);
    } on StateError {
      return null;
    }
  }
}
