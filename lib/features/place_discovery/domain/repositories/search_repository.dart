import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/swipe_action.dart';

abstract class SearchRepository {
  Future<List<PlaceWithDistance>> searchNearbyPlaces({
    required double currentLat,
    required double currentLng,
    required SearchSettings settings,
  });

  Future<void> recordSwipeAction(SwipeAction action);

  Future<List<SwipeAction>> getSwipeHistory({
    String? sessionId,
    DateTime? since,
  });

  Future<SearchSettings> getSearchSettings();

  Future<void> saveSearchSettings(SearchSettings settings);

  Future<void> clearSwipeHistory();
}