import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class UpdatePlace {
  final PlaceRepository _repository;

  UpdatePlace(this._repository);

  Future<void> call(Place place) async {
    // Validate place data
    if (place.id.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    if (place.name.trim().isEmpty) {
      throw ArgumentError('Place name cannot be empty');
    }
    
    if (place.categoryId.trim().isEmpty) {
      throw ArgumentError('Category must be selected');
    }
    
    // Check if place exists
    final existingPlace = await _repository.getPlace(place.id);
    if (existingPlace == null) {
      throw PlaceNotFoundException('Place with ID ${place.id} not found');
    }
    
    // Update place with current timestamp
    final updatedPlace = place.copyWith(
      updatedAt: DateTime.now(),
    );
    
    await _repository.updatePlace(updatedPlace);
    
    // Update operating hours if provided
    if (place.operatingHours != null) {
      await _repository.saveOperatingHours(place.id, place.operatingHours!);
    }
    
    // Update event periods if provided
    if (place.eventPeriods != null) {
      await _repository.saveEventPeriods(place.id, place.eventPeriods!);
    }
  }
}

class UpdatePlaceRating {
  final PlaceRepository _repository;

  UpdatePlaceRating(this._repository);

  Future<void> call(String placeId, double rating) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }
    
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    final updatedPlace = place.updateRating(rating);
    await _repository.updatePlace(updatedPlace);
  }
}

class IncrementVisitCount {
  final PlaceRepository _repository;

  IncrementVisitCount(this._repository);

  Future<void> call(String placeId) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    // Check if place exists
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    await _repository.incrementVisitCount(placeId);
  }
}

class TogglePlaceStatus {
  final PlaceRepository _repository;

  TogglePlaceStatus(this._repository);

  Future<void> call(String placeId) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    final updatedPlace = place.copyWith(
      isActive: !place.isActive,
      updatedAt: DateTime.now(),
    );
    
    await _repository.updatePlace(updatedPlace);
  }
}

class UpdateOperatingHours {
  final PlaceRepository _repository;

  UpdateOperatingHours(this._repository);

  Future<void> call(String placeId, List<OperatingHours> operatingHours) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    // Check if place exists
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    // Validate operating hours
    for (final hours in operatingHours) {
      if (hours.dayOfWeek < 0 || hours.dayOfWeek > 6) {
        throw ArgumentError('Day of week must be between 0 (Sunday) and 6 (Saturday)');
      }
      
      if (!hours.isClosed && (hours.openTime == null || hours.closeTime == null)) {
        throw ArgumentError('Open and close times must be provided for non-closed days');
      }
    }
    
    await _repository.saveOperatingHours(placeId, operatingHours);
  }
}

class UpdateEventPeriods {
  final PlaceRepository _repository;

  UpdateEventPeriods(this._repository);

  Future<void> call(String placeId, List<EventPeriod> eventPeriods) async {
    if (placeId.trim().isEmpty) {
      throw ArgumentError('Place ID cannot be empty');
    }
    
    // Check if place exists
    final place = await _repository.getPlace(placeId);
    if (place == null) {
      throw PlaceNotFoundException('Place with ID $placeId not found');
    }
    
    // Validate event periods
    for (final period in eventPeriods) {
      if (period.name.trim().isEmpty) {
        throw ArgumentError('Event period name cannot be empty');
      }
      
      if (period.endDate.isBefore(period.startDate)) {
        throw ArgumentError('Event end date must be after start date');
      }
    }
    
    await _repository.saveEventPeriods(placeId, eventPeriods);
  }
}

class PlaceNotFoundException implements Exception {
  final String message;
  
  PlaceNotFoundException(this.message);
  
  @override
  String toString() => 'PlaceNotFoundException: $message';
}