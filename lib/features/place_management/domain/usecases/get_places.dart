import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class GetPlaces {
  final PlaceRepository _repository;

  GetPlaces(this._repository);

  Future<List<Place>> call() async {
    return await _repository.getActivePlaces();
  }
}

class GetPlacesWithDetails {
  final PlaceRepository _repository;

  GetPlacesWithDetails(this._repository);

  Future<List<Place>> call() async {
    return await _repository.getPlacesWithDetails();
  }
}

class GetPlacesByCategory {
  final PlaceRepository _repository;

  GetPlacesByCategory(this._repository);

  Future<List<Place>> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    
    return await _repository.getPlacesByCategory(categoryId);
  }
}

class GetPlacesNearby {
  final PlaceRepository _repository;

  GetPlacesNearby(this._repository);

  Future<List<Place>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? categoryId,
    bool includeInactive = false,
  }) async {
    if (radiusKm <= 0) {
      throw ArgumentError('Radius must be greater than 0');
    }
    
    if (radiusKm > 100) {
      throw ArgumentError('Radius cannot exceed 100 km');
    }
    
    var places = await _repository.getPlacesNearby(latitude, longitude, radiusKm);
    
    // Filter by category if specified
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      places = places.where((place) => place.categoryId == categoryId).toList();
    }
    
    // Filter by active status if needed
    if (!includeInactive) {
      places = places.where((place) => place.isActive).toList();
    }
    
    return places;
  }
}

class GetPlace {
  final PlaceRepository _repository;

  GetPlace(this._repository);

  Future<Place?> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    return await _repository.getPlace(id);
  }
}

class GetPlaceWithDetails {
  final PlaceRepository _repository;

  GetPlaceWithDetails(this._repository);

  Future<Place?> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    return await _repository.getPlaceWithDetails(id);
  }
}

class SearchPlaces {
  final PlaceRepository _repository;

  SearchPlaces(this._repository);

  Future<List<Place>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    if (query.trim().length < 2) {
      throw ArgumentError('Search query must be at least 2 characters long');
    }
    
    return await _repository.searchPlaces(query.trim());
  }
}