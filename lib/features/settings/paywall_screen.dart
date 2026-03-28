import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizesync/shared/providers/providers.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _package;
  bool _loadingOffering = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (mounted) {
        setState(() {
          _package = offerings.current?.availablePackages.firstOrNull;
          _loadingOffering = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOffering = false);
    }
  }

  Future<void> _buy() async {
    setState(() => _busy = true);
    try {
      final success = await ref.read(purchaseProvider.notifier).buyPremium();
      if (mounted && success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium активирован!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final success = await ref.read(purchaseProvider.notifier).restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Premium восстановлен!' : 'Активных покупок не найдено')));
        if (success) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorMessage(dynamic e) {
    if (e is PlatformException) {
      return switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError => 'Покупка отменена',
        PurchasesErrorCode.networkError => 'Нет подключения к интернету',
        PurchasesErrorCode.storeProblemError => 'Ошибка магазина',
        PurchasesErrorCode.receiptAlreadyInUseError => 'Покупка уже активирована',
        _ => 'Произошла ошибка. Попробуйте снова.',
      };
    }
    return 'Произошла ошибка. Попробуйте снова.';
  }

  @override
  Widget build(BuildContext context) {
    final priceString = _package?.storeProduct.priceString ?? '—';
    final isLoading = _loadingOffering || _busy;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('SizeSync Premium')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Icon(Icons.workspace_premium_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 32),
                          const _BenefitCard(icon: Icons.grid_view_rounded, title: '500+ брендов', subtitle: 'Полная база мировых брендов одежды'),
                          const SizedBox(height: 12),
                          const _BenefitCard(icon: Icons.accessibility_new, title: 'Персональный подбор', subtitle: 'Размер по вашим меркам для любого бренда'),
                          const SizedBox(height: 12),
                          const _BenefitCard(icon: Icons.cloud_off, title: 'Полная база офлайн', subtitle: 'Работает без интернета в любой точке мира'),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : _buy,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: Text('Разблокировать — $priceString'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _busy ? null : _restore, child: const Text('Восстановить покупки')),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) ...[
          ModalBarrier(dismissible: false, color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.26)),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
