import '../entities/user_preferences.dart';

abstract class SettingsRepository {
  /// Get current user preferences
  Future<UserPreferences> getUserPreferences();

  /// Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences);

  /// Reset preferences to default values
  Future<void> resetToDefaults();

  /// Export all app data as JSON
  Future<Map<String, dynamic>> exportAppData();

  /// Import app data from JSON
  Future<void> importAppData(Map<String, dynamic> data);

  /// Clear all app data
  Future<void> clearAllData();

  /// Get app version info
  Future<String> getAppVersion();

  /// Check if this is first app launch
  Future<bool> isFirstLaunch();

  /// Set first launch flag
  Future<void> setFirstLaunchCompleted();
}
