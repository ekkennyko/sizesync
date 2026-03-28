import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizesync/core/constants/app_constants.dart';

class HiveDataSource {
  late final Box<dynamic> _profileBox;
  late final Box<dynamic> _favoritesBox;
  late final Box<dynamic> _historyBox;
  late final Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _profileBox = await Hive.openBox(AppConstants.hiveProfileBoxName);
    _favoritesBox = await Hive.openBox(AppConstants.hiveFavoritesBoxName);
    _historyBox = await Hive.openBox(AppConstants.hiveHistoryBoxName);
    _settingsBox = await Hive.openBox(AppConstants.hiveSettingsBoxName);
  }

  Map<String, dynamic>? readProfile() {
    final data = _profileBox.get('data');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> writeProfile(Map<String, dynamic> data) => _profileBox.put('data', data);

  List<String> readFavorites() {
    final data = _favoritesBox.get('data');
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  Future<void> writeFavorites(List<String> slugs) => _favoritesBox.put('data', slugs);

  List<Map<String, dynamic>> readHistory() {
    final data = _historyBox.get('data');
    if (data == null) return [];
    return (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> writeHistory(List<Map<String, dynamic>> records) => _historyBox.put('data', records);

  bool readOnboardingComplete() => (_settingsBox.get(AppConstants.hiveOnboardingKey) as bool?) ?? false;

  Future<void> writeOnboardingComplete() => _settingsBox.put(AppConstants.hiveOnboardingKey, true);

  bool readIsPremium() => (_settingsBox.get(AppConstants.hivePremiumKey) as bool?) ?? false;

  Future<void> writeIsPremium({required bool value}) => _settingsBox.put(AppConstants.hivePremiumKey, value);

  ThemeMode readThemeMode() {
    final index = (_settingsBox.get(AppConstants.hiveThemeModeKey) as int?) ?? 0;
    return ThemeMode.values[index.clamp(0, 2)];
  }

  Future<void> writeThemeMode(ThemeMode mode) => _settingsBox.put(AppConstants.hiveThemeModeKey, mode.index);

  String readSizeSystem() => (_settingsBox.get(AppConstants.hiveSizeSystemKey) as String?) ?? 'EU';

  Future<void> writeSizeSystem(String system) => _settingsBox.put(AppConstants.hiveSizeSystemKey, system);

  bool readUseInches() => (_settingsBox.get(AppConstants.hiveUseInchesKey) as bool?) ?? false;

  Future<void> writeUseInches({required bool value}) => _settingsBox.put(AppConstants.hiveUseInchesKey, value);

  List<String> readRecentSearches() {
    final data = _settingsBox.get(AppConstants.hiveRecentSearchesKey);
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  Future<void> writeRecentSearches(List<String> slugs) => _settingsBox.put(AppConstants.hiveRecentSearchesKey, slugs);

  Box<dynamic> get settingsBox => _settingsBox;
}
