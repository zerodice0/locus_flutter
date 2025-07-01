import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class UpdatePreferences {
  final SettingsRepository repository;

  UpdatePreferences(this.repository);

  Future<void> call(UserPreferences preferences) async {
    await repository.updateUserPreferences(preferences);
  }
}
