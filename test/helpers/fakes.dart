import 'package:flutter/material.dart';
import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/category.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/conversion_result.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';

// ---------------------------------------------------------------------------
// FakeAssetDataSource
//
// Returns charts by the key '$brandSlug/$gender/$chartId'.
// ---------------------------------------------------------------------------
class FakeAssetDataSource extends AssetDataSource {
  FakeAssetDataSource({Map<String, SizeChart?> charts = const {}, List<Brand> brands = const [], List<Category> categories = const []})
    : _charts = charts,
      _brands = brands,
      _categories = categories;

  final Map<String, SizeChart?> _charts;
  final List<Brand> _brands;
  final List<Category> _categories;

  int loadBrandFileCallCount = 0;

  @override
  Future<List<Brand>> loadBrands() async => _brands;

  @override
  Future<List<Category>> loadCategories() async => _categories;

  @override
  Future<SizeChart?> loadSizeChart({required String brandSlug, required String gender, required String chartId}) async =>
      _charts['$brandSlug/$gender/$chartId'];

  @override
  Future<List<SizeChart>> loadSizeChartsForGender({required String brandSlug, required String gender}) async {
    final prefix = '$brandSlug/$gender/';
    return _charts.entries.where((e) => e.key.startsWith(prefix) && e.value != null).map((e) => e.value!).toList();
  }
}

// ---------------------------------------------------------------------------
// FakeHiveDataSource
//
// In-memory replacement for HiveDataSource — no Hive initialisation needed.
// ---------------------------------------------------------------------------
class FakeHiveDataSource extends HiveDataSource {
  Map<String, dynamic>? _profile;
  List<String> _favorites = [];
  List<Map<String, dynamic>> _history = [];
  bool _isPremium = false;
  ThemeMode _theme = ThemeMode.system;
  String _sizeSystem = 'EU';
  bool _useInches = false;
  List<String> _recentSearches = [];

  @override
  Map<String, dynamic>? readProfile() => _profile != null ? Map.from(_profile!) : null;

  @override
  Future<void> writeProfile(Map<String, dynamic> data) async => _profile = Map.from(data);

  @override
  List<String> readFavorites() => List.from(_favorites);

  @override
  Future<void> writeFavorites(List<String> slugs) async => _favorites = List.from(slugs);

  @override
  List<Map<String, dynamic>> readHistory() => _history.map((e) => Map<String, dynamic>.from(e)).toList();

  @override
  Future<void> writeHistory(List<Map<String, dynamic>> records) async => _history = records.map((e) => Map<String, dynamic>.from(e)).toList();

  @override
  bool readIsPremium() => _isPremium;

  @override
  Future<void> writeIsPremium({required bool value}) async => _isPremium = value;

  @override
  ThemeMode readThemeMode() => _theme;

  @override
  Future<void> writeThemeMode(ThemeMode mode) async => _theme = mode;

  @override
  String readSizeSystem() => _sizeSystem;

  @override
  Future<void> writeSizeSystem(String system) async => _sizeSystem = system;

  @override
  bool readUseInches() => _useInches;

  @override
  Future<void> writeUseInches({required bool value}) async => _useInches = value;

  @override
  List<String> readRecentSearches() => List.from(_recentSearches);

  @override
  Future<void> writeRecentSearches(List<String> slugs) async => _recentSearches = List.from(slugs);

  @override
  bool readOnboardingComplete() => true;

  @override
  Future<void> writeOnboardingComplete() async {}
}

// ---------------------------------------------------------------------------
// FakeUserRepository
// ---------------------------------------------------------------------------
class FakeUserRepository implements UserRepository {
  UserProfile? _profile;
  final List<String> _favorites = [];
  final List<ConversionRecord> _history = [];

  @override
  Future<UserProfile?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async => _profile = profile;

  @override
  Future<List<String>> getFavoriteBrandSlugs() async => List.from(_favorites);

  @override
  Future<void> toggleFavorite(String brandSlug) async {
    if (_favorites.contains(brandSlug)) {
      _favorites.remove(brandSlug);
    } else {
      _favorites.add(brandSlug);
    }
  }

  @override
  Future<List<ConversionRecord>> getHistory() async => List.from(_history);

  @override
  Future<void> addToHistory(ConversionRecord record) async => _history.insert(0, record);

  @override
  Future<void> clearHistory() async => _history.clear();
}

// ---------------------------------------------------------------------------
// FakeSizeChartRepository
// ---------------------------------------------------------------------------
class FakeSizeChartRepository implements SizeChartRepository {
  FakeSizeChartRepository({SizeChart? chart, ConversionResult? convertResult, SizeEntry? recommendResult})
    : _chart = chart,
      _convertResult = convertResult,
      _recommendResult = recommendResult;

  final SizeChart? _chart;
  final ConversionResult? _convertResult;
  final SizeEntry? _recommendResult;

  @override
  Future<SizeChart?> getChartForCategory({required String brandSlug, required String gender, required String categorySlug}) async => _chart;

  @override
  Future<ConversionResult?> convertSize({
    required String fromBrandSlug,
    required String toBrandSlug,
    required String gender,
    required String chartId,
    required String sizeLabel,
  }) async => _convertResult;

  @override
  Future<SizeEntry?> recommendSize({required String brandSlug, required String gender, required String chartId, required UserProfile profile}) async =>
      _recommendResult;
}

// ---------------------------------------------------------------------------
// FakeBrandRepository
// ---------------------------------------------------------------------------
class FakeBrandRepository implements BrandRepository {
  FakeBrandRepository({List<Brand> brands = const []}) : _brands = brands;

  final List<Brand> _brands;

  @override
  Future<List<Brand>> getAllBrands() async => _brands;

  @override
  Future<List<Brand>> getFreeBrands() async => _brands.where((b) => !b.isPremium).toList();

  @override
  Future<List<Brand>> searchBrands(String query) async => _brands.where((b) => b.name.toLowerCase().contains(query.toLowerCase())).toList();

  @override
  Future<Brand?> getBrandBySlug(String slug) async => _brands.where((b) => b.slug == slug).firstOrNull;
}

// ---------------------------------------------------------------------------
// Common fixture data
// ---------------------------------------------------------------------------

final fixtureBrandZara = Brand(
  name: 'Zara',
  slug: 'zara',
  country: 'Spain',
  logoAsset: 'assets/logos/zara.svg',
  isPremium: false,
  genders: const ['women', 'men'],
  website: null,
);

final fixtureBrandHm = Brand(
  name: 'H&M',
  slug: 'hm',
  country: 'Sweden',
  logoAsset: 'assets/logos/hm.svg',
  isPremium: false,
  genders: const ['women', 'men'],
  website: null,
);
