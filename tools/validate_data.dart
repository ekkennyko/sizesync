// ignore_for_file: avoid_print, avoid_dynamic_calls
import 'dart:convert';
import 'dart:io';

void main() async {
  final brandsFile = File('assets/data/brands.json');
  if (!brandsFile.existsSync()) {
    stderr.writeln('ERROR: assets/data/brands.json not found');
    exit(1);
  }

  final List<dynamic> brands = (jsonDecode(brandsFile.readAsStringSync()) as List<dynamic>);
  int failCount = 0;
  int passCount = 0;

  for (final brand in brands) {
    final String name = brand['name'] as String;
    final String slug = brand['slug'] as String;
    final List<String> genders = (brand['genders'] as List<dynamic>).cast<String>();

    final chartFile = File('assets/data/size_charts/$slug.json');
    if (!chartFile.existsSync()) {
      print('✗ $name: size chart file not found (assets/data/size_charts/$slug.json)');
      failCount++;
      continue;
    }

    Map<String, dynamic> chartData;
    try {
      chartData = jsonDecode(chartFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      print('✗ $name: invalid JSON — $e');
      failCount++;
      continue;
    }

    final errors = <String>[];

    // Check that genders in brands.json match keys in the chart file
    for (final gender in genders) {
      if (!chartData.containsKey(gender)) {
        errors.add('missing "$gender" key in chart file (brands.json genders: $genders)');
      }
    }

    // Check for unexpected gender keys in the chart file
    for (final key in ['women', 'men']) {
      if (chartData.containsKey(key) && !genders.contains(key)) {
        errors.add('chart file has "$key" but brands.json genders does not include it');
      }
    }

    // Validate each gender section
    for (final gender in genders) {
      if (!chartData.containsKey(gender)) continue;
      final genderSection = chartData[gender] as Map<String, dynamic>;
      final sizeCharts = genderSection['size_charts'] as List<dynamic>;

      for (final chart in sizeCharts) {
        final chartMap = chart as Map<String, dynamic>;
        final chartId = chartMap['chart_id'] as String;
        final prefix = '$gender/$chartId';

        // Validate applicable_categories not empty
        final appCats = chartMap['applicable_categories'] as List<dynamic>;
        if (appCats.isEmpty) {
          errors.add('$prefix: applicable_categories is empty');
        }

        // Validate measurements header
        final measurements = (chartMap['measurements'] as List<dynamic>).cast<String>();
        if (measurements.isEmpty) {
          errors.add('$prefix: measurements array is empty');
        }

        final sizes = chartMap['sizes'] as List<dynamic>;

        // Check no duplicate labels
        final labels = <String>[];
        for (final s in sizes) {
          final label = (s as Map<String, dynamic>)['label'] as String;
          if (labels.contains(label)) {
            errors.add('$prefix: duplicate label "$label"');
          }
          labels.add(label);
        }

        // Check order is sequential starting from 1
        for (int i = 0; i < sizes.length; i++) {
          final sizeMap = sizes[i] as Map<String, dynamic>;
          final order = sizeMap['order'] as int;
          if (order != i + 1) {
            errors.add('$prefix: size at index $i has order=$order, expected ${i + 1}');
          }
        }

        // Check each size entry
        for (final sizeEntry in sizes) {
          final sizeMap = sizeEntry as Map<String, dynamic>;
          final label = sizeMap['label'] as String;

          // eu array not empty
          final eu = sizeMap['eu'] as List<dynamic>;
          if (eu.isEmpty) {
            errors.add('$prefix: size "$label" has empty eu array');
          }

          // measurements keys match values keys
          final values = sizeMap['values'] as Map<String, dynamic>;
          for (final m in measurements) {
            if (!values.containsKey(m)) {
              errors.add('$prefix: size "$label" missing measurement "$m" in values');
            }
          }
          for (final key in values.keys) {
            if (!measurements.contains(key)) {
              errors.add('$prefix: size "$label" has extra key "$key" in values not in measurements header');
            }
          }

          // Range checks
          if (values.containsKey('bust')) {
            final min = (values['bust']['min'] as num).toDouble();
            final max = (values['bust']['max'] as num).toDouble();
            if (min < 70 || max > 140) {
              errors.add('$prefix: size "$label" bust out of range [70,140]: min=$min max=$max');
            }
          }
          if (values.containsKey('chest')) {
            final min = (values['chest']['min'] as num).toDouble();
            final max = (values['chest']['max'] as num).toDouble();
            if (min < 70 || max > 140) {
              errors.add('$prefix: size "$label" chest out of range [70,140]: min=$min max=$max');
            }
          }
          if (values.containsKey('waist')) {
            final min = (values['waist']['min'] as num).toDouble();
            final max = (values['waist']['max'] as num).toDouble();
            if (min < 55 || max > 120) {
              errors.add('$prefix: size "$label" waist out of range [55,120]: min=$min max=$max');
            }
          }
          if (values.containsKey('hips')) {
            final min = (values['hips']['min'] as num).toDouble();
            final max = (values['hips']['max'] as num).toDouble();
            if (min < 75 || max > 150) {
              errors.add('$prefix: size "$label" hips out of range [75,150]: min=$min max=$max');
            }
          }
          if (values.containsKey('foot_length')) {
            final min = (values['foot_length']['min'] as num).toDouble();
            final max = (values['foot_length']['max'] as num).toDouble();
            if (min < 20 || max > 32) {
              errors.add('$prefix: size "$label" foot_length out of range [20,32]: min=$min max=$max');
            }
          }
        }

        // Check monotonic increase per measurement
        for (final m in measurements) {
          double prevMax = -1;
          for (final sizeEntry in sizes) {
            final sizeMap = sizeEntry as Map<String, dynamic>;
            final label = sizeMap['label'] as String;
            final values = sizeMap['values'] as Map<String, dynamic>;
            if (!values.containsKey(m)) continue;
            final min = (values[m]['min'] as num).toDouble();
            final max = (values[m]['max'] as num).toDouble();
            if (prevMax >= 0 && min <= prevMax - 2) {
              errors.add('$prefix: measurement "$m" not monotonically increasing at size "$label" (min=$min, prev max=$prevMax)');
            }
            prevMax = max;
          }
        }
      }
    }

    if (errors.isEmpty) {
      print('✓ $name');
      passCount++;
    } else {
      for (final e in errors) {
        print('✗ $name: $e');
      }
      failCount++;
    }
  }

  print('');
  print('Summary: $passCount passed, $failCount failed out of ${brands.length} brands.');

  if (failCount > 0) {
    exit(1);
  }
  exit(0);
}
