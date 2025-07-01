import 'package:locus_flutter/features/settings/domain/repositories/settings_repository.dart';

class ClearAllData {
  final SettingsRepository _settingsRepository;

  ClearAllData(this._settingsRepository);

  Future<void> call() async {
    try {
      // 모든 앱 데이터 삭제 (장소, 카테고리, 설정 포함)
      await _settingsRepository.clearAllData();
    } catch (e) {
      throw DataClearException('Failed to clear all data: $e');
    }
  }
}

class DataClearException implements Exception {
  final String message;
  
  DataClearException(this.message);
  
  @override
  String toString() => 'DataClearException: $message';
}