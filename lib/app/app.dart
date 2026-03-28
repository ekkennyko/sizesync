import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizesync/app/theme.dart';
import 'package:sizesync/shared/providers/providers.dart';

class SizeSyncApp extends ConsumerWidget {
  const SizeSyncApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(title: 'SizeSync', theme: lightTheme, darkTheme: darkTheme, themeMode: themeMode, routerConfig: router);
  }
}
