import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/features/converter/converter_state.dart';
import 'package:sizesync/shared/providers/providers.dart';

class BrandCardScreen extends ConsumerStatefulWidget {
  const BrandCardScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<BrandCardScreen> createState() => _BrandCardScreenState();
}

class _BrandCardScreenState extends ConsumerState<BrandCardScreen> {
  String? _selectedChartId;

  @override
  Widget build(BuildContext context) {
    final gender = ref.watch(converterProvider.select((s) => s.gender));
    final isPremiumUser = ref.watch(purchaseProvider);
    final favorites = ref.watch(favoritesProvider);
    final brandsAsync = ref.watch(allBrandsUnfilteredProvider);
    final chartsAsync = ref.watch(brandChartsProvider((slug: widget.slug, gender: gender)));

    return brandsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Scaffold(body: SizedBox.shrink()),
      data: (brands) {
        final brand = brands.where((b) => b.slug == widget.slug).firstOrNull;
        if (brand == null) return const Scaffold(body: Center(child: Text('Brand not found')));

        final isFavorite = favorites.contains(widget.slug);
        final theme = Theme.of(context);

        final favoriteAction = IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          color: isFavorite ? theme.colorScheme.primary : null,
          onPressed: () => ref.read(favoritesProvider.notifier).toggle(widget.slug),
        );

        if (brand.isPremium && !isPremiumUser) {
          return Scaffold(
            appBar: AppBar(title: Text(brand.name), actions: [favoriteAction]),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BrandHeader(brand: brand),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('Premium brand', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock Premium to see the full size chart',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: () => context.push('/paywall'), child: const Text('Unlock Premium')),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return chartsAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(brand.name), actions: [favoriteAction]),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Scaffold(
            appBar: AppBar(title: Text(brand.name), actions: [favoriteAction]),
            body: const SizedBox.shrink(),
          ),
          data: (charts) {
            final effectiveId = _selectedChartId != null && charts.any((c) => c.chartId == _selectedChartId) ? _selectedChartId! : charts.firstOrNull?.chartId;
            final selectedChart = charts.where((c) => c.chartId == effectiveId).firstOrNull;

            return Scaffold(
              appBar: AppBar(title: Text(brand.name), actions: [favoriteAction]),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandHeader(brand: brand),
                          if (charts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _ChartChips(charts: charts, selectedId: effectiveId ?? '', onSelected: (id) => setState(() => _selectedChartId = id)),
                          ],
                          if (selectedChart != null) ...[const SizedBox(height: 12), _SizeTable(chart: selectedChart)],
                          const SizedBox(height: 16),
                          _RecommendedSizes(slug: widget.slug, gender: gender),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  _BottomBar(brand: brand),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(brand.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(brand.country, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        if (brand.website != null) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => launchUrl(Uri.parse(brand.website!), mode: LaunchMode.externalApplication),
            child: Text(
              brand.website!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChartChips extends StatelessWidget {
  const _ChartChips({required this.charts, required this.selectedId, required this.onSelected});

  final List<SizeChart> charts;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: charts
            .map(
              (chart) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(chart.name), selected: chart.chartId == selectedId, onSelected: (_) => onSelected(chart.chartId)),
              ),
            )
            .toList(),
      ),
    );
  }
}

const double _kLabelW = 72.0;
const double _kSystemW = 88.0;

class _SizeTable extends StatelessWidget {
  const _SizeTable({required this.chart});

  final SizeChart chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline);
    final bodyStyle = theme.textTheme.bodyMedium;
    final sorted = [...chart.sizes]..sort((a, b) => a.order.compareTo(b.order));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _kLabelW,
                        child: Text('Size', style: labelStyle),
                      ),
                      SizedBox(
                        width: _kSystemW,
                        child: Text('EU', style: labelStyle),
                      ),
                      SizedBox(
                        width: _kSystemW,
                        child: Text('US', style: labelStyle),
                      ),
                      SizedBox(
                        width: _kSystemW,
                        child: Text('UK', style: labelStyle),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...sorted.map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _kLabelW,
                          child: Text(s.label, style: bodyStyle?.copyWith(fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(
                          width: _kSystemW,
                          child: Text(s.eu.isEmpty ? '—' : s.eu.join(', '), style: bodyStyle),
                        ),
                        SizedBox(
                          width: _kSystemW,
                          child: Text(s.us.isEmpty ? '—' : s.us.join(', '), style: bodyStyle),
                        ),
                        SizedBox(
                          width: _kSystemW,
                          child: Text(s.uk.isEmpty ? '—' : s.uk.join(', '), style: bodyStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecommendedSizes extends ConsumerWidget {
  const _RecommendedSizes({required this.slug, required this.gender});

  final String slug;
  final String gender;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    if (profile == null) return const SizedBox.shrink();

    final primaryMeasurement = gender == 'men' ? profile.chestCm : profile.bustCm;
    final hasProfile = primaryMeasurement != null || profile.waistCm != null || profile.hipsCm != null || profile.footLengthCm != null;

    if (!hasProfile) {
      final theme = Theme.of(context);
      return Row(
        children: [
          Icon(Icons.straighten, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              children: [
                Text('Fill in your ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Text(
                    'profile',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Text(' for size recommendations', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ],
      );
    }

    final recsAsync = ref.watch(brandRecommendedSizesProvider((slug: slug, gender: gender)));
    return recsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (recs) {
        final entries = recs.entries.where((e) => e.value != null).toList();
        if (entries.isEmpty) return const SizedBox.shrink();

        final theme = Theme.of(context);
        return Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, size: 16, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text('Your size', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entries.map((e) => '${e.key}: ${e.value!.label}').join('  ·  '),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(converterProvider.notifier).setFromBrand(brand);
                  context.go('/');
                },
                child: const Text('Convert from'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ref.read(converterProvider.notifier).setToBrand(brand);
                  context.go('/');
                },
                child: const Text('Convert to'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
