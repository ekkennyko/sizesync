import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/category.dart';
import 'package:sizesync/data/models/size_chart.dart';

class AssetDataSource {
  List<Brand>? _brandsCache;
  List<Category>? _categoriesCache;
  final Map<String, List<SizeChart>> _sizeChartCache = {};

  Future<List<Brand>> loadBrands() async {
    if (_brandsCache != null) return _brandsCache!;
    final raw = await rootBundle.loadString('assets/data/brands.json');
    final list = json.decode(raw) as List<dynamic>;
    _brandsCache = list.map((e) => Brand.fromJson(e as Map<String, dynamic>)).toList();
    return _brandsCache!;
  }

  Future<List<Category>> loadCategories() async {
    if (_categoriesCache != null) return _categoriesCache!;
    final raw = await rootBundle.loadString('assets/data/categories.json');
    final list = json.decode(raw) as List<dynamic>;
    _categoriesCache = list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    return _categoriesCache!;
  }

  Future<List<SizeChart>> loadSizeChart(String brandSlug) async {
    if (_sizeChartCache.containsKey(brandSlug)) return _sizeChartCache[brandSlug]!;
    final raw = await rootBundle.loadString('assets/data/size_charts/$brandSlug.json');
    final list = json.decode(raw) as List<dynamic>;
    final charts = list.map((e) => SizeChart.fromJson(e as Map<String, dynamic>)).toList();
    _sizeChartCache[brandSlug] = charts;
    return charts;
  }
}
