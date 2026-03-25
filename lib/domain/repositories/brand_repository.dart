import 'package:sizesync/data/models/brand.dart';

abstract interface class BrandRepository {
  Future<List<Brand>> getAllBrands();
  Future<List<Brand>> getFreeBrands();
  Future<List<Brand>> searchBrands(String query);
  Future<Brand?> getBrandBySlug(String slug);
}
