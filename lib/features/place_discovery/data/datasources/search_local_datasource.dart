import 'dart:convert';

import 'package:locus_flutter/core/database/database_helper.dart';
import 'package:locus_flutter/features/place_discovery/data/models/search_settings_model.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/swipe_action.dart';
import 'package:locus_flutter/features/place_discovery/domain/usecases/calculate_distance.dart';
import 'package:locus_flutter/features/place_management/data/models/place_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SearchLocalDataSource {
  final DatabaseHelper databaseHelper;
  final CalculateDistance calculateDistance;

  SearchLocalDataSource({
    required this.databaseHelper,
    required this.calculateDistance,
  });

  static const String _searchSettingsKey = 'search_settings';
  static const String _swipeActionsTable = 'swipe_actions';

  Future<List<PlaceWithDistance>> searchNearbyPlaces({
    required double currentLat,
    required double currentLng,
    required SearchSettings settings,
  }) async {
    final Database db = await databaseHelper.database;
    
    // 기본 쿼리 구성
    String query = '''
      SELECT p.*, c.name as category_name, c.color as category_color
      FROM places p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE 1=1
    ''';
    
    List<dynamic> args = [];

    // 카테고리 필터 적용
    if (settings.categoryIds.isNotEmpty) {
      final placeholders = settings.categoryIds.map((_) => '?').join(',');
      query += ' AND p.category_id IN ($placeholders)';
      args.addAll(settings.categoryIds);
    }

    // 운영시간 고려
    if (settings.considerOperatingHours) {
      final now = DateTime.now();
      final dayOfWeek = now.weekday; // 1=Monday, 7=Sunday
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      query += '''
        AND (
          p.operating_hours IS NULL OR
          json_extract(p.operating_hours, '\$.${_getDayKey(dayOfWeek)}.isOpen') = 1 AND
          json_extract(p.operating_hours, '\$.${_getDayKey(dayOfWeek)}.openTime') <= ? AND
          json_extract(p.operating_hours, '\$.${_getDayKey(dayOfWeek)}.closeTime') >= ?
        )
      ''';
      args.addAll([currentTime, currentTime]);
    }

    // 이벤트 기간 고려
    if (settings.considerEventPeriod) {
      final now = DateTime.now().toIso8601String();
      query += '''
        AND (
          p.event_period IS NULL OR
          (json_extract(p.event_period, '\$.startDate') <= ? AND
           json_extract(p.event_period, '\$.endDate') >= ?)
        )
      ''';
      args.addAll([now, now]);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    
    // Place 객체로 변환하고 거리 계산
    final List<PlaceWithDistance> placesWithDistance = [];
    
    for (final map in maps) {
      final place = PlaceModel.fromDatabase(map).toEntity();
      final distance = calculateDistance.call(
        place: place,
        currentLat: currentLat,
        currentLng: currentLng,
      );
      
      // 반경 내에 있는 장소만 포함
      if (distance.distanceKm <= settings.radiusKm) {
        placesWithDistance.add(distance);
      }
    }

    return placesWithDistance;
  }

  Future<void> recordSwipeAction(SwipeAction action) async {
    final Database db = await databaseHelper.database;
    
    await db.insert(
      _swipeActionsTable,
      {
        'place_id': action.placeId,
        'direction': action.direction.name,
        'timestamp': action.timestamp.toIso8601String(),
        'session_id': action.sessionId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SwipeAction>> getSwipeHistory({
    String? sessionId,
    DateTime? since,
  }) async {
    final Database db = await databaseHelper.database;
    
    String query = 'SELECT * FROM $_swipeActionsTable WHERE 1=1';
    List<dynamic> args = [];

    if (sessionId != null) {
      query += ' AND session_id = ?';
      args.add(sessionId);
    }

    if (since != null) {
      query += ' AND timestamp >= ?';
      args.add(since.toIso8601String());
    }

    query += ' ORDER BY timestamp DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    
    return maps.map((map) => SwipeAction(
      placeId: map['place_id'] as String,
      direction: _parseSwipeDirection(map['direction'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      sessionId: map['session_id'] as String?,
    )).toList();
  }

  Future<SearchSettings> getSearchSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_searchSettingsKey);
    
    if (settingsJson != null) {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return SearchSettingsModel.fromJson(json).toEntity();
    }
    
    return const SearchSettings(); // 기본값 반환
  }

  Future<void> saveSearchSettings(SearchSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SearchSettingsModel model = SearchSettingsModel.fromEntity(settings);
    final String settingsJson = jsonEncode(model.toJson());
    
    await prefs.setString(_searchSettingsKey, settingsJson);
  }

  Future<void> clearSwipeHistory() async {
    final Database db = await databaseHelper.database;
    await db.delete(_swipeActionsTable);
  }

  SwipeDirection _parseSwipeDirection(String value) {
    switch (value) {
      case 'like':
        return SwipeDirection.like;
      case 'dislike':
        return SwipeDirection.dislike;
      case 'skip':
        return SwipeDirection.skip;
      default:
        return SwipeDirection.skip;
    }
  }

  String _getDayKey(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
}