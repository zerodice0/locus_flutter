import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:locus_flutter/core/database/database_helper.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';
import 'package:locus_flutter/features/place_management/data/repositories/place_repository_impl.dart';
import 'package:locus_flutter/features/place_management/data/datasources/place_local_datasource.dart';
import 'package:locus_flutter/features/place_management/data/datasources/category_local_datasource.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/add_place.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/get_places.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/update_place.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/delete_place.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/detect_duplicate_places.dart';

// Core dependencies
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

// DataSource providers
final placeLocalDataSourceProvider = Provider<PlaceLocalDataSource>((ref) {
  final databaseHelper = ref.read(databaseHelperProvider);
  final uuid = ref.read(uuidProvider);
  return PlaceLocalDataSourceImpl(
    databaseHelper: databaseHelper,
    uuid: uuid,
  );
});

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final databaseHelper = ref.read(databaseHelperProvider);
  final uuid = ref.read(uuidProvider);
  return CategoryLocalDataSourceImpl(
    databaseHelper: databaseHelper,
    uuid: uuid,
  );
});

// Repository provider
final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  final placeDataSource = ref.read(placeLocalDataSourceProvider);
  final categoryDataSource = ref.read(categoryLocalDataSourceProvider);
  final uuid = ref.read(uuidProvider);
  return PlaceRepositoryImpl(
    placeDataSource: placeDataSource,
    categoryDataSource: categoryDataSource,
    uuid: uuid,
  );
});

// UseCase providers
final addPlaceUseCaseProvider = Provider<AddPlace>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return AddPlace(repository);
});

final getPlacesUseCaseProvider = Provider<GetPlaces>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlaces(repository);
});

final getPlacesWithDetailsUseCaseProvider = Provider<GetPlacesWithDetails>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlacesWithDetails(repository);
});

final getPlacesByCategoryUseCaseProvider = Provider<GetPlacesByCategory>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlacesByCategory(repository);
});

final getPlacesNearbyUseCaseProvider = Provider<GetPlacesNearby>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlacesNearby(repository);
});

final getPlaceUseCaseProvider = Provider<GetPlace>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlace(repository);
});

final getPlaceWithDetailsUseCaseProvider = Provider<GetPlaceWithDetails>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetPlaceWithDetails(repository);
});

final searchPlacesUseCaseProvider = Provider<SearchPlaces>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return SearchPlaces(repository);
});

final updatePlaceUseCaseProvider = Provider<UpdatePlace>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return UpdatePlace(repository);
});

final updatePlaceRatingUseCaseProvider = Provider<UpdatePlaceRating>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return UpdatePlaceRating(repository);
});

final incrementVisitCountUseCaseProvider = Provider<IncrementVisitCount>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return IncrementVisitCount(repository);
});

final deletePlaceUseCaseProvider = Provider<DeletePlace>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return DeletePlace(repository);
});

final detectDuplicatePlacesUseCaseProvider = Provider<DetectDuplicatePlaces>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return DetectDuplicatePlaces(repository);
});

final checkPlaceNameSimilarityUseCaseProvider = Provider<CheckPlaceNameSimilarity>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return CheckPlaceNameSimilarity(repository);
});

final validateNewPlaceUseCaseProvider = Provider<ValidateNewPlace>((ref) {
  final detectDuplicates = ref.read(detectDuplicatePlacesUseCaseProvider);
  final checkSimilarity = ref.read(checkPlaceNameSimilarityUseCaseProvider);
  return ValidateNewPlace(detectDuplicates, checkSimilarity);
});

// State management providers
final placesProvider = StateNotifierProvider<PlacesNotifier, AsyncValue<List<Place>>>((ref) {
  final getPlacesUseCase = ref.read(getPlacesUseCaseProvider);
  final getPlacesWithDetailsUseCase = ref.read(getPlacesWithDetailsUseCaseProvider);
  return PlacesNotifier(getPlacesUseCase, getPlacesWithDetailsUseCase);
});

final selectedPlaceProvider = StateProvider<Place?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Place>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final searchUseCase = ref.read(searchPlacesUseCaseProvider);
  return await searchUseCase(query);
});

// Places state notifier
class PlacesNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final GetPlaces _getPlaces;
  final GetPlacesWithDetails _getPlacesWithDetails;

  PlacesNotifier(this._getPlaces, this._getPlacesWithDetails) : super(const AsyncValue.loading()) {
    loadPlaces();
  }

  Future<void> loadPlaces({bool withDetails = false}) async {
    try {
      state = const AsyncValue.loading();
      final places = withDetails 
          ? await _getPlacesWithDetails()
          : await _getPlaces();
      state = AsyncValue.data(places);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPlaces({bool withDetails = false}) async {
    await loadPlaces(withDetails: withDetails);
  }

  void addPlace(Place place) {
    state.whenData((places) {
      state = AsyncValue.data([place, ...places]);
    });
  }

  void updatePlace(Place updatedPlace) {
    state.whenData((places) {
      final updatedPlaces = places.map((place) {
        return place.id == updatedPlace.id ? updatedPlace : place;
      }).toList();
      state = AsyncValue.data(updatedPlaces);
    });
  }

  void removePlace(String placeId) {
    state.whenData((places) {
      final updatedPlaces = places.where((place) => place.id != placeId).toList();
      state = AsyncValue.data(updatedPlaces);
    });
  }

  List<Place> get places {
    return state.maybeWhen(
      data: (places) => places,
      orElse: () => [],
    );
  }

  int get placesCount {
    return places.length;
  }

  bool get isLoading {
    return state.isLoading;
  }

  bool get hasError {
    return state.hasError;
  }

  String? get errorMessage {
    return state.maybeWhen(
      error: (error, _) => error.toString(),
      orElse: () => null,
    );
  }
}

// Nearby places provider
final nearbyPlacesProvider = StateNotifierProvider.family<NearbyPlacesNotifier, AsyncValue<List<Place>>, NearbyPlacesParams>((ref, params) {
  final getNearbyUseCase = ref.read(getPlacesNearbyUseCaseProvider);
  return NearbyPlacesNotifier(getNearbyUseCase, params);
});

class NearbyPlacesParams {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? categoryId;
  final bool includeInactive;

  const NearbyPlacesParams({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.categoryId,
    this.includeInactive = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyPlacesParams &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          categoryId == other.categoryId &&
          includeInactive == other.includeInactive;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      radiusKm.hashCode ^
      categoryId.hashCode ^
      includeInactive.hashCode;
}

class NearbyPlacesNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final GetPlacesNearby _getPlacesNearby;
  final NearbyPlacesParams _params;

  NearbyPlacesNotifier(this._getPlacesNearby, this._params) : super(const AsyncValue.loading()) {
    loadNearbyPlaces();
  }

  Future<void> loadNearbyPlaces() async {
    try {
      state = const AsyncValue.loading();
      final places = await _getPlacesNearby(
        latitude: _params.latitude,
        longitude: _params.longitude,
        radiusKm: _params.radiusKm,
        categoryId: _params.categoryId,
        includeInactive: _params.includeInactive,
      );
      state = AsyncValue.data(places);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshNearbyPlaces() async {
    await loadNearbyPlaces();
  }

  List<Place> get nearbyPlaces {
    return state.maybeWhen(
      data: (places) => places,
      orElse: () => [],
    );
  }
}