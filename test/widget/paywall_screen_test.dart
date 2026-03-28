import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizesync/features/settings/paywall_screen.dart';
import 'package:sizesync/shared/providers/providers.dart';

import '../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Stub the purchases_flutter MethodChannel so it doesn't throw MissingPlugin.
// PaywallScreen calls Purchases.getOfferings() in initState.
// The stub returns an exception which is caught by _loadOffering's try-catch,
// leaving _loadingOffering = false and _package = null.
// ---------------------------------------------------------------------------
const _purchasesChannel = MethodChannel('purchases_flutter');

void _stubPurchasesChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_purchasesChannel, (call) async {
    throw PlatformException(code: 'UNAVAILABLE');
  });
}

Widget _buildPaywall() {
  final fakeHive = FakeHiveDataSource();

  return ProviderScope(
    overrides: [
      hiveDataSourceProvider.overrideWithValue(fakeHive),
      // purchaseServiceProvider uses a real PurchaseService but no-ops in tests
      // because the RevenueCat API keys are empty strings at test time.
    ],
    child: const MaterialApp(home: PaywallScreen()),
  );
}

// ---------------------------------------------------------------------------

void main() {
  setUp(_stubPurchasesChannel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_purchasesChannel, null);
  });

  group('PaywallScreen', () {
    testWidgets('displays SizeSync Premium title', (tester) async {
      await tester.pumpWidget(_buildPaywall());
      await tester.pumpAndSettle();
      expect(find.text('SizeSync Premium'), findsOneWidget);
    });

    testWidgets('displays three benefit cards', (tester) async {
      await tester.pumpWidget(_buildPaywall());
      await tester.pumpAndSettle();
      expect(find.text('500+ брендов'), findsOneWidget);
      expect(find.text('Персональный подбор'), findsOneWidget);
      expect(find.text('Полная база офлайн'), findsOneWidget);
    });

    testWidgets('buy button contains Разблокировать', (tester) async {
      await tester.pumpWidget(_buildPaywall());
      await tester.pumpAndSettle();
      // _package is null (channel threw), so priceString = '—'
      expect(find.textContaining('Разблокировать'), findsOneWidget);
    });

    testWidgets('restore button is visible', (tester) async {
      await tester.pumpWidget(_buildPaywall());
      await tester.pumpAndSettle();
      expect(find.text('Восстановить покупки'), findsOneWidget);
    });

    testWidgets('buy button is enabled when not busy', (tester) async {
      await tester.pumpWidget(_buildPaywall());
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
