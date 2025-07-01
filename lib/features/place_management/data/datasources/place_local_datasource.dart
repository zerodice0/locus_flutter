import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import 'package:locus_flutter/core/database/database_helper.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';
import 'package:locus_flutter/features/place_management/data/models/place_model.dart';
import 'package:locus_flutter/features/place_management/data/models/operating_hours_model.dart';
import 'package:locus_flutter/features/place_management/data/models/event_period_model.dart';

abstract class PlaceLocalDataSource {
  Future<String> insertPlace(PlaceModel place);
  Future<void> insertPlaces(List<PlaceModel> places);
  Future<PlaceModel?> getPlace(String id);
  Future<List<PlaceModel>> getAllPlaces();
  Future<List<PlaceModel>> getPlacesByCategory(String categoryId);
  Future<List<PlaceModel>> getActivePlaces();
  Future<List<PlaceModel>> getPlacesNearby(
    double latitude,
    double longitude,
    double radiusKm,
  );
  Future<void> updatePlace(PlaceModel place);
  Future<void> deletePlace(String id);
  Future<void> incrementVisitCount(String placeId);

  // Operating hours
  Future<void> insertOperatingHours(List<OperatingHoursModel> operatingHours);
  Future<List<OperatingHoursModel>> getOperatingHours(String placeId);
  Future<void> updateOperatingHours(List<OperatingHoursModel> operatingHours);
  Future<void> deleteOperatingHours(String placeId);

  // Event periods
  Future<void> insertEventPeriods(List<EventPeriodModel> eventPeriods);
  Future<List<EventPeriodModel>> getEventPeriods(String placeId);
  Future<List<EventPeriodModel>> getActiveEventPeriods(String placeId);
  Future<void> updateEventPeriods(List<EventPeriodModel> eventPeriods);
  Future<void> deleteEventPeriods(String placeId);
}

class PlaceLocalDataSourceImpl implements PlaceLocalDataSource {
  final DatabaseHelper _databaseHelper;
  // final Uuid _uuid; // Currently unused

  PlaceLocalDataSourceImpl({required DatabaseHelper databaseHelper, Uuid? uuid})
    : _databaseHelper = databaseHelper;
  // _uuid = uuid ?? const Uuid(); // Currently unused

  @override
  Future<String> insertPlace(PlaceModel place) async {
    final placeData = place.toDatabase();
    await _databaseHelper.insert(DatabaseConstants.tablePlaces, placeData);
    return place.id;
  }

  @override
  Future<void> insertPlaces(List<PlaceModel> places) async {
    for (final place in places) {
      final placeData = place.toDatabase();
      await _databaseHelper.insert(DatabaseConstants.tablePlaces, placeData);
    }
  }

  @override
  Future<PlaceModel?> getPlace(String id) async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      where: '${DatabaseConstants.placeId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return PlaceModel.fromDatabase(results.first);
  }

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      orderBy: '${DatabaseConstants.placeUpdatedAt} DESC',
    );

    return results.map((row) => PlaceModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<PlaceModel>> getPlacesByCategory(String categoryId) async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      where: '${DatabaseConstants.placeCategoryId} = ?',
      whereArgs: [categoryId],
      orderBy: '${DatabaseConstants.placeUpdatedAt} DESC',
    );

    return results.map((row) => PlaceModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<PlaceModel>> getActivePlaces() async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      where: '${DatabaseConstants.placeIsActive} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.placeUpdatedAt} DESC',
    );

    return results.map((row) => PlaceModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<PlaceModel>> getPlacesNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    // Calculate bounding box for initial filtering
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double deltaLat = radiusKm / earthRadius * (180 / math.pi);
    final double deltaLng =
        radiusKm /
        (earthRadius * (math.pi / 180)) /
        math.cos(latitude * math.pi / 180);

    final double minLat = latitude - deltaLat;
    final double maxLat = latitude + deltaLat;
    final double minLng = longitude - deltaLng;
    final double maxLng = longitude + deltaLng;

    final results = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      where: '''
        ${DatabaseConstants.placeIsActive} = 1 AND
        ${DatabaseConstants.placeLatitude} BETWEEN ? AND ? AND
        ${DatabaseConstants.placeLongitude} BETWEEN ? AND ?
      ''',
      whereArgs: [minLat, maxLat, minLng, maxLng],
      orderBy: '${DatabaseConstants.placeUpdatedAt} DESC',
    );

    return results.map((row) => PlaceModel.fromDatabase(row)).toList();
  }

  @override
  Future<void> updatePlace(PlaceModel place) async {
    final placeData = place.toDatabase();
    await _databaseHelper.update(
      DatabaseConstants.tablePlaces,
      placeData,
      where: '${DatabaseConstants.placeId} = ?',
      whereArgs: [place.id],
    );
  }

  @override
  Future<void> deletePlace(String id) async {
    await _databaseHelper.delete(
      DatabaseConstants.tablePlaces,
      where: '${DatabaseConstants.placeId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> incrementVisitCount(String placeId) async {
    await _databaseHelper.rawUpdate(
      '''
      UPDATE ${DatabaseConstants.tablePlaces} 
      SET ${DatabaseConstants.placeVisitCount} = ${DatabaseConstants.placeVisitCount} + 1,
          ${DatabaseConstants.placeLastVisited} = ?,
          ${DatabaseConstants.placeUpdatedAt} = ?
      WHERE ${DatabaseConstants.placeId} = ?
      ''',
      [
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        placeId,
      ],
    );
  }

  // Operating hours methods
  @override
  Future<void> insertOperatingHours(
    List<OperatingHoursModel> operatingHours,
  ) async {
    if (operatingHours.isEmpty) return;

    await _databaseHelper.transaction((txn) async {
      for (final hours in operatingHours) {
        await txn.insert(
          DatabaseConstants.tableOperatingHours,
          hours.toDatabase(),
        );
      }
    });
  }

  @override
  Future<List<OperatingHoursModel>> getOperatingHours(String placeId) async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableOperatingHours,
      where: '${DatabaseConstants.operatingHoursPlaceId} = ?',
      whereArgs: [placeId],
      orderBy: DatabaseConstants.operatingHoursDayOfWeek,
    );

    return results.map((row) => OperatingHoursModel.fromDatabase(row)).toList();
  }

  @override
  Future<void> updateOperatingHours(
    List<OperatingHoursModel> operatingHours,
  ) async {
    if (operatingHours.isEmpty) return;

    await _databaseHelper.transaction((txn) async {
      for (final hours in operatingHours) {
        await txn.update(
          DatabaseConstants.tableOperatingHours,
          hours.toDatabase(),
          where: '${DatabaseConstants.operatingHoursId} = ?',
          whereArgs: [hours.id],
        );
      }
    });
  }

  @override
  Future<void> deleteOperatingHours(String placeId) async {
    await _databaseHelper.delete(
      DatabaseConstants.tableOperatingHours,
      where: '${DatabaseConstants.operatingHoursPlaceId} = ?',
      whereArgs: [placeId],
    );
  }

  // Event periods methods
  @override
  Future<void> insertEventPeriods(List<EventPeriodModel> eventPeriods) async {
    if (eventPeriods.isEmpty) return;

    await _databaseHelper.transaction((txn) async {
      for (final period in eventPeriods) {
        await txn.insert(
          DatabaseConstants.tableEventPeriods,
          period.toDatabase(),
        );
      }
    });
  }

  @override
  Future<List<EventPeriodModel>> getEventPeriods(String placeId) async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableEventPeriods,
      where: '${DatabaseConstants.eventPeriodPlaceId} = ?',
      whereArgs: [placeId],
      orderBy: DatabaseConstants.eventPeriodStartDate,
    );

    return results.map((row) => EventPeriodModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<EventPeriodModel>> getActiveEventPeriods(String placeId) async {
    final now = DateTime.now().toIso8601String();
    final results = await _databaseHelper.query(
      DatabaseConstants.tableEventPeriods,
      where: '''
        ${DatabaseConstants.eventPeriodPlaceId} = ? AND
        ${DatabaseConstants.eventPeriodStartDate} <= ? AND
        ${DatabaseConstants.eventPeriodEndDate} >= ?
      ''',
      whereArgs: [placeId, now, now],
      orderBy: DatabaseConstants.eventPeriodStartDate,
    );

    return results.map((row) => EventPeriodModel.fromDatabase(row)).toList();
  }

  @override
  Future<void> updateEventPeriods(List<EventPeriodModel> eventPeriods) async {
    if (eventPeriods.isEmpty) return;

    await _databaseHelper.transaction((txn) async {
      for (final period in eventPeriods) {
        await txn.update(
          DatabaseConstants.tableEventPeriods,
          period.toDatabase(),
          where: '${DatabaseConstants.eventPeriodId} = ?',
          whereArgs: [period.id],
        );
      }
    });
  }

  @override
  Future<void> deleteEventPeriods(String placeId) async {
    await _databaseHelper.delete(
      DatabaseConstants.tableEventPeriods,
      where: '${DatabaseConstants.eventPeriodPlaceId} = ?',
      whereArgs: [placeId],
    );
  }
}
