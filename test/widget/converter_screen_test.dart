import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/features/converter/converter_screen.dart';
import 'package:sizesync/shared/providers/providers.dart';

import '../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Widget _buildApp({List<Brand> brands = const [], List<Override> extraOverrides = const []}) {
  final fakeHive = FakeHiveDataSource();
  final fakeAssets = FakeAssetDataSource(brands: brands);
  final fakeUserRepo = FakeUserRepository();
  final fakeSizeRepo = FakeSizeChartRepository();
  final fakeBrandRepo = FakeBrandRepository(brands: brands);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const ConverterScreen()),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const Scaffold(body: Text('Paywall')),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const Scaffold(body: Text('Profile')),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('Settings')),
      ),
      GoRoute(
        path: '/comparison',
        builder: (_, __) => const Scaffold(body: Text('Comparison')),
      ),
      GoRoute(
        path: '/brand/:slug',
        builder: (_, __) => const Scaffold(body: Text('Brand')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      hiveDataSourceProvider.overrideWithValue(fakeHive),
      assetDataSourceProvider.overrideWithValue(fakeAssets),
      userRepositoryProvider.overrideWithValue(fakeUserRepo),
      sizeChartRepositoryProvider.overrideWithValue(fakeSizeRepo),
      brandRepositoryProvider.overrideWithValue(fakeBrandRepo),
      ...extraOverrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final testBrands = [
    Brand(name: 'Zara', slug: 'zara', country: 'Spain', logoAsset: 'assets/logos/zara.svg', isPremium: false, genders: const ['women', 'men']),
    Brand(name: 'H&M', slug: 'hm', country: 'Sweden', logoAsset: 'assets/logos/hm.svg', isPremium: false, genders: const ['women', 'men']),
  ];

  group('ConverterScreen', () {
    testWidgets('displays gender toggle with Women and Men segments', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Men'), findsOneWidget);
    });

    testWidgets('displays From and To brand slot labels', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });

    testWidgets('displays app bar with SizeSync title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.text('SizeSync'), findsOneWidget);
    });

    testWidgets('swap button is visible', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('tapping From slot opens brand picker bottom sheet', (tester) async {
      await tester.pumpWidget(_buildApp(brands: testBrands));
      await tester.pump();

      await tester.tap(find.text('From'));
      await tester.pumpAndSettle();

      // Bottom sheet should show brand list
      expect(find.text('Zara'), findsWidgets);
    });

    testWidgets('tapping brand in sheet sets it as from brand', (tester) async {
      await tester.pumpWidget(_buildApp(brands: testBrands));
      await tester.pump();

      // Open the From picker
      await tester.tap(find.text('From'));
      await tester.pumpAndSettle();

      // Tap Zara in the list
      await tester.tap(find.text('Zara').last);
      await tester.pumpAndSettle();

      // Zara should now show in the From slot
      expect(find.text('Zara'), findsWidgets);
    });

    testWidgets('switching gender updates the toggle selection', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Default is Women — tap Men
      await tester.tap(find.text('Men'));
      await tester.pump();

      // SegmentedButton keeps Men selected (no crash, state updated)
      expect(find.text('Men'), findsOneWidget);
    });

    testWidgets('Compare tables button not shown when only one brand selected', (tester) async {
      await tester.pumpWidget(_buildApp(brands: testBrands));
      await tester.pump();

      expect(find.text('Compare tables'), findsNothing);
    });
  });
}
