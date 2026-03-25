import 'package:sizesync/data/models/conversion_result.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/data/models/user_profile.dart';

abstract interface class SizeChartRepository {
  Future<SizeChart?> getChartForCategory({required String brandSlug, required String gender, required String categorySlug});

  Future<ConversionResult?> convertSize({
    required String fromBrandSlug,
    required String toBrandSlug,
    required String gender,
    required String chartId,
    required String sizeLabel,
  });

  Future<SizeEntry?> recommendSize({required String brandSlug, required String gender, required String chartId, required UserProfile profile});
}
