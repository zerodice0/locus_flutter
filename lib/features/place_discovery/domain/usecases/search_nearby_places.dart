import 'package:locus_flutter/core/utils/distance_calculator.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/domain/repositories/search_repository.dart';

class SearchNearbyPlaces {
  final SearchRepository repository;

  SearchNearbyPlaces(this.repository);

  Future<List<PlaceWithDistance>> call({
    required double currentLat,
    required double currentLng,
    SearchSettings? customSettings,
  }) async {
    final SearchSettings settings = customSettings ?? await repository.getSearchSettings();
    
    List<PlaceWithDistance> results = await repository.searchNearbyPlaces(
      currentLat: currentLat,
      currentLng: currentLng,
      settings: settings,
    );

    // 적응형 반경 적용
    if (settings.adaptiveRadius && results.length < 3) {
      final double adaptiveRadius = DistanceCalculator.calculateAdaptiveRadius(
        results.length,
        settings.radiusKm,
      );
      
      if (adaptiveRadius > settings.radiusKm) {
        final SearchSettings expandedSettings = settings.copyWith(
          radiusKm: adaptiveRadius,
        );
        
        results = await repository.searchNearbyPlaces(
          currentLat: currentLat,
          currentLng: currentLng,
          settings: expandedSettings,
        );
      }
    }

    // 정렬 적용
    switch (settings.sortOrder) {
      case SearchSortOrder.distance:
        results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case SearchSortOrder.name:
        results.sort((a, b) => a.place.name.compareTo(b.place.name));
        break;
      case SearchSortOrder.category:
        results.sort((a, b) => a.place.categoryId.compareTo(b.place.categoryId));
        break;
      case SearchSortOrder.createdDate:
        results.sort((a, b) => b.place.createdAt.compareTo(a.place.createdAt));
        break;
    }

    return results;
  }
}