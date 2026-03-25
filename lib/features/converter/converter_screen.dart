import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/features/converter/brand_picker_sheet.dart';
import 'package:sizesync/features/converter/converter_state.dart';
import 'package:sizesync/shared/providers/providers.dart';

class ConverterScreen extends ConsumerWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SizeSync'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FavoritesSection(),
            _BrandRow(fromBrand: state.fromBrand, toBrand: state.toBrand),
            const SizedBox(height: 16),
            _CategoryChips(selected: state.categorySlug, fromBrand: state.fromBrand),
            const SizedBox(height: 16),
            if (state.fromBrand != null) _SizeGrid(brandSlug: state.fromBrand!.slug, categorySlug: state.categorySlug, selectedLabel: state.selectedSizeLabel),
            const SizedBox(height: 16),
            if (state.result != null) _ResultCard(result: state.result!, toBrand: state.toBrand!, recommendedSize: state.recommendedSize),
            const SizedBox(height: 8),
            const _RecentSection(),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends ConsumerWidget {
  const _BrandRow({required this.fromBrand, required this.toBrand});

  final Brand? fromBrand;
  final Brand? toBrand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _BrandCard(
            label: 'From',
            brand: fromBrand,
            onTap: () => BrandPickerSheet.show(context, (b) => ref.read(converterProvider.notifier).setFromBrand(b)),
          ),
        ),
        _SwapButton(onTap: () => ref.read(converterProvider.notifier).swapBrands()),
        Expanded(
          child: _BrandCard(
            label: 'To',
            brand: toBrand,
            onTap: () => BrandPickerSheet.show(context, (b) => ref.read(converterProvider.notifier).setToBrand(b)),
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.label, required this.brand, required this.onTap});

  final String label;
  final Brand? brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: 'brand_card_$label',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 6),
                Text(
                  brand?.name ?? 'Select',
                  style: theme.textTheme.titleMedium?.copyWith(color: brand == null ? theme.colorScheme.outline : null, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (brand != null) ...[
                  const SizedBox(height: 2),
                  Text(brand!.country, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  double _turns = 0;

  void _handleTap() {
    setState(() => _turns += 0.5);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: _turns,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: IconButton(icon: const Icon(Icons.swap_horiz), onPressed: _handleTap),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.selected, required this.fromBrand});

  final String selected;
  final Brand? fromBrand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (categories) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final enabled = fromBrand == null || fromBrand!.categories.contains(cat.slug);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: selected == cat.slug,
                  onSelected: enabled ? (_) => ref.read(converterProvider.notifier).setCategory(cat.slug) : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SizeGrid extends ConsumerWidget {
  const _SizeGrid({required this.brandSlug, required this.categorySlug, required this.selectedLabel});

  final String brandSlug;
  final String categorySlug;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizesAsync = ref.watch(fromSizeEntriesProvider((brandSlug: brandSlug, categorySlug: categorySlug)));
    final theme = Theme.of(context);

    return sizesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (sizes) {
        if (sizes.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select size', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sizes.map((entry) {
                final isSelected = entry.label == selectedLabel;
                return FilterChip(
                  label: Text(entry.label),
                  selected: isSelected,
                  onSelected: (_) => ref.read(converterProvider.notifier).selectSize(entry.label),
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: isSelected ? TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold) : null,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.toBrand, this.recommendedSize});

  final SizeEntry result;
  final Brand toBrand;
  final SizeEntry? recommendedSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mappings = [
      if (result.eu != null) ('EU', result.eu!),
      if (result.us != null) ('US', result.us!),
      if (result.uk != null) ('UK', result.uk!),
      if (result.asia != null) ('Asia', result.asia!),
    ];

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your size in ${toBrand.name}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  result.label,
                  style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                if (mappings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    children: mappings.map((m) {
                      return RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: '${m.$1} ',
                              style: TextStyle(color: theme.colorScheme.outline),
                            ),
                            TextSpan(
                              text: m.$2,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (recommendedSize != null) ...[
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.straighten, size: 18, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommended by your measurements: ${recommendedSize!.label}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FavoritesSection extends ConsumerWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    if (favorites.isEmpty) return const SizedBox.shrink();

    final brandsAsync = ref.watch(allBrandsProvider);
    return brandsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (brands) {
        final favBrands = brands.where((b) => favorites.contains(b.slug)).toList();
        if (favBrands.isEmpty) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Favourites', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favBrands.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final brand = favBrands[i];
                  return GestureDetector(
                    onTap: () => ref.read(converterProvider.notifier).setFromBrand(brand),
                    onLongPress: () => _confirmRemove(ctx, ref, brand.slug, brand.name),
                    child: _FavouriteBrandChip(brand: brand),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, String slug, String name) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from favourites?'),
        content: Text(name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(slug);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _FavouriteBrandChip extends StatelessWidget {
  const _FavouriteBrandChip({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              brand.name[0].toUpperCase(),
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(brand.name, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    if (history.isEmpty) return const SizedBox.shrink();

    final brandsAsync = ref.watch(allBrandsProvider);
    return brandsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (brands) {
        final brandNames = {for (final b in brands) b.slug: b.name};
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Recent', style: theme.textTheme.labelLarge),
                const Spacer(),
                TextButton(onPressed: () => ref.read(historyProvider.notifier).clear(), child: const Text('Clear')),
              ],
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) =>
                    _HistoryChip(record: history[i], brandNames: brandNames, onTap: () => ref.read(converterProvider.notifier).restoreFromHistory(history[i])),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.record, required this.brandNames, required this.onTap});

  final ConversionRecord record;
  final Map<String, String> brandNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final from = brandNames[record.fromBrandSlug] ?? record.fromBrandSlug;
    final to = brandNames[record.toBrandSlug] ?? record.toBrandSlug;
    return ActionChip(label: Text('$from ${record.fromSize} → $to ${record.toSize}'), onPressed: onTap);
  }
}
