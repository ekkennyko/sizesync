import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';

class LocalUserRepository implements UserRepository {
  LocalUserRepository(this._dataSource);

  final HiveDataSource _dataSource;

  @override
  Future<UserProfile?> getProfile() async {
    final data = _dataSource.readProfile();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Future<void> saveProfile(UserProfile profile) => _dataSource.writeProfile(profile.toJson());

  @override
  Future<List<String>> getFavoriteBrandSlugs() async => _dataSource.readFavorites();

  @override
  Future<void> toggleFavorite(String brandSlug) async {
    final favorites = _dataSource.readFavorites();
    if (favorites.contains(brandSlug)) {
      favorites.remove(brandSlug);
    } else {
      favorites.add(brandSlug);
    }
    await _dataSource.writeFavorites(favorites);
  }

  @override
  Future<List<ConversionRecord>> getHistory() async {
    final data = _dataSource.readHistory();
    return data.map(ConversionRecord.fromJson).toList();
  }

  @override
  Future<void> addToHistory(ConversionRecord record) async {
    final history = _dataSource.readHistory();
    history.insert(0, record.toJson());
    await _dataSource.writeHistory(history);
  }

  @override
  Future<void> clearHistory() => _dataSource.writeHistory([]);
}
