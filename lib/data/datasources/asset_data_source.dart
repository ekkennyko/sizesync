import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/brand_file.dart';
import 'package:sizesync/data/models/category.dart';
import 'package:sizesync/data/models/size_chart.dart';

class AssetDataSource {
  List<Brand>? _brandsCache;
  List<Category>? _categoriesCache;
  final Map<String, BrandFile> _brandFileCache = {};

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

  Future<BrandFile?> loadBrandFile(String brandSlug) async {
    if (_brandFileCache.containsKey(brandSlug)) return _brandFileCache[brandSlug];
    try {
      final raw = await rootBundle.loadString('assets/data/size_charts/$brandSlug.json');
      final brandFile = BrandFile.fromJson(json.decode(raw) as Map<String, dynamic>);
      _brandFileCache[brandSlug] = brandFile;
      return brandFile;
    } catch (_) {
      return null;
    }
  }

  Future<SizeChart?> loadSizeChart({required String brandSlug, required String gender, required String chartId}) async {
    final brandFile = await loadBrandFile(brandSlug);
    if (brandFile == null) return null;
    final genderData = gender == 'women' ? brandFile.women : brandFile.men;
    if (genderData == null) return null;
    return genderData.sizeCharts.where((c) => c.chartId == chartId).firstOrNull;
  }

  Future<List<SizeChart>> loadSizeChartsForGender({required String brandSlug, required String gender}) async {
    final brandFile = await loadBrandFile(brandSlug);
    if (brandFile == null) return [];
    final genderData = gender == 'women' ? brandFile.women : brandFile.men;
    return genderData?.sizeCharts ?? [];
  }
}
