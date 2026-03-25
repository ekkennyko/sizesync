import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/datasources/hive_data_source.dart';
import 'package:sizesync/data/datasources/purchase_service.dart';
import 'package:sizesync/data/models/conversion_record.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/domain/repositories/user_repository.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier(this._repository) : super(null) {
    _load();
  }

  final UserRepository _repository;

  bool get hasProfile => state != null && (state!.bustCm != null || state!.chestCm != null || state!.waistCm != null);

  Future<void> _load() async {
    state = await _repository.getProfile();
  }

  Future<void> save(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }
}

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._repository) : super({}) {
    _load();
  }

  final UserRepository _repository;

  Future<void> _load() async {
    state = (await _repository.getFavoriteBrandSlugs()).toSet();
  }

  Future<void> toggle(String brandSlug) async {
    await _repository.toggleFavorite(brandSlug);
    final updated = Set<String>.from(state);
    if (updated.contains(brandSlug)) {
      updated.remove(brandSlug);
    } else {
      updated.add(brandSlug);
    }
    state = updated;
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
    final updated = [record, ...state];
    state = updated.length > 50 ? updated.sublist(0, 50) : updated;
  }

  Future<void> clear() async {
    await _repository.clearHistory();
    state = [];
  }
}

class PurchaseNotifier extends StateNotifier<bool> {
  PurchaseNotifier(this._service, this._hive) : super(false) {
    _init();
  }

  final PurchaseService _service;
  final HiveDataSource _hive;
  StreamSubscription<bool>? _sub;

  Future<void> _init() async {
    final cached = _hive.readIsPremium();
    _service.seedCachedStatus(value: cached);
    state = _service.isPremium;

    _sub = _service.isPremiumStream.listen((value) {
      _hive.writeIsPremium(value: value);
      state = _service.isPremium;
    });

    await _service.init();
  }

  Future<bool> buyPremium() => _service.buyPremium();
  Future<bool> restorePurchases() => _service.restorePurchases();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
