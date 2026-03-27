import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/datasources/purchase_service.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/category.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/data/repositories/local_brand_repository.dart';
import 'package:sizesync/data/repositories/local_size_chart_repository.dart';
import 'package:sizesync/data/repositories/local_user_repository.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';
import 'package:sizesync/shared/providers/notifiers.dart';

final assetDataSourceProvider = Provider<AssetDataSource>((_) => AssetDataSource());
final hiveDataSourceProvider = Provider<HiveDataSource>((_) => HiveDataSource());
final purchaseServiceProvider = Provider<PurchaseService>((_) => PurchaseService());

final purchaseProvider = StateNotifierProvider<PurchaseNotifier, bool>(
  (ref) => PurchaseNotifier(ref.watch(purchaseServiceProvider), ref.watch(hiveDataSourceProvider)),
);

final brandRepositoryProvider = Provider<BrandRepository>(
  (ref) => LocalBrandRepository(ref.watch(assetDataSourceProvider), isPremium: ref.watch(purchaseProvider)),
);
final sizeChartRepositoryProvider = Provider<SizeChartRepository>((ref) => LocalSizeChartRepository(ref.watch(assetDataSourceProvider)));
final userRepositoryProvider = Provider<UserRepository>((ref) => LocalUserRepository(ref.watch(hiveDataSourceProvider)));

final allBrandsProvider = FutureProvider<List<Brand>>((ref) => ref.watch(brandRepositoryProvider).getAllBrands());
final allBrandsUnfilteredProvider = FutureProvider<List<Brand>>((ref) => ref.watch(assetDataSourceProvider).loadBrands());
final categoriesProvider = FutureProvider<List<Category>>((ref) => ref.watch(assetDataSourceProvider).loadCategories());

final comparisonChartOptionsProvider = FutureProvider.autoDispose.family<List<({String id, String name})>, ({String slugA, String slugB, String gender})>((
  ref,
  p,
) async {
  final ds = ref.watch(assetDataSourceProvider);
  final chartsA = await ds.loadSizeChartsForGender(brandSlug: p.slugA, gender: p.gender);
  final chartsB = await ds.loadSizeChartsForGender(brandSlug: p.slugB, gender: p.gender);
  final idsB = chartsB.map((c) => c.chartId).toSet();
  return chartsA.where((c) => idsB.contains(c.chartId)).map((c) => (id: c.chartId, name: c.name)).toList();
});

final comparisonChartsProvider = FutureProvider.autoDispose
    .family<({SizeChart? chartA, SizeChart? chartB}), ({String slugA, String slugB, String gender, String chartId})>((ref, p) async {
      final ds = ref.watch(assetDataSourceProvider);
      final chartA = await ds.loadSizeChart(brandSlug: p.slugA, gender: p.gender, chartId: p.chartId);
      final chartB = await ds.loadSizeChart(brandSlug: p.slugB, gender: p.gender, chartId: p.chartId);
      return (chartA: chartA, chartB: chartB);
    });

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) => UserProfileNotifier(ref.watch(userRepositoryProvider)));
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) => FavoritesNotifier(ref.watch(userRepositoryProvider)));
final historyProvider = StateNotifierProvider<HistoryNotifier, List<ConversionRecord>>((ref) => HistoryNotifier(ref.watch(userRepositoryProvider)));
