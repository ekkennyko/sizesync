import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<List<String>> getFavoriteBrandSlugs();
  Future<void> toggleFavorite(String brandSlug);
  Future<List<ConversionRecord>> getHistory();
  Future<void> addToHistory(ConversionRecord record);
  Future<void> clearHistory();
}
