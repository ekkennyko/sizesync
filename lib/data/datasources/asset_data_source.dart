import 'dart:convert';

import 'package:flutter/services.dart';

class AssetDataSource {
  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<List<dynamic>> loadJsonList(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return json.decode(raw) as List<dynamic>;
  }
}
