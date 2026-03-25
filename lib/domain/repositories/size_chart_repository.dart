import 'package:sizesync/data/models/size_chart.dart';

abstract interface class SizeChartRepository {
  Future<List<SizeChart>> getSizeChart(String brandSlug);
}
