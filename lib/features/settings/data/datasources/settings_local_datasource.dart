import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user_preferences_model.dart';
import '../../../place_management/data/datasources/place_local_datasource.dart';
import '../../../place_management/data/datasources/category_local_datasource.dart';
import '../../../place_management/data/models/place_model.dart';
import '../../../place_management/data/models/category_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferencesModel> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferencesModel preferences);
  Future<void> clearPreferences();
  Future<Map<String, dynamic>> exportAllData();
  Future<void> importAllData(Map<String, dynamic> data);
  Future<void> clearAllAppData();
  Future<String> getAppVersion();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchCompleted();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _preferencesKey = 'user_preferences';
  static const String _firstLaunchKey = 'first_launch';

  final PlaceLocalDataSource placeDataSource;
  final CategoryLocalDataSource categoryDataSource;

  SettingsLocalDataSourceImpl({
    required this.placeDataSource,
    required this.categoryDataSource,
  });

  @override
  Future<UserPreferencesModel> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferencesKey);

    if (jsonString == null) {
      // Return default preferences
      return const UserPreferencesModel();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPreferencesModel.fromJson(json);
    } catch (e) {
      // If parsing fails, return default preferences
      return const UserPreferencesModel();
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, jsonString);
  }

  @override
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferencesKey);
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      // Get all places
      final places = await placeDataSource.getAllPlaces();

      // Get all categories
      final categories = await categoryDataSource.getAllCategories();

      // Get user preferences
      final preferences = await getUserPreferences();

      // Get app version
      final appVersion = await getAppVersion();

      return {
        'version': appVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'preferences': preferences.toJson(),
        'places': places.map((place) => place.toJson()).toList(),
        'categories': categories.map((category) => category.toJson()).toList(),
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {
    try {
      // Validate data structure
      if (!data.containsKey('places') || !data.containsKey('categories')) {
        throw Exception('Invalid data format');
      }

      // Import categories first (places depend on categories)
      final categoriesData = data['categories'] as List<dynamic>;
      if (categoriesData.isNotEmpty) {
        final categoryModels = categoriesData
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .where((category) => !category.isDefault) // 기본 카테고리는 제외
            .toList();
        
        if (categoryModels.isNotEmpty) {
          await categoryDataSource.insertCategories(categoryModels);
          debugPrint('Imported ${categoryModels.length} user categories');
        }
      }

      // Import places
      final placesData = data['places'] as List<dynamic>;
      if (placesData.isNotEmpty) {
        final placeModels = placesData
            .map((json) => PlaceModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        await placeDataSource.insertPlaces(placeModels);
        debugPrint('Imported ${placeModels.length} places');
      }

      // Import preferences
      if (data.containsKey('preferences')) {
        final preferencesData = data['preferences'] as Map<String, dynamic>;
        final preferences = UserPreferencesModel.fromJson(preferencesData);
        await saveUserPreferences(preferences);
        debugPrint('Imported user preferences');
      }

      debugPrint('Data import completed successfully');
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  @override
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0+1';
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_firstLaunchKey);
  }

  @override
  Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  @override
  Future<void> clearAllAppData() async {
    try {
      // 1. 모든 장소 데이터 삭제
      await _clearAllPlaces();
      
      // 2. 사용자 정의 카테고리 삭제 (기본 카테고리는 유지)
      await _clearUserCategories();
      
      // 3. 모든 설정 삭제
      await clearPreferences();
      
      // 4. 첫 실행 플래그도 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_firstLaunchKey);
      
      debugPrint('All app data cleared successfully');
    } catch (e) {
      throw Exception('Failed to clear all app data: $e');
    }
  }

  Future<void> _clearAllPlaces() async {
    try {
      // PlaceLocalDataSource에서 모든 장소 삭제
      final places = await placeDataSource.getAllPlaces();
      for (final place in places) {
        await placeDataSource.deletePlace(place.id);
      }
      debugPrint('Cleared ${places.length} places');
    } catch (e) {
      debugPrint('Error clearing places: $e');
      throw Exception('Failed to clear places: $e');
    }
  }

  Future<void> _clearUserCategories() async {
    try {
      // 사용자 정의 카테고리만 삭제 (기본 카테고리는 유지)
      final userCategories = await categoryDataSource.getUserCategories();
      for (final category in userCategories) {
        await categoryDataSource.deleteCategory(category.id);
      }
      debugPrint('Cleared ${userCategories.length} user categories');
    } catch (e) {
      debugPrint('Error clearing user categories: $e');
      throw Exception('Failed to clear user categories: $e');
    }
  }
}
