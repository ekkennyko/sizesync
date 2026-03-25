import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';

class LocalBrandRepository implements BrandRepository {
  LocalBrandRepository(this._dataSource, {required bool isPremium}) : _isPremium = isPremium;

  final AssetDataSource _dataSource;
  final bool _isPremium;

  @override
  Future<List<Brand>> getAllBrands() async {
    final brands = await _dataSource.loadBrands();
    if (_isPremium) return brands;
    return brands.where((b) => !b.isPremium).toList();
  }

  @override
  Future<List<Brand>> getFreeBrands() async {
    final brands = await _dataSource.loadBrands();
    return brands.where((b) => !b.isPremium).toList();
  }

  @override
  Future<List<Brand>> searchBrands(String query) async {
    final brands = await _dataSource.loadBrands();
    final lower = query.toLowerCase();
    return brands.where((b) => b.name.toLowerCase().contains(lower)).toList();
  }

  @override
  Future<Brand?> getBrandBySlug(String slug) async {
    final brands = await _dataSource.loadBrands();
    return brands.where((b) => b.slug == slug).firstOrNull;
  }
}
