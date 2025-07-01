import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';

part 'place_model.freezed.dart';
part 'place_model.g.dart';

@freezed
class PlaceModel with _$PlaceModel {
  const factory PlaceModel({
    required String id,
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    required String categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
    String? notes,
    double? rating,
    required int visitCount,
    DateTime? lastVisited,
    String? imagePath,
  }) = _PlaceModel;

  const PlaceModel._();

  factory PlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceModelFromJson(json);

  factory PlaceModel.fromDatabase(Map<String, dynamic> map) {
    return PlaceModel(
      id: map[DatabaseConstants.placeId] as String,
      name: map[DatabaseConstants.placeName] as String,
      description: map[DatabaseConstants.placeDescription] as String?,
      latitude: map[DatabaseConstants.placeLatitude] as double,
      longitude: map[DatabaseConstants.placeLongitude] as double,
      address: map[DatabaseConstants.placeAddress] as String?,
      categoryId: map[DatabaseConstants.placeCategoryId] as String,
      createdAt: DateTime.parse(map[DatabaseConstants.placeCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseConstants.placeUpdatedAt] as String),
      isActive: (map[DatabaseConstants.placeIsActive] as int) == 1,
      notes: map[DatabaseConstants.placeNotes] as String?,
      rating: map[DatabaseConstants.placeRating] as double?,
      visitCount: map[DatabaseConstants.placeVisitCount] as int,
      lastVisited: map[DatabaseConstants.placeLastVisited] != null
          ? DateTime.parse(map[DatabaseConstants.placeLastVisited] as String)
          : null,
      imagePath: map[DatabaseConstants.placeImagePath] as String?,
    );
  }

  factory PlaceModel.fromEntity(Place entity) {
    return PlaceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      categoryId: entity.categoryId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      notes: entity.notes,
      rating: entity.rating,
      visitCount: entity.visitCount,
      lastVisited: entity.lastVisited,
      imagePath: entity.imagePath,
    );
  }

  Place toEntity({
    Category? category,
    List<OperatingHours>? operatingHours,
    List<EventPeriod>? eventPeriods,
  }) {
    return Place(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      notes: notes,
      rating: rating,
      visitCount: visitCount,
      lastVisited: lastVisited,
      imagePath: imagePath,
      category: category,
      operatingHours: operatingHours,
      eventPeriods: eventPeriods,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      DatabaseConstants.placeId: id,
      DatabaseConstants.placeName: name,
      DatabaseConstants.placeDescription: description,
      DatabaseConstants.placeLatitude: latitude,
      DatabaseConstants.placeLongitude: longitude,
      DatabaseConstants.placeAddress: address,
      DatabaseConstants.placeCategoryId: categoryId,
      DatabaseConstants.placeCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.placeUpdatedAt: updatedAt.toIso8601String(),
      DatabaseConstants.placeIsActive: isActive ? 1 : 0,
      DatabaseConstants.placeNotes: notes,
      DatabaseConstants.placeRating: rating,
      DatabaseConstants.placeVisitCount: visitCount,
      DatabaseConstants.placeLastVisited: lastVisited?.toIso8601String(),
      DatabaseConstants.placeImagePath: imagePath,
    };
  }
}