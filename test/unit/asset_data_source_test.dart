import 'package:flutter_test/flutter_test.dart';
import 'package:sizesync/data/datasources/asset_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetDataSource ds;

  setUp(() {
    ds = AssetDataSource();
  });

  group('loadBrands', () {
    test('returns non-empty list', () async {
      final brands = await ds.loadBrands();
      expect(brands, isNotEmpty);
    });

    test('each brand has non-empty slug, name, country', () async {
      final brands = await ds.loadBrands();
      for (final b in brands) {
        expect(b.slug, isNotEmpty);
        expect(b.name, isNotEmpty);
        expect(b.country, isNotEmpty);
      }
    });
  });

  group('loadBrandFile', () {
    test('zara parses into BrandFile with women data', () async {
      final file = await ds.loadBrandFile('zara');
      expect(file, isNotNull);
      expect(file!.brandSlug, 'zara');
      expect(file.women, isNotNull);
      expect(file.women!.sizeCharts, isNotEmpty);
    });

    test('nonexistent slug returns null without throwing', () async {
      final file = await ds.loadBrandFile('brand_that_does_not_exist_xyz');
      expect(file, isNull);
    });

    test('second call returns cached result without re-reading JSON', () async {
      final first = await ds.loadBrandFile('zara');
      final second = await ds.loadBrandFile('zara');
      expect(identical(first, second), isTrue);
    });
  });

  group('loadSizeChart', () {
    test('zara women tops returns chart with sizes', () async {
      final chart = await ds.loadSizeChart(brandSlug: 'zara', gender: 'women', chartId: 'tops');
      expect(chart, isNotNull);
      expect(chart!.chartId, 'tops');
      expect(chart.sizes, isNotEmpty);
    });

    test('applicable_categories and measurements are lists', () async {
      final chart = await ds.loadSizeChart(brandSlug: 'zara', gender: 'women', chartId: 'tops');
      expect(chart!.applicableCategories, isA<List<String>>());
      expect(chart.measurements, isA<List<String>>());
    });

    test('nonexistent chartId returns null', () async {
      final chart = await ds.loadSizeChart(brandSlug: 'zara', gender: 'women', chartId: 'chart_that_does_not_exist');
      expect(chart, isNull);
    });
  });
}
