import 'package:flutter_test/flutter_test.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/data/repositories/local_user_repository.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeHiveDataSource hive;
  late LocalUserRepository repo;

  setUp(() {
    hive = FakeHiveDataSource();
    repo = LocalUserRepository(hive);
  });

  // -------------------------------------------------------------------------
  group('saveProfile / getProfile', () {
    test('round-trip preserves all fields', () async {
      const profile = UserProfile(gender: 'women', bustCm: 90.0, chestCm: 85.0, waistCm: 70.0, hipsCm: 95.0, footLengthCm: 25.0, preferredFit: 'loose');
      await repo.saveProfile(profile);
      final loaded = await repo.getProfile();
      expect(loaded, isNotNull);
      expect(loaded!.bustCm, 90.0);
      expect(loaded.waistCm, 70.0);
      expect(loaded.hipsCm, 95.0);
      expect(loaded.footLengthCm, 25.0);
      expect(loaded.preferredFit, 'loose');
    });

    test('getProfile returns null before any profile is saved', () async {
      final result = await repo.getProfile();
      expect(result, isNull);
    });

    test('gender field is persisted correctly', () async {
      const profile = UserProfile(gender: 'men', chestCm: 96.0);
      await repo.saveProfile(profile);
      final loaded = await repo.getProfile();
      expect(loaded!.gender, 'men');
      expect(loaded.chestCm, 96.0);
    });
  });

  // -------------------------------------------------------------------------
  group('toggleFavorite', () {
    test('add brand → getFavoriteBrandSlugs contains it', () async {
      await repo.toggleFavorite('zara');
      final favs = await repo.getFavoriteBrandSlugs();
      expect(favs, contains('zara'));
    });

    test('toggle twice → brand is removed', () async {
      await repo.toggleFavorite('zara');
      await repo.toggleFavorite('zara');
      final favs = await repo.getFavoriteBrandSlugs();
      expect(favs, isNot(contains('zara')));
    });

    test('multiple brands tracked independently', () async {
      await repo.toggleFavorite('zara');
      await repo.toggleFavorite('hm');
      await repo.toggleFavorite('zara'); // remove zara
      final favs = await repo.getFavoriteBrandSlugs();
      expect(favs, isNot(contains('zara')));
      expect(favs, contains('hm'));
    });
  });

  // -------------------------------------------------------------------------
  group('addToHistory', () {
    ConversionRecord _record(String from, String to) => ConversionRecord(
      fromBrandSlug: from,
      toBrandSlug: to,
      gender: 'women',
      chartId: 'tops',
      fromSizeLabel: 'M',
      toSizeLabel: 'M',
      timestamp: DateTime(2024),
    );

    test('new record is inserted at index 0', () async {
      await repo.addToHistory(_record('zara', 'hm'));
      await repo.addToHistory(_record('hm', 'zara'));
      final history = await repo.getHistory();
      expect(history.first.fromBrandSlug, 'hm');
    });

    test('gender field is persisted in history record', () async {
      final record = ConversionRecord(
        fromBrandSlug: 'zara',
        toBrandSlug: 'hm',
        gender: 'men',
        chartId: 'tops',
        fromSizeLabel: 'L',
        toSizeLabel: 'L',
        timestamp: DateTime(2024),
      );
      await repo.addToHistory(record);
      final history = await repo.getHistory();
      expect(history.first.gender, 'men');
    });

    test('history is capped at 50 entries', () async {
      for (var i = 0; i < 55; i++) {
        await repo.addToHistory(_record('zara', 'hm'));
      }
      final history = await repo.getHistory();
      expect(history.length, 50);
    });
  });

  // -------------------------------------------------------------------------
  group('clearHistory', () {
    test('clearHistory returns empty list', () async {
      final record = ConversionRecord(
        fromBrandSlug: 'zara',
        toBrandSlug: 'hm',
        gender: 'women',
        chartId: 'tops',
        fromSizeLabel: 'M',
        toSizeLabel: 'M',
        timestamp: DateTime(2024),
      );
      await repo.addToHistory(record);
      await repo.clearHistory();
      final history = await repo.getHistory();
      expect(history, isEmpty);
    });
  });
}
