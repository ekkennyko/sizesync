import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/app/app.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/shared/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hive = HiveDataSource();
  await hive.init();

  runApp(ProviderScope(overrides: [hiveDataSourceProvider.overrideWithValue(hive)], child: const SizeSyncApp()));
}
