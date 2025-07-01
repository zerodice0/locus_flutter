import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class DetectDuplicatePlaces {
  final PlaceRepository _repository;

  DetectDuplicatePlaces(this._repository);

  Future<List<Place>> call({
    required double latitude,
    required double longitude,
    double radiusMeters = 100,
    String? excludePlaceId,
  }) async {
    if (radiusMeters <= 0) {
      throw ArgumentError('Radius must be greater than 0');
    }
    
    if (radiusMeters > 1000) {
      throw ArgumentError('Radius cannot exceed 1000 meters for duplicate detection');
    }
    
    var duplicates = await _repository.detectDuplicatePlaces(
      latitude,
      longitude,
      radiusMeters: radiusMeters,
    );
    
    // Exclude the specified place ID if provided (useful when updating a place)
    if (excludePlaceId != null && excludePlaceId.trim().isNotEmpty) {
      duplicates = duplicates.where((place) => place.id != excludePlaceId).toList();
    }
    
    // Sort by distance (closest first)
    duplicates.sort((a, b) => 
        a.distanceFrom(latitude, longitude).compareTo(b.distanceFrom(latitude, longitude)));
    
    return duplicates;
  }
}

class CheckPlaceNameSimilarity {
  final PlaceRepository _repository;

  CheckPlaceNameSimilarity(this._repository);

  Future<List<Place>> call({
    required String placeName,
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
    double similarityThreshold = 0.7,
    String? excludePlaceId,
  }) async {
    if (placeName.trim().isEmpty) {
      throw ArgumentError('Place name cannot be empty');
    }
    
    if (radiusKm <= 0) {
      throw ArgumentError('Radius must be greater than 0');
    }
    
    if (similarityThreshold < 0 || similarityThreshold > 1) {
      throw ArgumentError('Similarity threshold must be between 0 and 1');
    }
    
    // Get nearby places
    var nearbyPlaces = await _repository.getPlacesNearby(latitude, longitude, radiusKm);
    
    // Exclude the specified place ID if provided
    if (excludePlaceId != null && excludePlaceId.trim().isNotEmpty) {
      nearbyPlaces = nearbyPlaces.where((place) => place.id != excludePlaceId).toList();
    }
    
    // Filter by name similarity
    final similarPlaces = <Place>[];
    final targetName = placeName.toLowerCase().trim();
    
    for (final place in nearbyPlaces) {
      final similarity = _calculateStringSimilarity(targetName, place.name.toLowerCase().trim());
      if (similarity >= similarityThreshold) {
        similarPlaces.add(place);
      }
    }
    
    // Sort by similarity (most similar first)
    similarPlaces.sort((a, b) {
      final similarityA = _calculateStringSimilarity(targetName, a.name.toLowerCase().trim());
      final similarityB = _calculateStringSimilarity(targetName, b.name.toLowerCase().trim());
      return similarityB.compareTo(similarityA);
    });
    
    return similarPlaces;
  }

  double _calculateStringSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;
    
    // Simple Levenshtein distance based similarity
    final distance = _levenshteinDistance(str1, str2);
    final maxLength = str1.length > str2.length ? str1.length : str2.length;
    
    return 1.0 - (distance / maxLength);
  }

  int _levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (i) => List.generate(str2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[str1.length][str2.length];
  }
}

class ValidateNewPlace {
  final DetectDuplicatePlaces _detectDuplicates;
  final CheckPlaceNameSimilarity _checkSimilarity;

  ValidateNewPlace(this._detectDuplicates, this._checkSimilarity);

  Future<PlaceValidationResult> call({
    required String placeName,
    required double latitude,
    required double longitude,
    String? excludePlaceId,
  }) async {
    final warnings = <String>[];
    final errors = <String>[];
    
    // Check for duplicate locations (within 50 meters)
    final duplicates = await _detectDuplicates.call(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: 50,
      excludePlaceId: excludePlaceId,
    );
    
    if (duplicates.isNotEmpty) {
      errors.add('There is already a place within 50 meters of this location');
    }
    
    // Check for similar names (within 1 km)
    final similarPlaces = await _checkSimilarity.call(
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      radiusKm: 1.0,
      similarityThreshold: 0.8,
      excludePlaceId: excludePlaceId,
    );
    
    if (similarPlaces.isNotEmpty) {
      warnings.add('There are places with similar names nearby');
    }
    
    return PlaceValidationResult(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
      duplicatePlaces: duplicates,
      similarPlaces: similarPlaces,
    );
  }
}

class PlaceValidationResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;
  final List<Place> duplicatePlaces;
  final List<Place> similarPlaces;

  PlaceValidationResult({
    required this.isValid,
    required this.warnings,
    required this.errors,
    required this.duplicatePlaces,
    required this.similarPlaces,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
  bool get hasDuplicates => duplicatePlaces.isNotEmpty;
  bool get hasSimilarPlaces => similarPlaces.isNotEmpty;
}