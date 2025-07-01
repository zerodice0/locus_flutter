import '../repositories/settings_repository.dart';

class ExportAppData {
  final SettingsRepository repository;

  ExportAppData(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.exportAppData();
  }
}

class ImportAppData {
  final SettingsRepository repository;

  ImportAppData(this.repository);

  Future<void> call(Map<String, dynamic> data) async {
    await repository.importAppData(data);
  }
}

class ResetAppData {
  final SettingsRepository repository;

  ResetAppData(this.repository);

  Future<void> call() async {
    await repository.clearAllData();
    await repository.resetToDefaults();
  }
}
