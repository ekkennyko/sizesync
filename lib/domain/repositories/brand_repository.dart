abstract interface class BrandRepository {
  Future<List<Map<String, dynamic>>> getBrands();
  Future<Map<String, dynamic>?> getBrandById(String id);
}
