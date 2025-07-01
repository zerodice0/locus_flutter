import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/user_preferences_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<UserPreferences> getUserPreferences() async {
    try {
      final model = await localDataSource.getUserPreferences();
      return model.toEntity();
    } catch (e) {
      // Return default preferences on error
      return const UserPreferences();
    }
  }

  @override
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      final model = UserPreferencesModel.fromEntity(preferences);
      await localDataSource.saveUserPreferences(model);
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await localDataSource.clearPreferences();
    } catch (e) {
      throw Exception('Failed to reset preferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportAppData() async {
    try {
      return await localDataSource.exportAllData();
    } catch (e) {
      throw Exception('Failed to export app data: $e');
    }
  }

  @override
  Future<void> importAppData(Map<String, dynamic> data) async {
    try {
      await localDataSource.importAllData(data);
    } catch (e) {
      throw Exception('Failed to import app data: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await localDataSource.clearPreferences();
      // Additional cleanup would go here (places, categories, etc.)
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  @override
  Future<String> getAppVersion() async {
    try {
      return await localDataSource.getAppVersion();
    } catch (e) {
      return '1.0.0';
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return await localDataSource.isFirstLaunch();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setFirstLaunchCompleted() async {
    try {
      await localDataSource.setFirstLaunchCompleted();
    } catch (e) {
      throw Exception('Failed to set first launch completed: $e');
    }
  }
}
