import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user_preferences_model.dart';
import '../../../place_management/data/datasources/place_local_datasource.dart';
import '../../../place_management/data/datasources/category_local_datasource.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferencesModel> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferencesModel preferences);
  Future<void> clearPreferences();
  Future<Map<String, dynamic>> exportAllData();
  Future<void> importAllData(Map<String, dynamic> data);
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

      // Clear existing data first
      await placeDataSource.clearAllPlaces();
      await categoryDataSource.clearAllCategories();

      // Import categories first (places depend on categories)
      final categoriesData = data['categories'] as List<dynamic>;
      for (final categoryJson in categoriesData) {
        // This would need to be implemented in CategoryLocalDataSource
        // await categoryDataSource.insertCategory(CategoryModel.fromJson(categoryJson));
      }

      // Import places
      final placesData = data['places'] as List<dynamic>;
      for (final placeJson in placesData) {
        // This would need to be implemented in PlaceLocalDataSource
        // await placeDataSource.insertPlace(PlaceModel.fromJson(placeJson));
      }

      // Import preferences
      if (data.containsKey('preferences')) {
        final preferencesData = data['preferences'] as Map<String, dynamic>;
        final preferences = UserPreferencesModel.fromJson(preferencesData);
        await saveUserPreferences(preferences);
      }
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
}
