import 'package:flutter_test/flutter_test.dart';
import 'package:sizesync/data/models/measurement_range.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/data/repositories/local_size_chart_repository.dart';

import '../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Fixture size entries
// ---------------------------------------------------------------------------
const _xs = SizeEntry(
  label: 'XS',
  order: 0,
  eu: ['32', '34'],
  us: ['0', '2'],
  uk: ['4', '6'],
  values: {'bust': MeasurementRange(min: 80, max: 88), 'waist': MeasurementRange(min: 60, max: 68)},
);

const _s = SizeEntry(
  label: 'S',
  order: 1,
  eu: ['36'],
  us: ['4'],
  uk: ['8'],
  values: {'bust': MeasurementRange(min: 88, max: 92), 'waist': MeasurementRange(min: 68, max: 72)},
);

const _m = SizeEntry(
  label: 'M',
  order: 2,
  eu: ['38', '40'],
  us: ['8', '10'],
  uk: ['12', '14'],
  values: {'bust': MeasurementRange(min: 92, max: 100), 'waist': MeasurementRange(min: 72, max: 80)},
);

const _l = SizeEntry(
  label: 'L',
  order: 3,
  eu: ['42'],
  us: ['12'],
  uk: ['16'],
  values: {'bust': MeasurementRange(min: 100, max: 108), 'waist': MeasurementRange(min: 80, max: 88)},
);

SizeChart _makeChart(String chartId, List<SizeEntry> sizes) =>
    SizeChart(chartId: chartId, name: chartId, garmentType: 'top', applicableCategories: [chartId], measurements: ['bust', 'waist'], unit: 'cm', sizes: sizes);

LocalSizeChartRepository _repoWith({SizeChart? zaraChart, SizeChart? hmChart, String gender = 'women', String chartId = 'tops'}) {
  final charts = <String, SizeChart?>{};
  if (zaraChart != null) charts['zara/$gender/$chartId'] = zaraChart;
  if (hmChart != null) charts['hm/$gender/$chartId'] = hmChart;
  return LocalSizeChartRepository(FakeAssetDataSource(charts: charts));
}

void main() {
  final zaraChart = _makeChart('tops', [_xs, _s, _m, _l]);
  final hmChart = _makeChart('tops', [_xs, _s, _m, _l]);

  // -------------------------------------------------------------------------
  group('convertSize', () {
    test('Zara M → H&M M via EU mapping', () async {
      final repo = _repoWith(zaraChart: zaraChart, hmChart: hmChart);
      final result = await repo.convertSize(fromBrandSlug: 'zara', toBrandSlug: 'hm', gender: 'women', chartId: 'tops', sizeLabel: 'M');
      expect(result, isNotNull);
      expect(result!.toSize.label, 'M');
      expect(result.matchMethod, 'eu');
      expect(result.confidence, 1.0);
    });

    test('EU array intersection — XS with eu [32,34] matches H&M XS', () async {
      final zaraXsOnly = _makeChart('tops', [_xs]);
      final hmXsOnly = _makeChart('tops', [_xs]);
      final repo = _repoWith(zaraChart: zaraXsOnly, hmChart: hmXsOnly);
      final result = await repo.convertSize(fromBrandSlug: 'zara', toBrandSlug: 'hm', gender: 'women', chartId: 'tops', sizeLabel: 'XS');
      expect(result, isNotNull);
      expect(result!.toSize.label, 'XS');
      expect(result.matchMethod, 'eu');
    });

    test('EU no intersection — fallback to US match', () async {
      // brandA has a size with unique EU but US='4'
      const fromEntry = SizeEntry(label: 'ODD', order: 1, eu: ['99'], us: ['4'], uk: []);
      // brandB has S with EU='36' (different) but US='4' (same)
      final chA = _makeChart('tops', [fromEntry]);
      final chB = _makeChart('tops', [_s]); // _s has eu=['36'], us=['4']
      final ds = FakeAssetDataSource(charts: {'brandA/women/tops': chA, 'brandB/women/tops': chB});
      final repo = LocalSizeChartRepository(ds);
      final result = await repo.convertSize(fromBrandSlug: 'brandA', toBrandSlug: 'brandB', gender: 'women', chartId: 'tops', sizeLabel: 'ODD');
      expect(result, isNotNull);
      expect(result!.matchMethod, 'us');
      expect(result.toSize.us, contains('4'));
    });

    test('nonexistent size label returns null', () async {
      final repo = _repoWith(zaraChart: zaraChart, hmChart: hmChart);
      final result = await repo.convertSize(fromBrandSlug: 'zara', toBrandSlug: 'hm', gender: 'women', chartId: 'tops', sizeLabel: 'XXXXXXL');
      expect(result, isNull);
    });

    test('chart does not exist for toBrand returns null', () async {
      final repo = _repoWith(zaraChart: zaraChart, hmChart: null);
      final result = await repo.convertSize(fromBrandSlug: 'zara', toBrandSlug: 'hm', gender: 'women', chartId: 'tops', sizeLabel: 'M');
      expect(result, isNull);
    });

    test('tops chart only — missing bottoms chart returns null', () async {
      // zaraChart has chartId 'tops'. Querying 'bottoms' → loadSizeChart returns null.
      final repo = _repoWith(zaraChart: zaraChart, hmChart: hmChart);
      final result = await repo.convertSize(fromBrandSlug: 'zara', toBrandSlug: 'hm', gender: 'women', chartId: 'bottoms', sizeLabel: 'M');
      expect(result, isNull);
    });

    test('matchMethod is "nearest" and confidence 0.5 when no size system matches', () async {
      const uniqueSize = SizeEntry(label: 'UNIQUE', order: 10, eu: ['999'], us: ['999'], uk: ['999']);
      final chA = _makeChart('tops', [uniqueSize]);
      // brandB has only XS-L with completely different system values
      final chB = _makeChart('tops', [_xs, _s, _m, _l]);
      final ds = FakeAssetDataSource(charts: {'brandA/women/tops': chA, 'brandB/women/tops': chB});
      final repo = LocalSizeChartRepository(ds);
      final result = await repo.convertSize(fromBrandSlug: 'brandA', toBrandSlug: 'brandB', gender: 'women', chartId: 'tops', sizeLabel: 'UNIQUE');
      expect(result, isNotNull);
      expect(result!.matchMethod, 'nearest');
      expect(result.confidence, 0.5);
    });
  });

  // -------------------------------------------------------------------------
  group('recommendSize', () {
    test('measurements in range return correct size', () async {
      final repo = _repoWith(zaraChart: zaraChart);
      // bustCm=96 is in M range [92, 100], waistCm=76 is in M range [72, 80]
      final profile = UserProfile(bustCm: 96, waistCm: 76);
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNotNull);
      expect(result!.label, 'M');
    });

    test('preferredFit tight returns size one order smaller', () async {
      final repo = _repoWith(zaraChart: zaraChart);
      // bustCm=96 matches M (index 2), adjustment=-1 → S (index 1)
      final profile = UserProfile(bustCm: 96, preferredFit: 'tight');
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNotNull);
      expect(result!.label, 'S');
    });

    test('preferredFit loose returns size one order larger', () async {
      final repo = _repoWith(zaraChart: zaraChart);
      // bustCm=96 matches M (index 2), adjustment=+1 → L (index 3)
      final profile = UserProfile(bustCm: 96, preferredFit: 'loose');
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNotNull);
      expect(result!.label, 'L');
    });

    test('adjustment is clamped at chart boundaries', () async {
      final repo = _repoWith(zaraChart: zaraChart);
      // bustCm=84 matches XS (index 0), adjustment=-1 → clamp → XS (index 0)
      final profile = UserProfile(bustCm: 84, preferredFit: 'tight');
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNotNull);
      expect(result!.label, 'XS');
    });

    test('profile with no measurements returns null', () async {
      final repo = _repoWith(zaraChart: zaraChart);
      // No bust, waist, hips or foot → checksPerformed=0 → no match
      const profile = UserProfile();
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNull);
    });

    test('women profile with men chart — chest field ignored, returns null', () async {
      // Men chart uses 'chest' key. Profile has bustCm but not chestCm.
      // gender='men' → primaryKey='chest', primaryCm=profile.chestCm=null → skip
      // No other measurements → checksPerformed=0 → null
      const menEntry = SizeEntry(label: 'M', order: 2, values: {'chest': MeasurementRange(min: 92, max: 100)});
      final menChart = _makeChart('tops', [menEntry]);
      final ds = FakeAssetDataSource(charts: {'zara/men/tops': menChart});
      final repo = LocalSizeChartRepository(ds);
      final profile = UserProfile(bustCm: 96);
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'men', chartId: 'tops', profile: profile);
      expect(result, isNull);
    });

    test('waist-only match when bust is null', () async {
      // Profile has only waistCm set; entry has waist values
      // bustCm=null → skip bust check; waistCm=76 in M.waist [72,80] → match
      final repo = _repoWith(zaraChart: zaraChart);
      final profile = UserProfile(waistCm: 76);
      final result = await repo.recommendSize(brandSlug: 'zara', gender: 'women', chartId: 'tops', profile: profile);
      expect(result, isNotNull);
      expect(result!.label, 'M');
    });
  });
}
