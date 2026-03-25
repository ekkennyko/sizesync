import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/user_profile.dart';

abstract interface class SizeChartRepository {
  Future<List<SizeChart>> getSizeCharts(String brandSlug, String categorySlug);

  Future<SizeEntry?> convertSize({required String fromBrandSlug, required String toBrandSlug, required String categorySlug, required String sizeLabel});

  Future<SizeEntry?> recommendSize({required String brandSlug, required String categorySlug, required UserProfile profile});
}
