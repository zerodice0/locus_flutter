import 'package:uuid/uuid.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/features/place_management/data/datasources/place_local_datasource.dart';
import 'package:locus_flutter/features/place_management/data/datasources/category_local_datasource.dart';
import 'package:locus_flutter/features/place_management/data/models/place_model.dart';
import 'package:locus_flutter/features/place_management/data/models/category_model.dart';
import 'package:locus_flutter/features/place_management/data/models/operating_hours_model.dart';
import 'package:locus_flutter/features/place_management/data/models/event_period_model.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceLocalDataSource _placeDataSource;
  final CategoryLocalDataSource _categoryDataSource;
  final Uuid _uuid;

  PlaceRepositoryImpl({
    required PlaceLocalDataSource placeDataSource,
    required CategoryLocalDataSource categoryDataSource,
    Uuid? uuid,
  }) : _placeDataSource = placeDataSource,
       _categoryDataSource = categoryDataSource,
       _uuid = uuid ?? const Uuid();

  // Place CRUD operations
  @override
  Future<String> addPlace(Place place) async {
    final placeId = place.id.isEmpty ? 'place_${_uuid.v4()}' : place.id;
    final placeWithId = place.copyWith(id: placeId);
    final placeModel = PlaceModel.fromEntity(placeWithId);
    
    await _placeDataSource.insertPlace(placeModel);
    
    // Save operating hours if provided
    if (place.operatingHours != null && place.operatingHours!.isNotEmpty) {
      await saveOperatingHours(placeId, place.operatingHours!);
    }
    
    // Save event periods if provided
    if (place.eventPeriods != null && place.eventPeriods!.isNotEmpty) {
      await saveEventPeriods(placeId, place.eventPeriods!);
    }
    
    return placeId;
  }

  @override
  Future<Place?> getPlace(String id) async {
    final placeModel = await _placeDataSource.getPlace(id);
    if (placeModel == null) return null;
    
    return placeModel.toEntity();
  }

  @override
  Future<List<Place>> getAllPlaces() async {
    final placeModels = await _placeDataSource.getAllPlaces();
    return placeModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Place>> getPlacesByCategory(String categoryId) async {
    final placeModels = await _placeDataSource.getPlacesByCategory(categoryId);
    return placeModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Place>> getActivePlaces() async {
    final placeModels = await _placeDataSource.getActivePlaces();
    return placeModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Place>> getPlacesNearby(double latitude, double longitude, double radiusKm) async {
    final placeModels = await _placeDataSource.getPlacesNearby(latitude, longitude, radiusKm);
    
    // Filter by actual distance using Haversine formula
    final nearbyPlaces = <Place>[];
    for (final model in placeModels) {
      final place = model.toEntity();
      final distance = place.distanceFrom(latitude, longitude);
      if (distance <= radiusKm) {
        nearbyPlaces.add(place);
      }
    }
    
    // Sort by distance
    nearbyPlaces.sort((a, b) => 
        a.distanceFrom(latitude, longitude).compareTo(b.distanceFrom(latitude, longitude)));
    
    return nearbyPlaces;
  }

  @override
  Future<void> updatePlace(Place place) async {
    final placeModel = PlaceModel.fromEntity(place);
    await _placeDataSource.updatePlace(placeModel);
  }

  @override
  Future<void> deletePlace(String id) async {
    // Delete related data first (cascade delete handled by database)
    await _placeDataSource.deleteOperatingHours(id);
    await _placeDataSource.deleteEventPeriods(id);
    await _placeDataSource.deletePlace(id);
  }

  @override
  Future<void> incrementVisitCount(String placeId) async {
    await _placeDataSource.incrementVisitCount(placeId);
  }

  // Category operations
  @override
  Future<String> addCategory(Category category) async {
    final categoryId = category.id.isEmpty ? 'cat_${_uuid.v4()}' : category.id;
    final categoryWithId = category.copyWith(id: categoryId);
    final categoryModel = CategoryModel.fromEntity(categoryWithId);
    
    return await _categoryDataSource.insertCategory(categoryModel);
  }

  @override
  Future<Category?> getCategory(String id) async {
    final categoryModel = await _categoryDataSource.getCategory(id);
    if (categoryModel == null) return null;
    
    return categoryModel.toEntity();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final categoryModels = await _categoryDataSource.getAllCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getDefaultCategories() async {
    final categoryModels = await _categoryDataSource.getDefaultCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getUserCategories() async {
    final categoryModels = await _categoryDataSource.getUserCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await _categoryDataSource.updateCategory(categoryModel);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoryDataSource.deleteCategory(id);
  }

  @override
  Future<bool> isCategoryNameExists(String name, {String? excludeId}) async {
    return await _categoryDataSource.isCategoryNameExists(name, excludeId: excludeId);
  }

  // Operating hours operations
  @override
  Future<void> saveOperatingHours(String placeId, List<OperatingHours> operatingHours) async {
    // Delete existing operating hours
    await _placeDataSource.deleteOperatingHours(placeId);
    
    // Insert new operating hours
    if (operatingHours.isNotEmpty) {
      final operatingHoursModels = operatingHours.map((hours) {
        final id = hours.id.isEmpty ? 'oh_${_uuid.v4()}' : hours.id;
        return OperatingHoursModel.fromEntity(hours.copyWith(id: id, placeId: placeId));
      }).toList();
      
      await _placeDataSource.insertOperatingHours(operatingHoursModels);
    }
  }

  @override
  Future<List<OperatingHours>> getOperatingHours(String placeId) async {
    final operatingHoursModels = await _placeDataSource.getOperatingHours(placeId);
    return operatingHoursModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteOperatingHours(String placeId) async {
    await _placeDataSource.deleteOperatingHours(placeId);
  }

  // Event periods operations
  @override
  Future<void> saveEventPeriods(String placeId, List<EventPeriod> eventPeriods) async {
    // Delete existing event periods
    await _placeDataSource.deleteEventPeriods(placeId);
    
    // Insert new event periods
    if (eventPeriods.isNotEmpty) {
      final eventPeriodModels = eventPeriods.map((period) {
        final id = period.id.isEmpty ? 'ep_${_uuid.v4()}' : period.id;
        return EventPeriodModel.fromEntity(period.copyWith(id: id, placeId: placeId));
      }).toList();
      
      await _placeDataSource.insertEventPeriods(eventPeriodModels);
    }
  }

  @override
  Future<List<EventPeriod>> getEventPeriods(String placeId) async {
    final eventPeriodModels = await _placeDataSource.getEventPeriods(placeId);
    return eventPeriodModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<EventPeriod>> getActiveEventPeriods(String placeId) async {
    final eventPeriodModels = await _placeDataSource.getActiveEventPeriods(placeId);
    return eventPeriodModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteEventPeriods(String placeId) async {
    await _placeDataSource.deleteEventPeriods(placeId);
  }

  // Complex operations
  @override
  Future<Place?> getPlaceWithDetails(String id) async {
    final placeModel = await _placeDataSource.getPlace(id);
    if (placeModel == null) return null;
    
    // Get category
    final categoryModel = await _categoryDataSource.getCategory(placeModel.categoryId);
    final category = categoryModel?.toEntity();
    
    // Get operating hours
    final operatingHoursModels = await _placeDataSource.getOperatingHours(id);
    final operatingHours = operatingHoursModels.map((model) => model.toEntity()).toList();
    
    // Get event periods
    final eventPeriodModels = await _placeDataSource.getEventPeriods(id);
    final eventPeriods = eventPeriodModels.map((model) => model.toEntity()).toList();
    
    return placeModel.toEntity(
      category: category,
      operatingHours: operatingHours,
      eventPeriods: eventPeriods,
    );
  }

  @override
  Future<List<Place>> getPlacesWithDetails() async {
    final placeModels = await _placeDataSource.getAllPlaces();
    final places = <Place>[];
    
    for (final placeModel in placeModels) {
      final placeWithDetails = await getPlaceWithDetails(placeModel.id);
      if (placeWithDetails != null) {
        places.add(placeWithDetails);
      }
    }
    
    return places;
  }

  @override
  Future<List<Place>> searchPlaces(String query) async {
    final allPlaces = await _placeDataSource.getAllPlaces();
    final queryLower = query.toLowerCase();
    
    final matchingPlaces = allPlaces.where((place) {
      return place.name.toLowerCase().contains(queryLower) ||
             (place.description?.toLowerCase().contains(queryLower) ?? false) ||
             (place.address?.toLowerCase().contains(queryLower) ?? false) ||
             (place.notes?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
    
    return matchingPlaces.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Place>> detectDuplicatePlaces(
    double latitude, 
    double longitude, 
    {double radiusMeters = 100}
  ) async {
    final radiusKm = radiusMeters / 1000.0;
    final nearbyPlaces = await getPlacesNearby(latitude, longitude, radiusKm);
    
    // Filter places within the exact radius
    return nearbyPlaces.where((place) {
      final distance = place.distanceFrom(latitude, longitude) * 1000; // Convert to meters
      return distance <= radiusMeters;
    }).toList();
  }
}