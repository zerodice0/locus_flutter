import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_preferences.dart';

part 'user_preferences_model.freezed.dart';
part 'user_preferences_model.g.dart';

@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  const factory UserPreferencesModel({
    @Default('auto') String mapProvider,
    @Default(2.0) double defaultSearchRadius,
    @Default(true) bool autoDeleteExpiredEvents,
    @Default(true) bool enableNotifications,
    @Default('system') String themeMode,
    @Default('ko') String language,
    @Default(true) bool enableLocationServices,
    @Default(false) bool enableAnalytics,
    @Default(30) int eventReminderDays,
    DateTime? lastBackupDate,
  }) = _UserPreferencesModel;

  const UserPreferencesModel._();

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  /// Convert to domain entity
  UserPreferences toEntity() {
    return UserPreferences(
      mapProvider: mapProvider,
      defaultSearchRadius: defaultSearchRadius,
      autoDeleteExpiredEvents: autoDeleteExpiredEvents,
      enableNotifications: enableNotifications,
      themeMode: themeMode,
      language: language,
      enableLocationServices: enableLocationServices,
      enableAnalytics: enableAnalytics,
      eventReminderDays: eventReminderDays,
      lastBackupDate: lastBackupDate,
    );
  }

  /// Create from domain entity
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      mapProvider: entity.mapProvider,
      defaultSearchRadius: entity.defaultSearchRadius,
      autoDeleteExpiredEvents: entity.autoDeleteExpiredEvents,
      enableNotifications: entity.enableNotifications,
      themeMode: entity.themeMode,
      language: entity.language,
      enableLocationServices: entity.enableLocationServices,
      enableAnalytics: entity.enableAnalytics,
      eventReminderDays: entity.eventReminderDays,
      lastBackupDate: entity.lastBackupDate,
    );
  }
}
