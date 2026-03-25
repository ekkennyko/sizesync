import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';
import 'package:sizesync/shared/providers/providers.dart';

class ConverterState {
  const ConverterState({
    this.fromBrand,
    this.toBrand,
    this.categorySlug = 'tops',
    this.selectedSizeLabel,
    this.result,
    this.recommendedSize,
    this.isLoading = false,
  });

  final Brand? fromBrand;
  final Brand? toBrand;
  final String categorySlug;
  final String? selectedSizeLabel;
  final SizeEntry? result;
  final SizeEntry? recommendedSize;
  final bool isLoading;
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier(this._sizeChartRepo, this._userRepo) : super(const ConverterState());

  final SizeChartRepository _sizeChartRepo;
  final UserRepository _userRepo;

  void setFromBrand(Brand brand) {
    state = ConverterState(fromBrand: brand, toBrand: state.toBrand, categorySlug: state.categorySlug);
  }

  void setToBrand(Brand brand) {
    state = ConverterState(fromBrand: state.fromBrand, toBrand: brand, categorySlug: state.categorySlug);
  }

  void swapBrands() {
    state = ConverterState(fromBrand: state.toBrand, toBrand: state.fromBrand, categorySlug: state.categorySlug);
  }

  void setCategory(String slug) {
    state = ConverterState(fromBrand: state.fromBrand, toBrand: state.toBrand, categorySlug: slug);
  }

  Future<void> selectSize(String sizeLabel) async {
    final fromBrand = state.fromBrand;
    final toBrand = state.toBrand;
    final categorySlug = state.categorySlug;
    if (fromBrand == null || toBrand == null) return;

    state = ConverterState(fromBrand: fromBrand, toBrand: toBrand, categorySlug: categorySlug, selectedSizeLabel: sizeLabel, isLoading: true);

    final result = await _sizeChartRepo.convertSize(fromBrandSlug: fromBrand.slug, toBrandSlug: toBrand.slug, categorySlug: categorySlug, sizeLabel: sizeLabel);

    SizeEntry? recommended;
    final profile = await _userRepo.getProfile();
    if (profile != null) {
      recommended = await _sizeChartRepo.recommendSize(brandSlug: toBrand.slug, categorySlug: categorySlug, profile: profile);
    }

    if (result != null) {
      await _userRepo.addToHistory(
        ConversionRecord(
          fromBrandSlug: fromBrand.slug,
          toBrandSlug: toBrand.slug,
          categorySlug: categorySlug,
          fromSize: sizeLabel,
          toSize: result.label,
          timestamp: DateTime.now(),
        ),
      );
    }

    state = ConverterState(
      fromBrand: fromBrand,
      toBrand: toBrand,
      categorySlug: categorySlug,
      selectedSizeLabel: sizeLabel,
      result: result,
      recommendedSize: recommended,
    );
  }
}

final converterProvider = StateNotifierProvider<ConverterNotifier, ConverterState>(
  (ref) => ConverterNotifier(ref.watch(sizeChartRepositoryProvider), ref.watch(userRepositoryProvider)),
);

final fromSizeEntriesProvider = FutureProvider.autoDispose.family<List<SizeEntry>, ({String brandSlug, String categorySlug})>((ref, params) async {
  final charts = await ref.watch(sizeChartRepositoryProvider).getSizeCharts(params.brandSlug, params.categorySlug);
  return charts.expand((c) => c.sizes).toList();
});
