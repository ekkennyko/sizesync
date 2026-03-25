import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizesync/core/constants/app_constants.dart';

const _premiumOverride = bool.fromEnvironment('PREMIUM_OVERRIDE');

class PurchaseService {
  final _controller = StreamController<bool>.broadcast();
  bool _isPremium = false;
  bool _configured = false;

  bool get isPremium => _premiumOverride || _isPremium;
  Stream<bool> get isPremiumStream => _controller.stream;

  void seedCachedStatus({required bool value}) => _isPremium = value;

  Future<void> init() async {
    if (_premiumOverride) return;

    final apiKey = Platform.isIOS ? const String.fromEnvironment('REVENUECAT_IOS_KEY') : const String.fromEnvironment('REVENUECAT_ANDROID_KEY');

    if (apiKey.isEmpty) return;

    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;

    Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);

    try {
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
    } catch (_) {}
  }

  void _onCustomerInfo(CustomerInfo info) {
    _emit(info.entitlements.active.containsKey(AppConstants.entitlementId));
  }

  void _emit(bool value) {
    _isPremium = value;
    _controller.add(value);
  }

  Future<bool> buyPremium() async {
    if (!_configured) return false;
    final offerings = await Purchases.getOfferings();
    final package = offerings.current?.availablePackages.firstOrNull;
    if (package == null) throw Exception('No offerings available');
    final info = await Purchases.purchasePackage(package);
    final active = info.entitlements.active.containsKey(AppConstants.entitlementId);
    _emit(active);
    return active;
  }

  Future<bool> restorePurchases() async {
    if (!_configured) return false;
    final info = await Purchases.restorePurchases();
    final active = info.entitlements.active.containsKey(AppConstants.entitlementId);
    _emit(active);
    return active;
  }
}
