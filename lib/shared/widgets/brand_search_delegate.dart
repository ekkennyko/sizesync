import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/shared/providers/providers.dart';

class BrandSearchDelegate extends SearchDelegate<void> {
  BrandSearchDelegate(this._ref);

  final WidgetRef _ref;

  @override
  String get searchFieldLabel => 'Поиск брендов…';

  @override
  List<Widget> buildActions(BuildContext context) => [if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => BackButton(onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _SearchBody(query: query, onSelect: (b) => _selectBrand(context, b), onRemoveRecent: _removeRecent);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchBody(query: query, onSelect: (b) => _selectBrand(context, b), onRemoveRecent: _removeRecent);

  void _removeRecent(String slug) => _ref.read(recentSearchesProvider.notifier).remove(slug);

  void _selectBrand(BuildContext context, Brand brand) {
    _ref.read(recentSearchesProvider.notifier).add(brand.slug);
    close(context, null);
    context.push('/brand/${brand.slug}');
  }
}

class _SearchBody extends ConsumerStatefulWidget {
  const _SearchBody({required this.query, required this.onSelect, required this.onRemoveRecent});

  final String query;
  final ValueChanged<Brand> onSelect;
  final ValueChanged<String> onRemoveRecent;

  @override
  ConsumerState<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends ConsumerState<_SearchBody> {
  String _activeQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _activeQuery = widget.query;
  }

  @override
  void didUpdateWidget(_SearchBody old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _activeQuery = widget.query);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(allBrandsUnfilteredProvider);
    final recentSlugs = ref.watch(recentSearchesProvider);
    final isPremium = ref.watch(purchaseProvider);

    return brandsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (brands) {
        if (_activeQuery.isEmpty) {
          final recentBrands = recentSlugs
              .map((slug) {
                try {
                  return brands.firstWhere((b) => b.slug == slug);
                } catch (_) {
                  return null;
                }
              })
              .whereType<Brand>()
              .toList();
          return _RecentSection(brands: recentBrands, onSelect: widget.onSelect, onRemove: widget.onRemoveRecent);
        }

        final q = _activeQuery.toLowerCase();
        final filtered = brands
            .where((b) => b.name.toLowerCase().contains(q) || b.slug.toLowerCase().contains(q) || b.country.toLowerCase().contains(q))
            .toList();
        return _ResultSection(brands: filtered, isPremium: isPremium, onSelect: widget.onSelect);
      },
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.brands, required this.onSelect, required this.onRemove});

  final List<Brand> brands;
  final ValueChanged<Brand> onSelect;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return Center(
        child: Text('Начните вводить название бренда', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Недавние', style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: brands.length,
            itemBuilder: (_, i) {
              final brand = brands[i];
              return _BrandTile(
                brand: brand,
                onTap: () => onSelect(brand),
                trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => onRemove(brand.slug)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.brands, required this.isPremium, required this.onSelect});

  final List<Brand> brands;
  final bool isPremium;
  final ValueChanged<Brand> onSelect;

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return Center(
        child: Text('Ничего не найдено', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
      );
    }

    return ListView.builder(
      itemCount: brands.length,
      itemBuilder: (_, i) {
        final brand = brands[i];
        return _BrandTile(brand: brand, onTap: () => onSelect(brand));
      },
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.brand, required this.onTap, this.trailing});

  final Brand brand;
  final VoidCallback onTap;
  final Widget? trailing;

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
      trailing:
          trailing ??
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: brand.isPremium ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (brand.isPremium) ...[
                  Icon(Icons.lock, size: 12, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Text('Premium', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                ] else
                  Text('Free', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
      onTap: onTap,
    );
  }
}
