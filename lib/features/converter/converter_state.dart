import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/domain/repositories/brand_repository.dart';
import 'package:sizesync/domain/repositories/size_chart_repository.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';
import 'package:sizesync/shared/providers/providers.dart';

class ConverterState {
  const ConverterState({
    this.fromBrand,
    this.toBrand,
    this.gender = 'women',
    this.categorySlug = 'tops',
    this.selectedSizeLabel,
    this.result,
    this.recommendedSize,
    this.isLoading = false,
  });

  final Brand? fromBrand;
  final Brand? toBrand;
  final String gender;
  final String categorySlug;
  final String? selectedSizeLabel;
  final SizeEntry? result;
  final SizeEntry? recommendedSize;
  final bool isLoading;
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier(this._sizeChartRepo, this._userRepo, this._brandRepo) : super(const ConverterState());

  final SizeChartRepository _sizeChartRepo;
  final UserRepository _userRepo;
  final BrandRepository _brandRepo;

  void setFromBrand(Brand brand) {
    state = ConverterState(fromBrand: brand, toBrand: state.toBrand, gender: state.gender, categorySlug: state.categorySlug);
  }

  void setToBrand(Brand brand) {
    state = ConverterState(fromBrand: state.fromBrand, toBrand: brand, gender: state.gender, categorySlug: state.categorySlug);
  }

  void swapBrands() {
    state = ConverterState(fromBrand: state.toBrand, toBrand: state.fromBrand, gender: state.gender, categorySlug: state.categorySlug);
  }

  void setGender(String gender) {
    state = ConverterState(fromBrand: state.fromBrand, toBrand: state.toBrand, gender: gender, categorySlug: state.categorySlug);
  }

  void setCategory(String slug) {
    state = ConverterState(fromBrand: state.fromBrand, toBrand: state.toBrand, gender: state.gender, categorySlug: slug);
  }

  Future<void> selectSize(String sizeLabel) async {
    final fromBrand = state.fromBrand;
    final toBrand = state.toBrand;
    final gender = state.gender;
    final categorySlug = state.categorySlug;
    if (fromBrand == null || toBrand == null) return;

    state = ConverterState(
      fromBrand: fromBrand,
      toBrand: toBrand,
      gender: gender,
      categorySlug: categorySlug,
      selectedSizeLabel: sizeLabel,
      isLoading: true,
      result: state.result,
      recommendedSize: state.recommendedSize,
    );

    final conversionResult = await _sizeChartRepo.convertSize(
      fromBrandSlug: fromBrand.slug,
      toBrandSlug: toBrand.slug,
      gender: gender,
      chartId: categorySlug,
      sizeLabel: sizeLabel,
    );

    SizeEntry? recommended;
    final profile = await _userRepo.getProfile();
    if (profile != null) {
      recommended = await _sizeChartRepo.recommendSize(brandSlug: toBrand.slug, gender: gender, chartId: categorySlug, profile: profile);
    }

    if (conversionResult != null) {
      await _userRepo.addToHistory(
        ConversionRecord(
          fromBrandSlug: fromBrand.slug,
          toBrandSlug: toBrand.slug,
          gender: gender,
          chartId: categorySlug,
          fromSizeLabel: sizeLabel,
          toSizeLabel: conversionResult.toSize.label,
          timestamp: DateTime.now(),
        ),
      );
    }

    state = ConverterState(
      fromBrand: fromBrand,
      toBrand: toBrand,
      gender: gender,
      categorySlug: categorySlug,
      selectedSizeLabel: sizeLabel,
      result: conversionResult?.toSize,
      recommendedSize: recommended,
    );
  }

  Future<void> restoreFromHistory(ConversionRecord record) async {
    final fromBrand = await _brandRepo.getBrandBySlug(record.fromBrandSlug);
    final toBrand = await _brandRepo.getBrandBySlug(record.toBrandSlug);
    if (fromBrand == null || toBrand == null) return;
    state = ConverterState(fromBrand: fromBrand, toBrand: toBrand, gender: record.gender, categorySlug: record.chartId);
    await selectSize(record.fromSizeLabel);
  }
}

final converterProvider = StateNotifierProvider<ConverterNotifier, ConverterState>(
  (ref) => ConverterNotifier(ref.watch(sizeChartRepositoryProvider), ref.watch(userRepositoryProvider), ref.watch(brandRepositoryProvider)),
);

final fromSizeEntriesProvider = FutureProvider.autoDispose.family<List<SizeEntry>, ({String brandSlug, String gender, String categorySlug})>((
  ref,
  params,
) async {
  final chart = await ref
      .watch(sizeChartRepositoryProvider)
      .getChartForCategory(brandSlug: params.brandSlug, gender: params.gender, categorySlug: params.categorySlug);
  if (chart == null) return [];
  return [...chart.sizes]..sort((a, b) => a.order.compareTo(b.order));
});
