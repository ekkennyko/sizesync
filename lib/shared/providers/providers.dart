import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/datasources/purchase_service.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/category.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/data/repositories/local_brand_repository.dart';
import 'package:sizesync/data/repositories/local_size_chart_repository.dart';
import 'package:sizesync/data/repositories/local_user_repository.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';
import 'package:sizesync/shared/providers/notifiers.dart';

// Datasources
final assetDataSourceProvider = Provider<AssetDataSource>((_) => AssetDataSource());
final hiveDataSourceProvider = Provider<HiveDataSource>((_) => HiveDataSource());
final purchaseServiceProvider = Provider<PurchaseService>((_) => PurchaseService());

// Repositories
final brandRepositoryProvider = Provider<BrandRepository>((ref) => LocalBrandRepository(ref.watch(assetDataSourceProvider)));
final sizeChartRepositoryProvider = Provider<SizeChartRepository>((ref) => LocalSizeChartRepository(ref.watch(assetDataSourceProvider)));
final userRepositoryProvider = Provider<UserRepository>((ref) => LocalUserRepository(ref.watch(hiveDataSourceProvider)));

// Data
final allBrandsProvider = FutureProvider<List<Brand>>((ref) => ref.watch(brandRepositoryProvider).getAllBrands());
final categoriesProvider = FutureProvider<List<Category>>((ref) => ref.watch(assetDataSourceProvider).loadCategories());

// State
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) => UserProfileNotifier(ref.watch(userRepositoryProvider)));
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) => FavoritesNotifier(ref.watch(userRepositoryProvider)));
final historyProvider = StateNotifierProvider<HistoryNotifier, List<ConversionRecord>>((ref) => HistoryNotifier(ref.watch(userRepositoryProvider)));
