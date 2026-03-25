import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  Future<void> init({required String apiKey}) async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Future<bool> isPremium() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.isNotEmpty;
  }
}
