import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/app/app.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hive = HiveDataSource();
  await hive.init();

  runApp(const ProviderScope(child: SizeSyncApp()));
}
