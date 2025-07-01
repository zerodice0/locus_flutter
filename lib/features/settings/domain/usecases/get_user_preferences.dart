import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class GetUserPreferences {
  final SettingsRepository repository;

  GetUserPreferences(this.repository);

  Future<UserPreferences> call() async {
    return await repository.getUserPreferences();
  }
}
