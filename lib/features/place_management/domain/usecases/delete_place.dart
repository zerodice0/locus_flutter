import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class DeletePlace {
  final PlaceRepository _repository;

  DeletePlace(this._repository);

  Future<void> call(String placeId) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    // Check if place exists
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    // Delete the place (this will cascade delete related data)
    await _repository.deletePlace(placeId);
  }
}

class SoftDeletePlace {
  final PlaceRepository _repository;

  SoftDeletePlace(this._repository);

  Future<void> call(String placeId) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    // Mark place as inactive instead of deleting
    final updatedPlace = place.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
    
    await _repository.updatePlace(updatedPlace);
  }
}

class RestorePlace {
  final PlaceRepository _repository;

  RestorePlace(this._repository);

  Future<void> call(String placeId) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    // Restore place by marking it as active
    final updatedPlace = place.copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
    
    await _repository.updatePlace(updatedPlace);
  }
}

class DeleteMultiplePlaces {
  final PlaceRepository _repository;

  DeleteMultiplePlaces(this._repository);

  Future<void> call(List<String> placeIds) async {
    if (placeIds.isEmpty) {
      throw ArgumentError('Place IDs list cannot be empty');
    }
    
    for (final placeId in placeIds) {
      if (placeId.trim().isEmpty) {
        throw ArgumentError('Place ID cannot be empty');
      }
    }
    
    // Use batch delete for better performance
    try {
      await _repository.deletePlaces(placeIds);
    } catch (e) {
      // Fallback to individual deletion if batch fails
      for (final placeId in placeIds) {
        try {
          await _repository.deletePlace(placeId);
        } catch (individualError) {
          // Continue deleting other places even if one fails
          continue;
        }
      }
    }
  }
}

class PlaceNotFoundException implements Exception {
  final String message;
  
  PlaceNotFoundException(this.message);
  
  @override
  String toString() => 'PlaceNotFoundException: $message';
}