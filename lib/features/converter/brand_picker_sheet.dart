import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/features/converter/converter_state.dart';
import 'package:sizesync/shared/providers/providers.dart';

class BrandPickerSheet extends ConsumerStatefulWidget {
  const BrandPickerSheet({required this.onBrandSelected, super.key});

  final ValueChanged<Brand> onBrandSelected;

  static Future<void> show(BuildContext context, ValueChanged<Brand> onBrandSelected) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => BrandPickerSheet(onBrandSelected: onBrandSelected),
    );
  }

  @override
  ConsumerState<BrandPickerSheet> createState() => _BrandPickerSheetState();
}

class _BrandPickerSheetState extends ConsumerState<BrandPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _onBrandTap(BuildContext context, Brand brand) {
    if (brand.isPremium && !ref.read(purchaseProvider)) {
      Navigator.of(context).pop();
      context.push('/paywall');
      return;
    }
    Navigator.of(context).pop();
    widget.onBrandSelected(brand);
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(allBrandsUnfilteredProvider);
    final favorites = ref.watch(favoritesProvider);
    final gender = ref.watch(converterProvider.select((s) => s.gender));
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search brands…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: brandsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (brands) {
                  final genderBrands = brands.where((b) => b.genders.contains(gender)).toList();
                  final filtered = _query.isEmpty ? genderBrands : genderBrands.where((b) => b.name.toLowerCase().contains(_query.toLowerCase())).toList();

                  final favBrands = genderBrands.where((b) => favorites.contains(b.slug)).toList();

                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      if (favBrands.isNotEmpty && _query.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: Text('Favourites', style: theme.textTheme.labelLarge),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: favBrands.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => _FavouriteAvatar(brand: favBrands[i], onTap: () => _onBrandTap(context, favBrands[i])),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: Divider(height: 16)),
                      ],
                      SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _BrandTile(
                          brand: filtered[i],
                          onTap: () => _onBrandTap(context, filtered[i]),
                          isFavorite: favorites.contains(filtered[i].slug),
                          onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(filtered[i].slug),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavouriteAvatar extends StatelessWidget {
  const _FavouriteAvatar({required this.brand, required this.onTap});

  final Brand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              brand.name[0].toUpperCase(),
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(brand.name, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.brand, required this.onTap, required this.isFavorite, required this.onFavoriteTap});

  final Brand brand;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(brand.name[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
      ),
      title: Text(brand.name),
      subtitle: Text(brand.country),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (brand.isPremium) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 12, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Text('Premium', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? theme.colorScheme.primary : null,
            onPressed: onFavoriteTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
