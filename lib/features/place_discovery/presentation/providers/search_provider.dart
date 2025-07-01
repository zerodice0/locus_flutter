import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/core/database/database_helper.dart';
import 'package:locus_flutter/features/place_discovery/data/datasources/search_local_datasource.dart';
import 'package:locus_flutter/features/place_discovery/data/repositories/search_repository_impl.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/domain/repositories/search_repository.dart';
import 'package:locus_flutter/features/place_discovery/domain/usecases/calculate_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/usecases/record_swipe_action.dart';
import 'package:locus_flutter/features/place_discovery/domain/usecases/search_nearby_places.dart';

// Providers
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final databaseHelper = DatabaseHelper();
  final calculateDistance = CalculateDistance();
  
  final localDataSource = SearchLocalDataSource(
    databaseHelper: databaseHelper,
    calculateDistance: calculateDistance,
  );
  
  return SearchRepositoryImpl(localDataSource: localDataSource);
});

final searchNearbyPlacesProvider = Provider<SearchNearbyPlaces>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNearbyPlaces(repository);
});

final recordSwipeActionProvider = Provider<RecordSwipeAction>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return RecordSwipeAction(repository);
});

final calculateDistanceProvider = Provider<CalculateDistance>((ref) {
  return CalculateDistance();
});

// State providers
final searchSettingsProvider = StateNotifierProvider<SearchSettingsNotifier, SearchSettings>(
  (ref) => SearchSettingsNotifier(ref.watch(searchRepositoryProvider)),
);

final nearbyPlacesProvider = StateNotifierProvider<NearbyPlacesNotifier, AsyncValue<List<PlaceWithDistance>>>(
  (ref) => NearbyPlacesNotifier(
    ref.watch(searchNearbyPlacesProvider),
    ref.watch(searchSettingsProvider.notifier),
  ),
);

// State notifiers
class SearchSettingsNotifier extends StateNotifier<SearchSettings> {
  final SearchRepository _repository;

  SearchSettingsNotifier(this._repository) : super(const SearchSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSearchSettings();
      state = settings;
    } catch (e) {
      // Keep default settings if loading fails
    }
  }

  Future<void> updateSettings(SearchSettings newSettings) async {
    try {
      await _repository.saveSearchSettings(newSettings);
      state = newSettings;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  void updateRadius(double radius) {
    final newSettings = state.copyWith(radiusKm: radius);
    updateSettings(newSettings);
  }

  void updateCategoryFilter(List<String> categoryIds) {
    final newSettings = state.copyWith(categoryIds: categoryIds);
    updateSettings(newSettings);
  }

  void updateOperatingHoursFilter(bool considerOperatingHours) {
    final newSettings = state.copyWith(considerOperatingHours: considerOperatingHours);
    updateSettings(newSettings);
  }

  void updateEventPeriodFilter(bool considerEventPeriod) {
    final newSettings = state.copyWith(considerEventPeriod: considerEventPeriod);
    updateSettings(newSettings);
  }

  void updateSortOrder(SearchSortOrder sortOrder) {
    final newSettings = state.copyWith(sortOrder: sortOrder);
    updateSettings(newSettings);
  }

  void updateAdaptiveRadius(bool adaptiveRadius) {
    final newSettings = state.copyWith(adaptiveRadius: adaptiveRadius);
    updateSettings(newSettings);
  }

  void resetToDefaults() {
    updateSettings(const SearchSettings());
  }
}

class NearbyPlacesNotifier extends StateNotifier<AsyncValue<List<PlaceWithDistance>>> {
  final SearchNearbyPlaces _searchNearbyPlaces;
  final SearchSettingsNotifier _settingsNotifier;

  NearbyPlacesNotifier(this._searchNearbyPlaces, this._settingsNotifier) 
      : super(const AsyncValue.data([]));

  Future<void> searchPlaces({
    required double currentLat,
    required double currentLng,
    SearchSettings? customSettings,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final places = await _searchNearbyPlaces.call(
        currentLat: currentLat,
        currentLng: currentLng,
        customSettings: customSettings,
      );
      
      state = AsyncValue.data(places);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearResults() {
    state = const AsyncValue.data([]);
  }

  Future<void> refreshWithCurrentSettings({
    required double currentLat,
    required double currentLng,
  }) async {
    await searchPlaces(
      currentLat: currentLat,
      currentLng: currentLng,
      customSettings: _settingsNotifier.state,
    );
  }
}