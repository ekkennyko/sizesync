import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF2E7D32);

final lightTheme = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor));

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor, brightness: Brightness.dark),
);
