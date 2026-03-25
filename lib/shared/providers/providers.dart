import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/datasources/asset_data_source.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/datasources/purchase_service.dart';
import 'package:sizesync/data/repositories/local_brand_repository.dart';
import 'package:sizesync/data/repositories/local_size_chart_repository.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';

final assetDataSourceProvider = Provider<AssetDataSource>((_) => AssetDataSource());

final hiveDataSourceProvider = Provider<HiveDataSource>((_) => HiveDataSource());

final purchaseServiceProvider = Provider<PurchaseService>((_) => PurchaseService());

final brandRepositoryProvider = Provider<BrandRepository>((ref) => LocalBrandRepository(ref.watch(assetDataSourceProvider)));

final sizeChartRepositoryProvider = Provider<SizeChartRepository>((ref) => LocalSizeChartRepository(ref.watch(assetDataSourceProvider)));
