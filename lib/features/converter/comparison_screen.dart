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
  final _tableKey = GlobalKey();

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
      final boundary = _tableKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
        if (_selectedChartId == null) {
          setState(() => _selectedChartId = firstId);
        }
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
        if (brandA == null || brandB == null) {
          return const Scaffold(body: Center(child: Text('Brand not found')));
        }

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
                        tableKey: _tableKey,
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
    required this.tableKey,
  });

  final String slugA;
  final String slugB;
  final Brand brandA;
  final Brand brandB;
  final String gender;
  final String chartId;
  final String? recommendedLabelA;
  final AnimationController rowController;
  final GlobalKey tableKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartsAsync = ref.watch(comparisonChartsProvider((slugA: slugA, slugB: slugB, gender: gender, chartId: chartId)));

    return chartsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading charts')),
      data: (charts) {
        final chartA = charts.chartA;
        final chartB = charts.chartB;
        if (chartA == null || chartB == null) {
          return const Center(child: Text('Size chart not available'));
        }

        final rows = _buildRows(chartA.sizes, chartB.sizes);
        final explanation = _explanation(rows);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: tableKey,
                child: _ComparisonTable(
                  brandA: brandA,
                  brandB: brandB,
                  chartA: chartA,
                  rows: rows,
                  recommendedLabelA: recommendedLabelA,
                  rowController: rowController,
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
      return _RowData(sizeA: sizeA, matchedSizeB: matched, euLabel: sizeA.eu.firstOrNull ?? '', labelsMatch: matched == null || matched.label == sizeA.label);
    }).toList();
  }

  String? _explanation(List<_RowData> rows) {
    if (recommendedLabelA == null) return null;
    final rec = rows.where((r) => r.sizeA.label == recommendedLabelA).firstOrNull;
    if (rec == null) return null;
    final matchLabel = rec.matchedSizeB?.label ?? '—';
    return 'Ваш размер ${rec.sizeA.label} в ${brandA.name} соответствует $matchLabel в ${brandB.name}';
  }
}

const double _kColLabel = 80.0;
const double _kColEu = 44.0;
const double _kColIndicator = 28.0;
const double _kColMeasurements = 168.0;

class _RowData {
  const _RowData({required this.sizeA, required this.matchedSizeB, required this.euLabel, required this.labelsMatch});

  final SizeEntry sizeA;
  final SizeEntry? matchedSizeB;
  final String euLabel;
  final bool labelsMatch;
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.brandA,
    required this.brandB,
    required this.chartA,
    required this.rows,
    required this.recommendedLabelA,
    required this.rowController,
  });

  final Brand brandA;
  final Brand brandB;
  final SizeChart chartA;
  final List<_RowData> rows;
  final String? recommendedLabelA;
  final AnimationController rowController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: _kColLabel,
                  child: Text(brandA.name, style: labelStyle, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(
                  width: _kColEu,
                  child: Text('EU', style: labelStyle),
                ),
                SizedBox(
                  width: _kColLabel,
                  child: Text(brandB.name, style: labelStyle, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: _kColIndicator),
                SizedBox(
                  width: _kColMeasurements,
                  child: Text('Мерки', style: labelStyle),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows.asMap().entries.map((e) {
            final index = e.key;
            final row = e.value;
            final start = (index / rows.length * 0.65).clamp(0.0, 1.0);
            final end = (start + 0.45).clamp(0.0, 1.0);
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
              child: _TableDataRow(row: row, measurements: chartA.measurements, isHighlighted: row.sizeA.label == recommendedLabelA),
            );
          }),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({required this.row, required this.measurements, required this.isHighlighted});

  final _RowData row;
  final List<String> measurements;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: isHighlighted ? FontWeight.bold : null);

    return Container(
      color: isHighlighted ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: _kColLabel,
            child: Text(row.sizeA.label, style: bodyStyle),
          ),
          SizedBox(
            width: _kColEu,
            child: Text(row.euLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ),
          SizedBox(
            width: _kColLabel,
            child: Text(row.matchedSizeB?.label ?? '—', style: bodyStyle),
          ),
          SizedBox(
            width: _kColIndicator,
            child: !row.labelsMatch && row.matchedSizeB != null
                ? Text(
                    '≠',
                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 13),
                  )
                : null,
          ),
          SizedBox(
            width: _kColMeasurements,
            child: Text(
              _formatMeasurements(),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMeasurements() {
    final parts = <String>[];
    for (final key in measurements) {
      final range = row.sizeA.values[key];
      if (range == null) continue;
      final name = switch (key) {
        'bust' => 'Бюст',
        'waist' => 'Талия',
        'hips' => 'Бёдра',
        'chest' => 'Грудь',
        'foot_length' => 'Ступня',
        _ => key,
      };
      parts.add('$name ${range.min.toStringAsFixed(0)}–${range.max.toStringAsFixed(0)}');
    }
    return parts.join('  ');
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
