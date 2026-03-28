import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizesync/data/models/brand.dart';
import 'package:sizesync/data/models/size_chart.dart';
import 'package:sizesync/data/models/size_entry.dart';
import 'package:sizesync/features/converter/converter_state.dart';
import 'package:sizesync/shared/providers/providers.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({required this.slugA, required this.slugB, super.key});

  final String slugA;
  final String slugB;

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> with SingleTickerProviderStateMixin {
  String? _selectedChartId;
  String? _recommendedLabelA;
  late final AnimationController _rowController;
  final _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _rowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _rowController.dispose();
    super.dispose();
  }

  void _selectChart(String id) {
    if (_selectedChartId == id) return;
    setState(() => _selectedChartId = id);
    _rowController
      ..reset()
      ..forward();
    _loadRecommendations(id);
  }

  Future<void> _loadRecommendations(String chartId) async {
    final gender = ref.read(converterProvider).gender;
    final profile = await ref.read(userRepositoryProvider).getProfile();
    if (!mounted) return;
    if (profile == null) {
      setState(() => _recommendedLabelA = null);
      return;
    }
    final rec = await ref.read(sizeChartRepositoryProvider).recommendSize(brandSlug: widget.slugA, gender: gender, chartId: chartId, profile: profile);
    if (mounted) setState(() => _recommendedLabelA = rec?.label);
  }

  Future<void> _share() async {
    try {
      final boundary = _listKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/size_comparison.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not share')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gender = ref.watch(converterProvider.select((s) => s.gender));
    final optionsKey = (slugA: widget.slugA, slugB: widget.slugB, gender: gender);

    ref.listen<AsyncValue<List<({String id, String name})>>>(comparisonChartOptionsProvider(optionsKey), (prev, next) {
      if (!next.hasValue || next.value!.isEmpty) return;
      final firstId = next.value!.first.id;
      final wasEmpty = prev?.hasValue != true;
      final currentInvalid = _selectedChartId != null && !next.value!.any((o) => o.id == _selectedChartId);
      if (wasEmpty || currentInvalid) {
        if (_selectedChartId == null) setState(() => _selectedChartId = firstId);
        _rowController
          ..reset()
          ..forward();
        _loadRecommendations(firstId);
      }
    });

    final brandsAsync = ref.watch(allBrandsUnfilteredProvider);
    return brandsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(body: SizedBox.shrink()),
      data: (brands) {
        final brandA = brands.where((b) => b.slug == widget.slugA).firstOrNull;
        final brandB = brands.where((b) => b.slug == widget.slugB).firstOrNull;
        if (brandA == null || brandB == null) return const Scaffold(body: Center(child: Text('Brand not found')));

        final optionsAsync = ref.watch(comparisonChartOptionsProvider(optionsKey));
        final effectiveChartId = optionsAsync.when(
          loading: () => _selectedChartId,
          error: (_, _) => _selectedChartId,
          data: (opts) {
            if (opts.isEmpty) return null;
            if (_selectedChartId != null && opts.any((o) => o.id == _selectedChartId)) return _selectedChartId;
            return opts.first.id;
          },
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('${brandA.name} vs ${brandB.name}'),
            actions: [IconButton(icon: const Icon(Icons.share), onPressed: _share)],
          ),
          body: Column(
            children: [
              optionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (opts) => _ChartTypeBar(options: opts, selected: effectiveChartId ?? '', onSelected: _selectChart),
              ),
              Expanded(
                child: effectiveChartId == null
                    ? const Center(child: CircularProgressIndicator())
                    : _ChartsSection(
                        slugA: widget.slugA,
                        slugB: widget.slugB,
                        brandA: brandA,
                        brandB: brandB,
                        gender: gender,
                        chartId: effectiveChartId,
                        recommendedLabelA: _recommendedLabelA,
                        rowController: _rowController,
                        listKey: _listKey,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartTypeBar extends StatelessWidget {
  const _ChartTypeBar({required this.options, required this.selected, required this.onSelected});

  final List<({String id, String name})> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options
              .map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(opt.name), selected: opt.id == selected, onSelected: (_) => onSelected(opt.id)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ChartsSection extends ConsumerWidget {
  const _ChartsSection({
    required this.slugA,
    required this.slugB,
    required this.brandA,
    required this.brandB,
    required this.gender,
    required this.chartId,
    required this.recommendedLabelA,
    required this.rowController,
    required this.listKey,
  });

  final String slugA;
  final String slugB;
  final Brand brandA;
  final Brand brandB;
  final String gender;
  final String chartId;
  final String? recommendedLabelA;
  final AnimationController rowController;
  final GlobalKey listKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartsAsync = ref.watch(comparisonChartsProvider((slugA: slugA, slugB: slugB, gender: gender, chartId: chartId)));

    return chartsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading charts')),
      data: (charts) {
        final chartA = charts.chartA;
        final chartB = charts.chartB;
        if (chartA == null || chartB == null) return const Center(child: Text('Size chart not available'));

        final rows = _buildRows(chartA.sizes, chartB.sizes);
        final explanation = _explanation(rows);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: listKey,
                child: Column(
                  children: rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    final start = (i / rows.length * 0.6).clamp(0.0, 1.0);
                    final end = (start + 0.4).clamp(0.0, 1.0);
                    final anim = CurvedAnimation(
                      parent: rowController,
                      curve: Interval(start, end, curve: Curves.easeOut),
                    );
                    return AnimatedBuilder(
                      animation: anim,
                      builder: (ctx, child) => Opacity(
                        opacity: anim.value,
                        child: Transform.translate(offset: Offset(0, 14 * (1 - anim.value)), child: child),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ComparisonRow(
                          fromSize: row.sizeA,
                          toSize: row.matchedSizeB,
                          fromBrandName: brandA.name,
                          toBrandName: brandB.name,
                          isRecommended: row.sizeA.label == recommendedLabelA,
                          measurements: chartA.measurements,
                          euLabel: row.euLabel,
                          labelsMatch: row.labelsMatch,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (explanation != null) ...[const SizedBox(height: 16), _ExplanationCard(text: explanation)],
            ],
          ),
        );
      },
    );
  }

  List<_RowData> _buildRows(List<SizeEntry> sizesA, List<SizeEntry> sizesB) {
    final sorted = [...sizesA]..sort((a, b) => a.order.compareTo(b.order));
    return sorted.map((sizeA) {
      final matched = sizesB.where((sizeB) => sizeB.eu.any(sizeA.eu.contains)).firstOrNull;
      final euA = sizeA.eu.firstOrNull ?? '';
      final euB = matched?.eu.firstOrNull ?? '';
      final euLabel = matched == null || euA == euB || euB.isEmpty ? (euA.isEmpty ? '' : 'EU $euA') : 'EU $euA / $euB';
      return _RowData(sizeA: sizeA, matchedSizeB: matched, euLabel: euLabel, labelsMatch: matched == null || matched.label == sizeA.label);
    }).toList();
  }

  String? _explanation(List<_RowData> rows) {
    if (recommendedLabelA == null) return null;
    final rec = rows.where((r) => r.sizeA.label == recommendedLabelA).firstOrNull;
    if (rec == null) return null;
    final matchLabel = rec.matchedSizeB?.label ?? '—';
    return 'Your recommended size is highlighted (${rec.sizeA.label} in ${brandA.name} = $matchLabel in ${brandB.name})';
  }
}

class _RowData {
  const _RowData({required this.sizeA, required this.matchedSizeB, required this.euLabel, required this.labelsMatch});

  final SizeEntry sizeA;
  final SizeEntry? matchedSizeB;
  final String euLabel;
  final bool labelsMatch;
}

class ComparisonRow extends StatefulWidget {
  const ComparisonRow({
    required this.fromSize,
    required this.toSize,
    required this.fromBrandName,
    required this.toBrandName,
    required this.isRecommended,
    required this.measurements,
    required this.euLabel,
    required this.labelsMatch,
    super.key,
  });

  final SizeEntry fromSize;
  final SizeEntry? toSize;
  final String fromBrandName;
  final String toBrandName;
  final bool isRecommended;
  final List<String> measurements;
  final String euLabel;
  final bool labelsMatch;

  @override
  State<ComparisonRow> createState() => _ComparisonRowState();
}

class _ComparisonRowState extends State<ComparisonRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isRecommended ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4) : theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(widget.fromSize.label, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  _buildIndicator(theme),
                  const SizedBox(width: 12),
                  Text(widget.toSize?.label ?? '—', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (widget.euLabel.isNotEmpty) ...[
                    Text(widget.euLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(width: 8),
                  ],
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildMeasurements(theme),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    if (widget.toSize == null) {
      return Text('→', style: TextStyle(color: theme.colorScheme.outline, fontSize: 18));
    }
    if (widget.labelsMatch) {
      return Text(
        '=',
        style: TextStyle(color: theme.colorScheme.outline, fontSize: 18, fontWeight: FontWeight.w600),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(6)),
      child: Text(
        '≠',
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMeasurements(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _MeasurementCard(brandName: widget.fromBrandName, sizeEntry: widget.fromSize, measurements: widget.measurements),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: widget.toSize != null
                ? _MeasurementCard(brandName: widget.toBrandName, sizeEntry: widget.toSize!, measurements: widget.measurements)
                : _NoMappingCard(),
          ),
        ],
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({required this.brandName, required this.sizeEntry, required this.measurements});

  final String brandName;
  final SizeEntry sizeEntry;
  final List<String> measurements;

  String _name(String key) => switch (key) {
    'bust' => 'bust',
    'chest' => 'chest',
    'waist' => 'waist',
    'hips' => 'hips',
    'foot_length' => 'foot',
    _ => key,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = measurements.where((k) => sizeEntry.values[k] != null).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$brandName ${sizeEntry.label}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          if (keys.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...keys.map((k) {
              final range = sizeEntry.values[k]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                    children: [
                      TextSpan(
                        text: '${_name(k)}: ',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                      TextSpan(
                        text: '${range.min.toStringAsFixed(0)}–${range.max.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _NoMappingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: Text('No match', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}
