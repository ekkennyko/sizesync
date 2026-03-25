import 'package:sizesync/data/models/brand.dart';

abstract interface class BrandRepository {
  Future<List<Brand>> getBrands();
  Future<Brand?> getBrandById(String id);
}
