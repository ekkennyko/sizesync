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

  Box<dynamic> get settingsBox => _settingsBox;
}
