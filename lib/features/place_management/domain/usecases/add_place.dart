import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class AddPlace {
  final PlaceRepository _repository;

  AddPlace(this._repository);

  Future<String> call(Place place) async {
    // Validate place data
    if (place.name.trim().isEmpty) {
      throw ArgumentError('Place name cannot be empty');
    }
    
    if (place.categoryId.trim().isEmpty) {
      throw ArgumentError('Category must be selected');
    }
    
    // Check for duplicate places nearby (within 50 meters)
    final duplicates = await _repository.detectDuplicatePlaces(
      place.latitude,
      place.longitude,
      radiusMeters: 50,
    );
    
    if (duplicates.isNotEmpty) {
      throw DuplicatePlaceException(
        'Similar place already exists nearby',
        duplicates,
      );
    }
    
    // Create place with timestamps
    final now = DateTime.now();
    final placeToAdd = place.copyWith(
      createdAt: now,
      updatedAt: now,
      isActive: true,
      visitCount: 0,
    );
    
    return await _repository.addPlace(placeToAdd);
  }
}

class DuplicatePlaceException implements Exception {
  final String message;
  final List<Place> duplicatePlaces;
  
  DuplicatePlaceException(this.message, this.duplicatePlaces);
  
  @override
  String toString() => 'DuplicatePlaceException: $message';
}