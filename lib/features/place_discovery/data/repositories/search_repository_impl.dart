import 'package:locus_flutter/features/place_discovery/data/datasources/search_local_datasource.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/swipe_action.dart';
import 'package:locus_flutter/features/place_discovery/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<PlaceWithDistance>> searchNearbyPlaces({
    required double currentLat,
    required double currentLng,
    required SearchSettings settings,
  }) async {
    return await localDataSource.searchNearbyPlaces(
      currentLat: currentLat,
      currentLng: currentLng,
      settings: settings,
    );
  }

  @override
  Future<void> recordSwipeAction(SwipeAction action) async {
    await localDataSource.recordSwipeAction(action);
  }

  @override
  Future<List<SwipeAction>> getSwipeHistory({
    String? sessionId,
    DateTime? since,
  }) async {
    return await localDataSource.getSwipeHistory(
      sessionId: sessionId,
      since: since,
    );
  }

  @override
  Future<SearchSettings> getSearchSettings() async {
    return await localDataSource.getSearchSettings();
  }

  @override
  Future<void> saveSearchSettings(SearchSettings settings) async {
    await localDataSource.saveSearchSettings(settings);
  }

  @override
  Future<void> clearSwipeHistory() async {
    await localDataSource.clearSwipeHistory();
  }
}