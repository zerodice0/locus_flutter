import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';

abstract class PlaceRepository {
  // Place CRUD operations
  Future<String> addPlace(Place place);
  Future<Place?> getPlace(String id);
  Future<List<Place>> getAllPlaces();
  Future<List<Place>> getPlacesByCategory(String categoryId);
  Future<List<Place>> getActivePlaces();
  Future<List<Place>> getPlacesNearby(double latitude, double longitude, double radiusKm);
  Future<void> updatePlace(Place place);
  Future<void> deletePlace(String id);
  Future<void> incrementVisitCount(String placeId);
  
  // Category operations
  Future<String> addCategory(Category category);
  Future<Category?> getCategory(String id);
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getDefaultCategories();
  Future<List<Category>> getUserCategories();
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<bool> isCategoryNameExists(String name, {String? excludeId});
  
  // Operating hours operations
  Future<void> saveOperatingHours(String placeId, List<OperatingHours> operatingHours);
  Future<List<OperatingHours>> getOperatingHours(String placeId);
  Future<void> deleteOperatingHours(String placeId);
  
  // Event periods operations
  Future<void> saveEventPeriods(String placeId, List<EventPeriod> eventPeriods);
  Future<List<EventPeriod>> getEventPeriods(String placeId);
  Future<List<EventPeriod>> getActiveEventPeriods(String placeId);
  Future<void> deleteEventPeriods(String placeId);
  
  // Complex operations
  Future<Place?> getPlaceWithDetails(String id);
  Future<List<Place>> getPlacesWithDetails();
  Future<List<Place>> searchPlaces(String query);
  Future<List<Place>> detectDuplicatePlaces(double latitude, double longitude, {double radiusMeters = 100});
}