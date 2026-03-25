import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier(this._repository) : super(null) {
    _load();
  }

  final UserRepository _repository;

  bool get hasProfile => state != null && (state!.bustCm != null || state!.waistCm != null);

  Future<void> _load() async {
    state = await _repository.getProfile();
  }

  Future<void> save(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }
}

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier(this._repository) : super([]) {
    _load();
  }

  final UserRepository _repository;

  Future<void> _load() async {
    state = await _repository.getFavoriteBrandSlugs();
  }

  Future<void> toggle(String brandSlug) async {
    await _repository.toggleFavorite(brandSlug);
    state = await _repository.getFavoriteBrandSlugs();
  }
}

class HistoryNotifier extends StateNotifier<List<ConversionRecord>> {
  HistoryNotifier(this._repository) : super([]) {
    _load();
  }

  final UserRepository _repository;

  Future<void> _load() async {
    state = await _repository.getHistory();
  }

  Future<void> add(ConversionRecord record) async {
    await _repository.addToHistory(record);
    state = [record, ...state];
  }

  Future<void> clear() async {
    await _repository.clearHistory();
    state = [];
  }
}
