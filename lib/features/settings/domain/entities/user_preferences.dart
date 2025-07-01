import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('auto') String mapProvider, // 'auto', 'naver', 'google'
    @Default(2.0) double defaultSearchRadius, // km
    @Default(true) bool autoDeleteExpiredEvents,
    @Default(true) bool enableNotifications,
    @Default('system') String themeMode, // 'light', 'dark', 'system'
    @Default('ko') String language, // 'ko', 'en'
    @Default(true) bool enableLocationServices,
    @Default(false) bool enableAnalytics,
    @Default(30) int eventReminderDays, // days before event ends
    DateTime? lastBackupDate,
  }) = _UserPreferences;

  const UserPreferences._();

  /// Convert search radius to meters for calculations
  double get searchRadiusInMeters => defaultSearchRadius * 1000;

  /// Check if dark mode should be used
  bool isDarkMode(BuildContext context) {
    switch (themeMode) {
      case 'light':
        return false;
      case 'dark':
        return true;
      case 'system':
      default:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  /// Get localized map provider display name
  String getMapProviderDisplayName() {
    switch (mapProvider) {
      case 'naver':
        return 'Naver Maps';
      case 'google':
        return 'Google Maps';
      case 'auto':
      default:
        return '자동 선택';
    }
  }

  /// Get localized theme mode display name
  String getThemeModeDisplayName() {
    switch (themeMode) {
      case 'light':
        return '라이트 모드';
      case 'dark':
        return '다크 모드';
      case 'system':
      default:
        return '시스템 설정';
    }
  }
}
