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

  Box<dynamic> get profileBox => _profileBox;
  Box<dynamic> get favoritesBox => _favoritesBox;
  Box<dynamic> get historyBox => _historyBox;
  Box<dynamic> get settingsBox => _settingsBox;
}
